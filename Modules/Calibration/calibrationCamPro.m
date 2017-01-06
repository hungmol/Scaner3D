% This function is main gui to calibration camera

% This function can load image to calibration 

function calibrationCamPro()
    global mainFig
    mainFig = figure('Name', 'Calibration Tool', 'Position', [300, 300, 1200, 500], 'menubar', 'none');
    
    imagePanel = uipanel('Parent', mainFig, 'Position', [0.5, 0.0, 0.98, 1], 'Title', 'RGB Image',...
                         'BackgroundColor', [0.25, 0.1, 0.25], ...
                         'ForegroundColor', 'white');
    axesColorImage = axes('Parent', imagePanel, 'Position', [0.01, 0.01, 0.98, 0.98]);
    
    decodePanel = uipanel('Parent', mainFig, 'Position', [0.0, 0.5, 0.5, 0.5],'BackgroundColor', [0.25, 0.1, 0.25]);
    
    decodeHor = uipanel('Parent', decodePanel, 'Position', [0.0, 0.0, 0.5, 0.98],...
                        'Title', 'Decoded Horizontal', 'BackgroundColor', [0.25, 0.1, 0.25],...
                        'ForegroundColor', 'white');
                        
    decodeVer = uipanel('Parent', decodePanel, 'Position', [0.5, 0.0, 0.5, 0.98],...
                        'Title', 'Decoded Vertical', 'BackgroundColor', [0.25, 0.1, 0.25],...
                        'ForegroundColor', 'white');
    
    axesDecodeHor = axes('Parent', decodeHor, 'Position', [0.0, 0.01, 0.98, 0.98]);
    axesDecodeVer = axes('Parent', decodeVer, 'Position', [0.0, 0.01, 0.98, 0.98]);
    
    controlPanel = uipanel('Parent', mainFig, 'Position', [0.0, 0.0, 0.5, 0.5], 'Title', 'Control Panel',...
                           'BackgroundColor', [0.25, 0.1, 0.25], ...
                           'ForegroundColor', 'white');
    
    btLoadDir = uicontrol('Parent', controlPanel, 'Position', [20, 150, 150, 30], 'string', 'Choose directory', ...
                          'callback', {@loadImage_callback});
    
    % Create next and previous button
    btPrevImage = uicontrol('Parent', controlPanel, 'Position', [210, 200, 80, 30], 'string', 'Previous',...
                            'callback',{@btNext_callback});
    btNextImage = uicontrol('Parent', controlPanel, 'Position', [300, 200, 80, 30], 'string', 'Next',...
                            'callback',{@btPrev_callback});
    
    btDecodeImage = uicontrol('Parent', controlPanel, 'Position', [20, 100, 150, 30],...
                              'string', 'Decode Image', 'callback', {@decodeImage_callback});
   
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

%%%%%%%%%%%%%%%%%%%%%%%%---- CALLBACK FUNCTION ------%%%%%%%%%%%%%%%%%%%
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
   
   initData = cv.FileStorage('setup.xml');
   
   graySequence = loadImageSequence(outputDir, initData.threshHold);
   setappdata(mainFig, 'graySequence', graySequence);
   
end
 
function decodeImage_callback(src, evnt)
    %        %%%%%%%%%%%%%%----Decode image----%%%%%%%%%%%%%%%%%
    decodedTemp = decodeGrayIM(grayIM, grayThresh);
    decodeOutput{j, 1} = decodedTemp{1, 1};
    decodeOutput{j, 2} = decodedTemp{1, 2};
end
 
function btNext_callback(src, evnt)
   global mainFig
   graySeq = getappdata(mainFig, 'graySequence');
   
end
 
function btPrev_callback(src, evnt)
   global mainFig 
   graySeq = getappdata(mainFig, 'graySequence');
   
end