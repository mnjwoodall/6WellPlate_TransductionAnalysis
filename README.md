# 6WellPlate_TransductionAnalysis

## Overview
This macro is designed to analyze transduction efficiency in a 6-well plate by counting transduced cells (GFP positive) and live cells (transmitted light signal) from microscopy images. It processes images acquired with separate green (GFP) and red (transmitted light) channels, applying correction and enhancement techniques to quantify transduction rates.

## Experimental Procedure
For viral titre definition, cells were analyzed for transgene expression 96 hours after the transduction procedure. The procedure involved:
- Washing the cells 3x with PBS to remove residual phenol red from the growth medium.
- Submerging cells in Ussing buffer for the duration of the microscopy analysis.
  
At least 10 images were taken from each well using a Nikon Inverted Microscope Eclipse Ti-S at 10x magnification, or 16 images using a Cytation™ 5 - Cell Imaging Multi-Mode Reader at 4x magnification. Both fluorescent signals (GFP) and transmitted light were captured for each well.

The images were then analyzed using this ImageJ macro designed specifically for quantifying the ratio of fluorescent to non-fluorescent cells. The macro converts transmitted light images and fluorescence images from the same XY position into binary masks, enabling accurate identification of fluorescent and non-fluorescent cells. Dead cells were excluded from the analysis using a size and granulation threshold.

## Calculation of Transduction Efficiency
Transduction efficiency was calculated using the following equation:

**% Transduced = (Σ (GFP positive pixels) / (GFP positive pixels + total pixels within all cell regions)) / (0.01 × n)**

Where:
- `n` is the number of images taken per well.

### Calibration
The results were initially calibrated against flow cytometry analysis using a 1.5 x 10^5 cell sample from each well to verify the accuracy of the technique.

## Viral Titre Calculation
Viral titre for each lentiviral suspension was calculated using the equation:

**Infectious particles/µl = (2.5 × 10^5 × % Transduced) / x**

Where `x` is the volume of lentiviral suspension applied in µl.

## Analysis Steps
1. **Split Channels**: The macro splits the image into individual channels for processing.
2. **Transmitted Light (Red Channel)**: 
   - Background subtraction with a rolling ball radius of 20.
   - Contrast enhancement, median filtering, and thresholding (Huang method) applied to identify cell regions.
3. **GFP (Green Channel)**:
   - Background subtraction with a rolling ball radius of 5.
   - Further contrast enhancement and filtering, followed by thresholding using the Li method to detect GFP signals.
4. **Combining Data**: The macro generates an overlay mask combining GFP and transmitted light signals for particle analysis.

## Output
- Mask images are saved in a `results` folder within the selected directory.
- A summary file (`summary.txt`) containing particle analysis data for each well is generated.

## How to Use the Macro
1. **Install ImageJ** if you haven't already.
2. Open the macro script in ImageJ.
3. Run the macro and select the directory containing your `.tif` images when prompted.

## Important Notes
- The macro uses a minimum size cutoff of 59 pixels.
- The images should only contain `.tif` files for accurate processing.

## License
This project is licensed under the [Apache License 2.0](./LICENSE) - see the LICENSE file for details.

## Author
- **Max Woodall** - Creator and maintainer of the macro script.
