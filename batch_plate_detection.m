close all;
clear all;

% Folder path
folderPath = 'TestSet'; % Specify the folder path here (relative or absolute)

% Get all images in the folder (supports jpg, png, jpeg)
imageFiles = dir(fullfile(folderPath, '*.jpg'));  % You can add other formats like '*.png', '*.jpeg' etc.
imageFiles = [imageFiles; dir(fullfile(folderPath, '*.png'))]; % Add more file types if needed
imageFiles = [imageFiles; dir(fullfile(folderPath, '*.jpeg'))]; % Add more file types if needed

% Initialize cell arrays to store results
imageNames = {};
licensePlateTexts = {};

% Loop through each image in the folder
for i = 1:length(imageFiles)
    try
        % Get the full path of the image
        imgPath = fullfile(imageFiles(i).folder, imageFiles(i).name);
        
        % Read the image
        im = imread(imgPath);
        
        % Convert to HSV and enhance contrast using CLAHE
        hsv_im = rgb2hsv(im);
        v_channel = hsv_im(:,:,3);  % Use value channel for brightness
        v_eq = adapthisteq(v_channel);  % CLAHE - adaptive histogram equalization
        
        % Edge detection with Canny on enhanced brightness
        edges = edge(v_eq, 'Canny', [0.2 0.5]);

        % Remove small noise and fill holes
        edges_clean = bwareaopen(edges, 150);  % Remove small areas
        edges_clean = imclose(edges_clean, strel('rectangle', [5,15])); % Close gaps
        edges_clean = imfill(edges_clean, 'holes');

        % Region properties
        stats = regionprops(edges_clean, 'BoundingBox', 'Area', 'Eccentricity', 'Solidity');

        % Filter regions and detect plates
        plateDetected = false; % Flag to check if any plate was detected
        for j = 1:length(stats)
            bbox = stats(j).BoundingBox;
            aspectRatio = bbox(3) / bbox(4);
            solidity = stats(j).Solidity;

            % License plate filters:
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

                % Binarization (Adaptive thresholding)
                bw_plate = imbinarize(gray_plate, 'adaptive', 'Sensitivity', 1);

                % Use OCR to read text
                ocrResult = ocr(bw_plate);

                % Check if OCR detected any text
                if ~isempty(ocrResult.Text)
                    detectedText = ocrResult.Text;
                else
                    detectedText = ''; % Set as empty string if no text detected
                end

                % Remove any special characters from the OCR result
                if ischar(detectedText)  % Ensure it is a char array before applying regex
                    cleaned_text = regexprep(detectedText, '[^A-Za-z0-9]', '');
                else
                    cleaned_text = '';  % Handle non-string cases
                end

                % Store the result in cell arrays
                imageNames{end+1} = imageFiles(i).name;
                licensePlateTexts{end+1} = cleaned_text;

                plateDetected = true; % Mark that a plate was detected
            end
        end
        
        % If no plate was detected, store NaN in both fields
        if ~plateDetected
            imageNames{end+1} = imageFiles(i).name;
            licensePlateTexts{end+1} = NaN;
        end
    catch ME
        % Handle any errors in processing and continue with the next image
        disp(['Error processing image: ' imageFiles(i).name]);
        disp(['Error message: ' ME.message]);
        imageNames{end+1} = imageFiles(i).name;
        licensePlateTexts{end+1} = NaN;  % Store NaN if the image could not be processed
    end
end

% Remove entries where license plate text is NaN
validIndices = ~cellfun(@(x) isequal(x, NaN), licensePlateTexts);
imageNames = imageNames(validIndices);
licensePlateTexts = licensePlateTexts(validIndices);

% Save the results to a CSV file
outputTable = table(imageNames', licensePlateTexts', 'VariableNames', {'ImageName', 'LicensePlateText'});
writetable(outputTable, 'batch_license_plate_results.csv');

disp('Processing complete. Results saved to "batch_license_plate_results.csv".');
