# Design For Visual Systems Project: License Plate Detection and OCR Application

## Project Overview

This MATLAB-based application performs **license plate detection** and **optical character recognition (OCR)** from images. It processes input images, detects the license plate region accurately, extracts it, and recognizes the text using OCR techniques.

> **Note**: Although this started as a group project, I, **Danush**, have completed this project **individually**.

---

##  Workflow Overview

The application is divided into two major stages for better accuracy and modularity:

### 1. License Plate Detection
- Full image is preprocessed to detect potential license plate regions.
- Methods: CLAHE, edge detection, morphological operations, region filtering by aspect ratio and solidity.

### 2. License Plate Reading (OCR)
- After plate detection, additional preprocessing is done on the **cropped plate only**.
- Methods: adaptive thresholding, noise removal, OCR text extraction and cleanup.

> Separating these two stages improved accuracy, allowed stepwise debugging, and reduced OCR errors.

---

##  Achievements

- Developed a robust pipeline for license plate detection and text extraction.
- Applied preprocessing techniques like **CLAHE** for contrast enhancement, **Canny edge detection**, and **morphological operations** for noise reduction.
- Detected license plate regions using adaptive methods (aspect ratio and solidity checks).
- Applied **OCR** to the detected plates and cleaned the text for accuracy.
- Automated result storage in a **CSV file** for scalability and record-keeping.

### Results:

- **Preprocessing and Plate Detection**:
  - Enhanced image contrast using **CLAHE**.
  - Detected potential plate regions after applying edge detection and morphological operations.
    ![Screenshot 2025-03-21 003822](https://github.com/user-attachments/assets/4f702ce8-1c57-4671-b5eb-b5fab5076991)


- **Plate Reading and OCR**:
  - Extracted and cleaned OCR text from the detected plates.
  - Results stored in **`license_plate_results.csv`** for record-keeping.
    ![Screenshot 2025-03-21 003845](https://github.com/user-attachments/assets/d159ca23-056a-45b7-8e72-d843a2477833)



- Techniques used:
  - CLAHE for contrast enhancement
  - Canny edge detection
  - Morphological operations
  - Region filtering (aspect ratio, solidity)
  - OCR with post-processing cleanup

---

##  Preprocessing Steps

### Before Plate Detection (Full Image):
- **CLAHE**: Enhance contrast.
- **Canny Edge Detection**: Identify edges robustly.
- **Morphology**: Dilate/erode to remove noise.
- **Region Filtering**: Keep regions likely to be plates (based on shape features).

### After Plate Detection (Plate Region Only):
- **Crop Plate Region**.
- **Adaptive Thresholding**: Sharpen contrast.
- **Noise Removal**: Clean image for OCR.
- **OCR**: Recognize characters and clean output.

---

##  How to Run

### Requirements
- MATLAB R2021a or newer
- Image Processing Toolbox
- OCR Toolbox

### Scripts Included

| Script Name                  | Functionality                                                    |
|-----------------------------|------------------------------------------------------------------|
| `license_plate_detection.m` | **Manual Testing**: Select image manually and view results       |
| `batch_plate_detection.m`   | **Batch Processing**: Run on all images in `/TestSet`, save CSV  |

---

##  Evaluation

### What the Application Can Do:
- Detect plates from clear, front-facing images.
- Accurately OCR license plate text.
- Visualize each step of processing.
- Save results to CSV automatically.

### What it Cannot Do (Yet):
- Handle low-res, distorted, or angled plates.
- Handle different plate colors (e.g., yellow/red plates may fail).
- Differentiate between **large plates vs. windshield** (may get confused).
- Support real-time or video input.

---

##  Personal Contribution

- I developed **all code and design** independently.
- Researched and applied image processing and OCR techniques.
- Debugged and modularized the code.
- Created this README and structured the project.

### Mistake → Lesson:
Initially, I attempted **plate detection and OCR simultaneously** within the same loop. This caused:
- Poor detection accuracy.
- Noisy OCR outputs.

**Fix**: Split the workflow into **two parts** (plate detection first, OCR second). This made the process **cleaner, more accurate, and easier to debug**.

---

##  Future Improvements

To overcome current limitations, I plan to integrate **machine learning**:

- Use **CNN-based models** (e.g., YOLOv5 or SSD) for:
  - Better plate detection across colors, sizes, and angles.
  - Avoid confusion between plates and other objects like windshields.

Other planned improvements:
- Add **batch processing** with folder input.
- GUI for user-friendly interaction.
- Real-time detection from **video feeds**.

---

##  Reflection

This project deepened my understanding of:
- Image processing techniques (CLAHE, edge detection, morphological ops).
- Region selection based on shape metrics.
- OCR optimization.
- Writing clean, modular, and scalable code

