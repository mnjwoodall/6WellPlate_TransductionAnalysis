/*  
 *  Transduction Rate Analysis Macro for 6 Well Plate
 * 
 *  This macro processes microscopy images to analyze transduction efficiency in a 6-well plate by counting transduced cells in the green channel (GFP) and live cells in the transmitted light channel (red).
 * 
 *  Copyright (c) 2019 Max Woodall 
 * 
 *  Assumes fluorescence in green and transmitted light in red channels 
 *  with shade sliding parabola correction and contrast enhancement.
 */  

// Last updated 2019-04-25 // 12:20 PM 

/*  
 * NOTE: Hardcoded minimum size cut off is 59 pixels  
 * NOTE: Assumes directory chosen only has .tif files to be processed (no uppercase for .tif)  
 */

// Uncomment this line for debugging pauses
// waitForUser("debug point 1", "Press anything to continue"); 

var myDir = "";  

macro "Transduction Rate Analysis [1]" {  

    // Prompt user to select a directory containing the images
    myDir = getDirectory("Choose a Directory (all .TIF files will be processed)");	  
    list = getFileList(myDir);  

    print("\\Clear"); // Clear the log window  

    // Clear Summary window  
    if (isOpen("Summary"))   
        selectWindow("Summary");  

    Table.create("Summary"); // Create a new Summary table

    // Process each .tif file in the directory
    for (i = 0; i < list.length; i++) {  
        listelement = toLowerCase(list[i]);  
        if (endsWith(listelement, ".tif")) // Process only .tif files
            overlay1(list[i], myDir, i);  
    }

    // Save the summary data
    selectWindow("Summary");  
    saveAs("TXT", myDir + '\\' + "results" + "\\" + "summary");  
    Table.rename("summary.txt", "Summary");

    print("myDir=", myDir);  
    print("Done!");  
}  

/*************** Function for processing images ***************/  

function overlay1(Imagename, path, n)  {  
    open(Imagename);  

    name1 = File.getName(Imagename); // Get name without path  
    name1stem = substring(name1, 0, lengthOf(name1) - 4);  

    // Create results directory if it doesn't exist
    dest_dir1 = myDir + "results";   
    File.makeDirectory(dest_dir1);  
    if (!File.exists(dest_dir1)) 
        exit("Unable to create directory");  

    print("Processing:", name1);  

    // Split channels
    run("Split Channels");

    // Process transmitted (red) channel
    selectWindow("C1-" + name1);  
    run("Subtract Background...", "rolling=20 light"); 
    run("Enhance Contrast...", "saturated=20"); 
    run("Median...", "radius=4"); 
    makeOval(598, 1289, 80, 80); 
    run("Clear", "slice"); 
    makeRectangle(12, 12, 2012, 2012); 
    run("Crop"); 
    run("Variance...", "radius=6"); 
    setAutoThreshold("Huang dark"); 
    run("Convert to Mask"); 
    run("Fill Holes"); 
    run("Watershed"); 
    run("Erode");  
    run("Analyze Particles...", "size=360-Infinity pixel show=Masks display exclude add");  
    selectWindow("Mask of C1-" + name1); 

    // Process GFP (green) channel
    selectWindow("C2-" + name1);  
    run("Subtract Background...", "rolling=5 sliding");  
    run("Enhance Contrast...", "saturated=2");  
    run("Minimum...", "radius=1");  
    run("Median...", "radius=4");  
    makeOval(598, 1289, 80, 80); 
    run("Clear", "slice"); 
    makeRectangle(12, 12, 2012, 2012); 
    run("Crop"); 
    setAutoThreshold("Li dark");  
    run("Convert to Mask"); 
    run("Fill Holes"); 
    run("Watershed"); 
    run("Erode");  
 
    // Remove any previous ROI
    if (isOpen("ROI Manager")) { 
        selectWindow("ROI Manager"); 
        run("Select All"); 
        roiManager("Deselect"); 
        roiManager("Delete"); 
    }

    run("Analyze Particles...", "size=60-Infinity show=Masks display exclude summarize add");  
    run("Labels...", "color=black font=24");  
    run("Invert LUT"); 
    run("Magenta"); 
    run("RGB Color"); 
    run("Invert");  

    // Close blue channel as it is not used
    close("C3-" + name1);  

    // Create an overlay image by multiplying transmitted and GFP masks
    selectWindow("Mask of C1-" + name1);  
    run("RGB Color");  
    run("Calculator Plus", "i1=[Mask of C1-" + name1 + "] i2=[Mask of C2-" + name1 + "] operation=[Multiply: i2 = (i1*i2) x k1 + k2] k1=1 k2=0 create");  
    selectWindow("Result"); 
    run("8-bit"); 
    setAutoThreshold("Default"); 
    setOption("BlackBackground", true); 
    run("Convert to Mask"); 
    run("Watershed"); 
    run("Analyze Particles...", "size=8-Infinity show=[Bare Outlines] display exclude summarize add"); 

    // Save the final result image
    selectWindow("Result");  
    saveAs("TIF", dest_dir1 + '\\' + name1stem + "-RESULT");  
    close("*");  
}
