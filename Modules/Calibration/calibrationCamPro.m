% This function is main gui to calibration camera

% This function can load image to calibration 

function calibrationCamPro()
    global mainFig
    mainFig = figure('Name', 'Calibration Tool', 'Position', [300, 300, 1200, 500], 'menubar', 'none');
    
    imagePanel = uipanel('Parent', mainFig, 'Position', [0.5, 0.0, 0.5, 0.98], 'Title', 'RGB Image');
    axesColorImage = axes('Parent', imagePanel, 'Position', [0.01, 0.01, 0.98, 0.98]);
    
    decodePanel = uipanel('Parent', mainFig, 'Position', [0.0, 0.5, 0.5, 0.5]);
    decodeHor = uipanel('Parent', decodePanel, 'Position', [0.0, 0.0, 0.5, 0.98], 'Title', 'Decoded Horizontal');
    decodeVer = uipanel('Parent', decodePanel, 'Position', [0.5, 0.0, 0.5, 0.98], 'Title', 'Decoded Vertical');
    
    axesDecodeHor = axes('Parent', decodeHor, 'Position', [0.0, 0.01, 0.98, 0.98]);
    axesDecodeVer = axes('Parent', decodeVer, 'Position', [0.0, 0.01, 0.98, 0.98]);
    
    controlPanel = uipanel('Parent', mainFig, 'Position', [0.0, 0.0, 0.5, 0.5], 'Title', 'Control Panel');
    
    btLoadDir = uicontrol('Parent', controlPanel, 'Position', [20, 180, 150, 30], 'string', 'Choose directory', ...
                          'callback', {@loadImage_callback});
    
   
end

function calibrationCamPro_constructor()
    global mainFig
    
    calibDir = uigetdir('/media/duonghung/Data/IMAGE','Open Image folder');
    if (calibDir == 0)
        return;
    end
    
end

function calibrationCamPro_destructor()
    
end

function loadImage_callback(src, evnt)
   global mainFig
   calibDir = uigetdir('/media/duonghung/Data/IMAGE', 'Open gray image'); 
   if (calibDir == 0)
        return;
   end
    
   listOfAttribute = dir(calibDir);
   listOfDir = [listOfAttribute.isdir];
   
   % Extract only that are directories 
   listOfDir = listOfAttribute(listOfDir);
   for i = 3:length(listOfDir)
       outputDir(i - 2).name = [calibDir, '/', listOfDir(i).name];
       fprintf('Sub folder #%d = %s \n', i, outputDir(i - 2).name);
   end
   
   loadImageSequence(outputDir, 100/255);
   
 end