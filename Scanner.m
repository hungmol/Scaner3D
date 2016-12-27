function Scanner()
    Scanner_Constructor;
    global figHandle
%    figHandle = figure('name', '3D Scanner', 'Position', [300, 300, 1200, 500], 'menubar', 'none');
    figHandle = figure('name', '3D Scanner', 'Position', [300, 300, 1200, 500]);
    
    %set constructor for figure
    set(figHandle, 'createfcn', {@Scanner_Constructor});
    set(figHandle, 'deletefcn', {@Scanner_Destructor});

    %add main panel
    showPanel = uipanel('Title', '', 'Position', [0.5, 0, 0.5, 0.99],...
                        'BackgroundColor', [0.25, 0.1, 0.25]);
    %create axes
    dispFrame = axes('Parent', showPanel, 'Position', [0.01, 0.01, 0.98, 0.98]);
    set(dispFrame,'Visible','on');
    
    controlPanel = uipanel('Title','', 'Position',[0,0.0,0.5, 0.99],...
                        'BackgroundColor', [0.25, 0.1, 0.25]);
                        
    cameraCapturePanel = uipanel('Parent', controlPanel, 'Title', 'Camera capture',...
                        'Position', [0.01, 0.01, 0.48, 0.48],...
                        'BackgroundColor','white');
                        
    processPanel = uipanel('Parent', controlPanel, 'Title', 'Process',...
                        'Position', [0.01, 0.51, 0.48, 0.48],...
                        'BackgroundColor','white');
                        
    cameraTweakPanel = uipanel('Parent', controlPanel, 'Title', 'Camera Tweak',...
                        'Position', [0.5, 0.51, 0.49, 0.48],...
                        'BackgroundColor','white'); 
    
    calibParameterPanel = uipanel('Parent', controlPanel, 'Title', 'Calib parameter',...
                        'Position', [0.5, 0.01, 0.49, 0.48],...
                        'BackgroundColor','white'); 
                        
    %//*****************Create menu*******************
    
    % menu load data
    mnLoadData  = uimenu(figHandle, 'Label', 'Data');
    mnLoadImage = uimenu('Parent', mnLoadData, 'Label', 'Load Images',...
                         'callback', {@loadImage_callback}); %choose the folder for graycode and phaseshift
    
    mnImportPC  = uimenu('Parent', mnLoadData, 'Label', 'Import Poincloud');
    mnExportPC  = uimenu('Parent', mnLoadData, 'Label', 'Export Pointcloud');
    mnExit      = uimenu('Parent', mnLoadData, 'Label', 'Exit');
    
    % Menu load and calib camera and projector
    mnCalib     = uimenu(figHandle, 'Label', 'Calib system');
    mnNewCalib  = uimenu(mnCalib, 'Label', 'New Calib');
    mnLoadCalib = uimenu(mnCalib, 'Label', 'Load calib');
    mnSaveCalib = uimenu(mnCalib, 'Label', 'Save Result');
    
    %//********************PROCESS MENU**************************\\

    % create two button in process panel
    %show point cloud button
    btShowPC = uicontrol('Parent', processPanel,...
                        'string', 'Show Point Cloud', 'Position', [60 170 160 30],...
                        'callback',{@showImage_test, dispFrame});
                        
    % Reconstruct button
    btReconstruct = uicontrol('Parent', processPanel,...
                        'string', 'Reconstruct', 'Position', [60 130 160 30],...
                        'callback',@hello);
                        
     % Decode graycode button
    btDecodeGray = uicontrol('Parent', processPanel,...
                        'string', 'Decode graycode', 'Position', [60 70 160 30],...
                        'callback',@decodeGray_callback);
    
    % Decode graycode button
    btUnwrapPhase = uicontrol('Parent', processPanel,...
                        'string', 'Unwrap Phase', 'Position', [60 30 160 30],...
                        'string', 'Unwrap Phase', 'Position', [60 30 160 30],...
                        'callback',@calWrappedPhase_callback);
                        
     %//*****************CAMERA TWEAK*******************
    %Create slider in camera tweak
    %static text constrast
    uicontrol(cameraTweakPanel,'style', 'text', 'string', 'Constrast',...
              'Position', [5, 150, 100, 20], 'fontsize', 9,...
              'BackgroundColor','white','horizontalalignment','right');
              
    %%%%% Make slider constrast
    slConstrast = uicontrol(cameraTweakPanel, 'style', 'slider', ...
                        'Position', [130, 150, 140, 20], 'Enable', 'on',...
                        'Value', 50, 'min', 0, 'max', 100);
                %******************                    
    %static text white balance              
    uicontrol(cameraTweakPanel,'style', 'text', 'string', 'White Balance',...
              'Position', [5, 110, 100, 20], 'fontsize', 9,...
              'BackgroundColor','white','horizontalalignment','right');
              
    %%%%% Make slider white balance              
    slWhiteBalance = uicontrol(cameraTweakPanel, 'style', 'slider', ...
                        'Position', [130, 110, 140, 20], 'Enable', 'on',...
                        'Value', 50, 'min', 0, 'max', 100);          
                %****************** 
    %static text Exposure  
    uicontrol(cameraTweakPanel,'style', 'text', 'string', 'Exposure',...
              'Position', [5, 70, 100, 20], 'fontsize', 9,...
              'BackgroundColor','white','horizontalalignment','right');
    
    %Make slider Exposure    
    slExposure = uicontrol(cameraTweakPanel, 'style', 'slider', ...
                        'Position', [130, 70, 140, 20], 'Enable', 'on',...
                        'Value', 50, 'min', 0, 'max', 100);
    %***************************************************
    
    %%*************************CALIBRATION PARAMETER*******************
    
    %Static text
    % Square Width
    uicontrol(calibParameterPanel,'style', 'text', 'string', 'Square Width:',...
              'Position', [5, 165, 100, 20], 'fontsize', 9,...
              'BackgroundColor','white','horizontalalignment','right');
              
    txtSquareWidth = uicontrol(calibParameterPanel, 'style', 'edit', ....
              'Position', [180, 165, 50, 20], 'fontsize', 9, ...
              'string', '15');
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
    % Square Height               
    uicontrol(calibParameterPanel,'style', 'text', 'string', 'Square Height:',...
              'Position', [5, 130, 100, 20], 'fontsize', 9, ...
              'BackgroundColor','white','horizontalalignment','right');
              
    txtSquareHeight = uicontrol(calibParameterPanel, 'style', 'edit', ....
              'Position', [180, 130, 50, 20], 'fontsize', 9, ...
              'string', '15');
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
    % Horizontal Squares               
    uicontrol(calibParameterPanel,'style', 'text', 'string', 'Hor Squares:',...
              'Position', [5, 95, 100, 20], 'fontsize', 9, ...
              'BackgroundColor','white','horizontalalignment','right');
              
    txtHorSquare = uicontrol(calibParameterPanel, 'style', 'edit', ....
              'Position', [180, 95, 50, 20], 'fontsize', 9, ...
              'string', '0');              
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Veritcal Squares                    
    uicontrol(calibParameterPanel,'style', 'text', 'string', 'Ver Squares:',...
              'Position', [5, 60, 100, 20], 'fontsize', 9, ...
              'BackgroundColor','white','horizontalalignment','right');
    
    txtVerSquare = uicontrol(calibParameterPanel, 'style', 'edit', ....
              'Position', [180, 60, 50, 20], 'fontsize', 9, ...
              'string', '0');
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Thresh hold                
    uicontrol(calibParameterPanel,'style', 'text', 'string', 'Thresh hold:',...
              'Position', [5, 25, 100, 20], 'fontsize', 9,...
              'BackgroundColor','white','horizontalalignment','right');
    
    txtThreshHold = uicontrol(calibParameterPanel, 'style', 'edit', ....
              'Position', [180, 25, 50, 20], 'fontsize', 9, ...
              'string', '100');
    %******************************************************************
    
    %------------------ CAMERA CAPTURE -----------------------
    uicontrol(cameraCapturePanel,'style', 'text', 'string', 'Thresh hold:',...
              'Position', [5, 180, 100, 20], 'fontsize', 9, ...
              'BackgroundColor','white','horizontalalignment','right');
    
    txtCameraCapture = uicontrol(cameraCapturePanel, 'style', 'edit', ....
                  'Position', [120, 180, 50, 20], 'fontsize', 9, ...
                  'string', '100');                
                     
    %show point cloud button
    btCollectData = uicontrol('Parent', cameraCapturePanel,...
                        'string', 'Collect Data', 'Position', [60, 120 160 30],...
                        'callback',@hello);           
    
    btPreviewCamera = uicontrol('Parent', cameraCapturePanel,...
                        'string', 'Preview Camera', 'Position', [60, 60 160 30],...
                        'callback',@hello); 
    %---------------------------------------------------------
end

function Scanner_Constructor(src, evnt) 
    global figHandle
    
    % Initilize for gray code image    
    setappdata(0, 'grayHor', figHandle);
    setappdata( 0, 'grayVer', figHandle);
    
    % Initilize for phase shift image
    setappdata(0, 'wrappedPhase', figHandle);
    setappdata(0, 'unWrappedPhase', figHandle);
    
    addpath('./Modules/Camera');
    addpath('./Modules/DisplayResult');
    addpath('./Modules/GrayCode');
    addpath('./Modules/PhaseShift');
    addpath('./Modules/IO');
end

function Scanner_Destructor(src, evnt)
    rmpath('./Modules/Camera');
    rmpath('./Modules/DisplayResult');
    rmpath('./Modules/GrayCode');
    rmpath('./Modules/PhaseShift');
    rmpath('./Modules/IO');
    close all;
    clear all;
end

%%%%%%%%%%%%%%%%%%%%---CALLBACK FUNCTIONS---%%%%%%%%%%%%%%%%%%%%
function hello
    disp('Hello world');
end
    
function showImage_test(src, evnt, handles)
    im = imread('./image/phase1.jpg');
    imshow(im, 'Parent', handles);
end

%true function
function loadImage_callback(src, evnt)
    global figHandle
    [grayIM, phaseIM] = loadImage();
    setappdata(figHandle, 'grayIM', grayIM);
    setappdata(figHandle, 'phaseIM', phaseIM);
end

function calWrappedPhase_callback(src, evnt)
    global figHandle
    [wPhi, uPhi] = calWrappedPhase(figHandle);
    setappdata(figHandle,'wrappedPhase',wPhi);
    setappdata(figHandle,'unWrappedPhase',uPhi);
    grayHor = getappdata(figHandle, 'grayHor');
    grayVer = getappdata(figHandle, 'grayVer');
    dispProImageGUI(grayHor, grayVer, wPhi, uPhi);
end

function decodeGray_callback(src, evnt)
    global figHandle

end
