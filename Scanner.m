function Scanner()
%    Scanner_Constructor;
    global figHandle
    figHandle = figure('name', '3D Scanner', 'Position', [300, 300, 1200, 500]);
%   figHandle = figure('name', '3D Scanner', 'Position', [300, 300, 1200, 500], 'menubar', 'none');

    Scanner_Constructor;
    
    %set constructor for figure
    set(figHandle, 'deletefcn', {@Scanner_Destructor});
    
    % Get the initilize Data
    if ~exist('setup.xml','file');
        warndlg('The file setup for data calibration not found, so I will load my default data', 'File not found');
        initData = struct('timeOut',0.5, 'threshHold', 100,'squareWidth', 15,...
                    'squareHeight', 15, 'horizontalSquare', 17, 'verticalSquare', 11);
        cv.FileStorage('setup.xml', initData);
    else
        initData = cv.FileStorage('setup.xml');
    end

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
                         
    mnConvertImage = uimenu('Parent', mnLoadData, 'Label', 'Convert Images', ...
                            'callback', {@convertImage_callback});  %Use this function for convert image name, format
    
    mnImportPC  = uimenu('Parent', mnLoadData, 'Label', 'Import Poincloud');
    mnExportPC  = uimenu('Parent', mnLoadData, 'Label', 'Export Pointcloud',...
						 'callback', {@exportPC_callback});
    mnExit      = uimenu('Parent', mnLoadData, 'Label', 'Exit');
    
    % Menu load and calib camera and projector
    mnCalib     = uimenu(figHandle, 'Label', 'Calib system');
    mnNewCalib  = uimenu(mnCalib, 'Label', 'New Calib','callback', {@calibrationCamPro});
    mnLoadCalib = uimenu(mnCalib, 'Label', 'Load calib', ...
                         'callback', {@loadCalibData_callback});
    mnSaveCalib = uimenu(mnCalib, 'Label', 'Save Result');
    
    %//********************PROCESS MENU**************************\\

    % create two button in process panel
    %show point cloud button
    btShowPC = uicontrol('Parent', processPanel,...
                        'string', 'Show Point Cloud', 'Position', [60 160 160 30],...
                        'callback',{@showImage_test, dispFrame});
                        
    % Reconstruct button
    btReconstruct = uicontrol('Parent', processPanel,...
                        'string', 'Reconstruct', 'Position', [60 110 160 30],...
                        'callback',@reconPointCloud_callback);
                        
     % Decode graycode button
    btStartCalculate = uicontrol('Parent', processPanel,...
                        'string', 'Start Calculate', 'Position', [60 60 160 30],...
                        'callback',@startCalculate_callback);

                        
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
              'string', num2str(initData.squareWidth), 'callback', {@squareWidth_callback});
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
    % Square Height               
    uicontrol(calibParameterPanel,'style', 'text', 'string', 'Square Height:',...
              'Position', [5, 130, 100, 20], 'fontsize', 9, ...
              'BackgroundColor','white','horizontalalignment','right');
              
    txtSquareHeight = uicontrol(calibParameterPanel, 'style', 'edit', ....
              'Position', [180, 130, 50, 20], 'fontsize', 9, ...
              'string', num2str(initData.squareHeight),'callback',{@squareHeight_callback});
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
    % Horizontal Squares               
    uicontrol(calibParameterPanel,'style', 'text', 'string', 'Hor Squares:',...
              'Position', [5, 95, 100, 20], 'fontsize', 9, ...
              'BackgroundColor','white','horizontalalignment','right');
              
    txtHorSquare = uicontrol(calibParameterPanel, 'style', 'edit', ....
              'Position', [180, 95, 50, 20], 'fontsize', 9, ...
              'string', num2str(initData.horizontalSquare),'callback',{@horizontalSquare_callback});              
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Veritcal Squares                    
    uicontrol(calibParameterPanel,'style', 'text', 'string', 'Ver Squares:',...
              'Position', [5, 60, 100, 20], 'fontsize', 9, ...
              'BackgroundColor','white','horizontalalignment','right');
    
    txtVerSquare = uicontrol(calibParameterPanel, 'style', 'edit', ....
              'Position', [180, 60, 50, 20], 'fontsize', 9, ...
              'string', num2str(initData.verticalSquare),'callback',{@verticalSquare_callback});
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Thresh hold                
    uicontrol(calibParameterPanel,'style', 'text', 'string', 'Thresh hold:',...
              'Position', [5, 25, 100, 20], 'fontsize', 9,...
              'BackgroundColor','white','horizontalalignment','right');
    
    txtThreshHold = uicontrol(calibParameterPanel, 'style', 'edit', ....
              'Position', [180, 25, 50, 20], 'fontsize', 9, ...
              'string',num2str(initData.threshHold), 'callback', {@threshHold_callback});
    %******************************************************************
    
    %------------------ CAMERA CAPTURE -----------------------
    uicontrol(cameraCapturePanel,'style', 'text', 'string', 'Time out:',...
              'Position', [5, 180, 100, 20], 'fontsize', 9, ...
              'BackgroundColor','white','horizontalalignment','right');
    
    txtCameraTimeOut = uicontrol(cameraCapturePanel, 'style', 'edit', ....
                  'Position', [120, 180, 50, 20], 'fontsize', 9, ...
                  'string', num2str(initData.timeOut),'callback',{@timeOut_callback});     

    uicontrol(cameraCapturePanel,'style', 'text', 'string', 's',...
              'Position', [170, 180, 10, 20], 'fontsize', 11, ...
              'BackgroundColor','white','horizontalalignment','right');				  
                     
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
    setappdata(0, 'grayVer', figHandle);
    
    % Initilize for phase shift image
    setappdata(0, 'wrappedPhase', figHandle);
    setappdata(0, 'unWrappedPhase', figHandle);
	
	% Initilize data for calibration when reconstruct
	setappdata(0, 'calibData', figHandle);
	
	% Get the initilize thresh hold value
	setappdata(figHandle, 'grayThreshHold', 100/255);
    
    addpath('./Modules/Camera');
    addpath('./Modules/DisplayResult');
    addpath('./Modules/GrayCode');
    addpath('./Modules/GrayCode/util');
    addpath('./Modules/PhaseShift');
    addpath('./Modules/Calibration');
    addpath('./Modules/IO');
end

function Scanner_Destructor(src, evnt)
    rmpath('./Modules/Camera');
    rmpath('./Modules/DisplayResult');
    rmpath('./Modules/GrayCode');
    rmpath('./Modules/GrayCode/util');
    rmpath('./Modules/PhaseShift');
    rmpath('./Modules/Calibration');
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%---EDIT TEXT FOR CALIBRATION---%%%%%%%%%%%%%%%%%%%%%%

% the width of rectangle to calib
function squareWidth_callback(src, evnt)
    squareWidth = get(src,'string');
	if isempty(squareWidth)
		errordlg('You cannot leave the blank value for thresh hold', 'Error Data');
		return;
	else	
%		setappdata(figHandle, 'squareWidth', squareWidth);
%   update parameter to file 
        tempData = cv.FileStorage('setup.xml');
        tempData.squareWidth = str2double(squareWidth);
        cv.FileStorage('setup.xml', tempData);
	end
end

% the height of rectangle to calib
function squareHeight_callback(src, evnt)
    squareHeight = get(src,'string');
	if isempty(squareHeight)
		errordlg('You cannot leave the blank value for thresh hold', 'Error Data');
		return;
	else	
%		setappdata(figHandle, 'squareHeight', squareHeight);
%   update parameter to file 
        tempData = cv.FileStorage('setup.xml');
        tempData.squareHeight= str2double(squareHeight);
        cv.FileStorage('setup.xml', tempData);
	end
end

% Number of rectangles follow the horizontal
function horizontalSquare_callback(src, evnt)
    horizontalSquare = get(src,'string');
	if isempty(horizontalSquare)
		errordlg('You cannot leave the blank value for thresh hold', 'Error Data');
		return;
	else	
%		setappdata(figHandle, 'horizontalSquare', horizontalSquare);
%   update parameter to file 
        tempData = cv.FileStorage('setup.xml');
        tempData.horizontalSquare = str2double(horizontalSquare);
        cv.FileStorage('setup.xml', tempData);
	end
end

% Number of rectangles follow the vertical
function verticalSquare_callback(src, evnt)
    global figHandle
    verticalSquare = get(src,'string');
	if isempty(verticalSquare)
		errordlg('You cannot leave the blank value for thresh hold', 'Error Data');
		return;
	else	
%		setappdata(figHandle, 'verticalSquare', verticalSquare);
%   update parameter to file 
        tempData = cv.FileStorage('setup.xml');
        tempData.verticalSquare = str2double(verticalSquare);
        cv.FileStorage('setup.xml', tempData);
	end
end

function timeOut_callback(src, evnt)
    timeOut = get(src,'string');
	if isempty(timeOut)
		errordlg('You cannot leave the blank value for thresh hold', 'Error Data');
		return;
	else	
%		setappdata(figHandle, 'verticalSquare', verticalSquare);
%   update parameter to file 
        tempData = cv.FileStorage('setup.xml');
        tempData.timeOut = str2double(timeOut);
        cv.FileStorage('setup.xml', tempData);
	end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%----Convert Images----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function convertImage_callback(src, evnt)
    folderPath = uigetdir('/media/duonghung/Data/IMAGE','Open Image folder to convert');
    if (folderPath == 0)
        return;
    end
    
    
end

%%%%%%%%%%%%%%%%%%%%---CALLBACK FUNCTIONS FOR EDIT TEXT---%%%%%%%%%%%%%%%%%%%%
function threshHold_callback(src, evnt)
	global figHandle
	temp = (get(src,'string'));
	if isempty(temp)
		errordlg('You cannot leave the blank value for thresh hold', 'Error Data');
		return;
	else	
		grayThreshHold = str2double(temp)/255;
		setappdata(figHandle, 'grayThreshHold', grayThreshHold);
        
        %   update parameter to file 
        tempData = cv.FileStorage('setup.xml');
        tempData.threshHold = num2str(temp);
        cv.FileStorage('setup.xml', tempData);
	end
end	


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%----true function----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function loadImage_callback(src, evnt)
    global figHandle
    [grayIM, phaseIM] = loadImage();
    setappdata(figHandle, 'grayIM', grayIM);
    setappdata(figHandle, 'phaseIM', phaseIM);
end

function startCalculate_callback(src, evnt)
    global figHandle
    
    %Calculate for phase shift images
    [wPhi, uPhi] = calWrappedPhase(figHandle);
    if (isempty(wPhi) || isempty(uPhi))
        return;
    else
        setappdata(figHandle,'wrappedPhase',wPhi);
        setappdata(figHandle,'unWrappedPhase',uPhi);
    end
    
    %Calculate for gray coded images
    grayIM = getappdata(figHandle, 'grayIM');
    if isempty(grayIM)
        return;
    else
		grayThreshHold = getappdata(figHandle, 'grayThreshHold');
		if (isempty(grayThreshHold) || grayThreshHold < 0) 
			grayThreshHold = 0.5;
		end
		
        decodedData = decodeGrayIM(grayIM, grayThreshHold);
        setappdata(figHandle, 'grayHor', decodedData{1,2});
        setappdata(figHandle, 'grayVer', decodedData{1,1});
        grayHor = decodedData{1,2};
        grayVer = decodedData{1,1};
    end

    % Display results for both phase shift and graycoded
    if (~isempty(wPhi) || ~isempty(uPhi) || ~isempty(decodecData))
        dispProImageGUI(grayHor, grayVer, wPhi, uPhi);
    end
end


%%%%%%%%%%%%%%%%%%% Calibration callback %%%%%%%%%%%%%%%%%%%
function loadCalibData_callback(src, evnt)
   global figHandle
   [calibFile, calibDataDir] = uigetfile({'*.yml';'*.xml'}, 'Select file calibrartion data',...
                                         '/media/duonghung/Data/IMAGE');
   if isequal(calibFile, 0)
      return;
   end
  
   try
      calibData = cv.FileStorage([calibDataDir calibFile]);
%      show_ketqua(S);
      msgbox('Read calib data sucsessfully','Done');
      setappdata(figHandle, 'calibData', calibData);
   catch exception
      errordlg('Error when load calib data, please check opencv toolbox', 'Error load calibration data');
	  setappdata(figHandle, 'calibData', []);
      disp(exception);
   end
end


function reconPointCloud_callback(src, evnt)
    global figHandle
	
	calibData = getappdata(figHandle, 'calibData');
	
	if isempty(calibData)
		errordlg('Please make sure you have loaded the calibration data', 'Error Calibration data not found');
		setappdata(figHandle, 'pointCloud', []);
		return;
	end
    
    grayHor = getappdata(figHandle, 'grayHor');
    grayVer = getappdata(figHandle, 'grayVer');
    
    if isempty(grayHor) || isempty(grayVer)
        errordlg('Please make sure you have loaded gray images and decoded images before this step',...
                  'Error Data Empty');
        return;
    end
    set(figHandle, 'pointer', 'watch');
    fwait = waitWindow();
    pointCloud = reconstructGrayCode(figHandle);
	setappdata(figHandle, 'pointCloud', pointCloud);
    set(figHandle, 'pointer', 'arrow');
    delete(fwait);
	
end

%%%%%%%%%et%%% POINCLOUD MENU CALLBACK %%%%%%%%%%%%%%%%%et
function exportPC_callback(src, evnt)
	global figHandle
	try
		pointCloud = getappdata(figHandle, 'pointCloud');
		pointCloud = pointCloud';
		x = pointCloud(1:end, 1);
		y = pointCloud(1:end, 2);
		z = pointCloud(1:end, 3);
		
		vertex = struct('x', x, 'y', y, 'z', z);
		pcOutput = struct('vertex', vertex);
        disp('Saving pointcloud ...');
        ply_write(pcOutput, './OutputData/PointCloud.ply', 'binary_little_endian');
        disp('+ Done');
%		scatter3(x, y, z);
		
	catch ex
		disp(ex)
		errordlg('The reconstruction process was failed, please check all again.', 'Error Data');
		return;
	end	
	
end