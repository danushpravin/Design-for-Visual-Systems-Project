close all;
clear all;

% Let user select an image
[filename, pathname] = uigetfile({'*.jpg;*.jpeg;*.png', 'Image Files (*.jpg, *.jpeg, *.png)'}, 'Select an Image');
if isequal(filename, 0)
    disp('User canceled image selection.');
    return;
end
imgPath = fullfile(pathname, filename);

% Initialize result storage
imageNames = {};
licensePlateTexts = {};

try
    % Read the image
    im = imread(imgPath);

    % Convert to HSV and enhance contrast using CLAHE
    hsv_im = rgb2hsv(im);
    v_channel = hsv_im(:,:,3);  % Value channel for brightness
    v_eq = adapthisteq(v_channel);  % CLAHE - adaptive histogram equalization

    % Edge detection with Canny on enhanced brightness
    edges = edge(v_eq, 'Canny', [0.2 0.5]);

    % Remove small noise and fill holes
    edges_clean = bwareaopen(edges, 150);  % Remove small areas
    edges_clean = imclose(edges_clean, strel('rectangle', [5,15])); % Close gaps
    edges_clean = imfill(edges_clean, 'holes');

    % Region properties
    stats = regionprops(edges_clean, 'BoundingBox', 'Area', 'Eccentricity', 'Solidity');

    % --- Display Preprocessing Steps: Panel 1 ---
    figure('Name', 'Preprocessing Before Plate Detection', 'NumberTitle', 'off');
    subplot(2,3,1);
    imshow(im);
    title('Original Image');

    subplot(2,3,2);
    imshow(v_channel);
    title('V Channel');

    subplot(2,3,3);
    imshow(v_eq);
    title('CLAHE Enhanced V');

    subplot(2,3,4);
    imshow(edges);
    title('Canny Edges');

    subplot(2,3,5);
    imshow(edges_clean);
    title('Cleaned Edges');

    % Initialize flag
    plateDetected = false;

    % Loop through regions to find license plate
    for j = 1:length(stats)
        bbox = stats(j).BoundingBox;
        aspectRatio = bbox(3) / bbox(4);
        solidity = stats(j).Solidity;

        % License plate filter
        if aspectRatio > 3 && aspectRatio < 5 && solidity > 0.5
            % Crop license plate
            x1 = round(bbox(1));
            y1 = round(bbox(2));
            x2 = round(bbox(1) + bbox(3));
            y2 = round(bbox(2) + bbox(4));

            % Boundary check
            x1 = max(x1, 1); y1 = max(y1, 1);
            x2 = min(x2, size(im, 2)); y2 = min(y2, size(im, 1));

            license_plate = im(y1:y2, x1:x2, :);

            % Preprocessing for OCR
            gray_plate = rgb2gray(license_plate);
            bw_plate = imbinarize(gray_plate, 'adaptive', 'Sensitivity', 1);

            % OCR detection
            ocrResult = ocr(bw_plate);

            if ~isempty(ocrResult.Text)
                detectedText = ocrResult.Text;
            else
                detectedText = '';
            end

            % Clean OCR result
            if ischar(detectedText)
                cleaned_text = regexprep(detectedText, '[^A-Za-z0-9]', '');
            else
                cleaned_text = '';
            end

            % Store results
            imageNames{end+1} = filename;
            licensePlateTexts{end+1} = cleaned_text;
            plateDetected = true;

            % --- Display Post-Detection Steps: Panel 2 ---
            figure('Name', 'Post Plate Detection and OCR', 'NumberTitle', 'off');
            subplot(2,3,1);
            imshow(license_plate);
            title('Detected License Plate');

            subplot(2,3,2);
            imshow(gray_plate);
            title('Grayscale Plate');

            subplot(2,3,3);
            imshow(bw_plate);
            title('Binarized Plate');

            subplot(2,3,4);
            imshow(insertShape(im, 'Rectangle', bbox, 'Color', 'green', 'LineWidth', 2));
            title('Plate Location');

            subplot(2,3,5);
            imshow(bw_plate);
            title(['OCR: ' cleaned_text]);

            break; % Plate detected, stop further search
        end
    end

    % If no plate detected, store NaN
    if ~plateDetected
        imageNames{end+1} = filename;
        licensePlateTexts{end+1} = NaN;

        figure('Name', 'Post Plate Detection and OCR', 'NumberTitle', 'off');
        subplot(2,3,1);
        imshow(im);
        title('No License Plate Detected');
    end

catch ME
    disp(['Error processing image: ' filename]);
    disp(['Error message: ' ME.message]);
    imageNames{end+1} = filename;
    licensePlateTexts{end+1} = NaN;
end

