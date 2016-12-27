%This function is used for load graycoded and phase shift images 
%

%Author: Duong Hong Hung
%Created: 12/2016 

function [grayIM, phaseIM] = loadImage()
       
    folderPath = uigetdir('/media/user4000223/DATA/IMAGE');
    if (folderPath == 0)
        return;
    endif
    
    % Check folder image exist
    str1 = strcat(folderPath,'/GrayCode');
    str2 = strcat(folderPath,'/PhaseShift');
    
    if (~exist(str1, "dir"))
        errordlg("Cannot find graycoded image folder", "Load image error");
    elseif (~exist(str2, "dir"))
        errordlg("Cannot find phase shift image folder", "Load image error");
    endif        
    
    % Load image
    % graycode
    numOfGrayIM = 42;
    grayIM = cell(1, numOfGrayIM);
    
    global abort;
    abort = false;
    
    %----------------- Load Graycoded Images-------------------
    imProBar = waitbar(0, 'Loading graycode images ...', "menubar", "none",...
                           'createcancelbtn', {@cancel_fnc, abort});
                           
    grayMatrix = inv([1.0 0.956 0.621; 1.0 -0.272 -0.647; 1.0 -1.106 1.703]);
    indexGrayConvert = grayMatrix(1,:)';
    
    try    
        for i = 1:1:numOfGrayIM
            if (abort == true)
                break;
            endif
            
            if (i == 1 || i == 2)
                grayIM{1,i} = imread([str1, '/', num2str(i, '%0.02d'), '.bmp']);
            else
            
                temp = imread([str1, '/', num2str(i, '%0.02d'), '.bmp']);
                grayIM{1,i} = imlincomb(indexGrayConvert(1), temp(:,:,1),...
                                        indexGrayConvert(2), temp(:,:,2),...
                                        indexGrayConvert(3), temp(:,:,3),'double');
            endif
            
            waitbar(i/numOfGrayIM, imProBar, ['Loading graycode images ...', num2str(round(i/numOfGrayIM*100)), '%']);
        endfor
    catch ex
        errordlg(['Check file format, make sure have enough images or has right name,',...
                  'Program only support bmp extension for graycode images'],'Loading image error!');
        disp(ex);
    end   
    close(imProBar);
    
    %----------------------Load Phase shift Images--------------------
    numOfPhaseIM = 3;
    phaseIM = cell(1,numOfPhaseIM); 
    imProPhaseBar = waitbar(0, 'Loading phase shift image ...', 'menubar', 'none');
    try
        for i = 1:1:numOfPhaseIM
            phaseIM{1,i} = single(rgb2gray(imread([str2, '/phase', num2str(i), '.jpg'])));
            waitbar(i/numOfPhaseIM, imProPhaseBar); 
        endfor
    catch ex
        errordlg(['Check file format, make sure have enough images or has right name,',...
                  'Program only support .jpg extension for phase shift images'],'Loading image error!');
    end
    close(imProPhaseBar)
        
endfunction 


function cancel_fnc(abort)
    global abort
    abort = true;
endfunction