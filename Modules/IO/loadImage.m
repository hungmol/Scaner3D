%This function is used for load graycoded and phase shift images 
%

%Author: Duong Hong Hung
%Created: 12/2016 

function [grayIM, phaseIM] = loadImage()
  
    numOfGrayIM = 42;
    numOfPhaseIM = 3;
    grayIM = cell(1, numOfGrayIM);
    phaseIM = cell(1,numOfPhaseIM); 
%     /user4000223/DATA/IMAGE');
    folderPath = uigetdir('/media/duonghung/Data/IMAGE','Open Image folder');
    if (folderPath == 0)
        return;
    end
    
    % Check folder image exist
    str1 = strcat(folderPath,'/GrayCode');
    str2 = strcat(folderPath,'/PhaseShift');
    
    if (~exist(str1, 'dir'))
        errordlg('Cannot find graycoded image folder', 'Load image error');
        return;
    elseif (~exist(str2, 'dir'))
        errordlg('Cannot find phase shift image folder', 'Load image error');
        return;
    end       
    
    % Load image
    % graycode   
    global abort_waitbar;
    abort_waitbar = false;
    
    %----------------- Load Graycoded Images-------------------
    imProBar = waitbar(0, 'Initilize', 'Name', 'Loading graycode images',...
                           'CreateCancelBtn', @cancel_fnc);
                           
    grayMatrix = inv([1.0 0.956 0.621; 1.0 -0.272 -0.647; 1.0 -1.106 1.703]);
    indexGrayConvert = grayMatrix(1,:)';
    
    try    
        for i = 1:1:numOfGrayIM
            if (abort_waitbar == true)
                return;
            end
            
            if (i == 1 || i == 2)
                grayIM{1,i} = imread([str1, '/', num2str(i, '%0.02d'), '.bmp']);
            else
            
                temp = imread([str1, '/', num2str(i, '%0.02d'), '.bmp']);
                grayIM{1,i} = imlincomb(indexGrayConvert(1), temp(:,:,1),...
                                        indexGrayConvert(2), temp(:,:,2),...
                                        indexGrayConvert(3), temp(:,:,3),'double');
            end
            
            waitbar(i/numOfGrayIM, imProBar, ['Loading ...', num2str(round(i/numOfGrayIM*100)), '%']);
        end
    catch ex
        errordlg(['Check file format, make sure have enough images or has right name,',...
                  'Program only support bmp extension for graycode images'],'Loading image error!');
        disp(ex);
    end   
    delete(imProBar);
    
    %----------------------Load Phase shift Images--------------------    
    imProPhaseBar = waitbar(0, 'Initilize', 'Name', 'Loading phase shift image ...', 'MenuBar', 'none');
    try
        for i = 1:1:numOfPhaseIM
            phaseIM{1,i} = single(rgb2gray(imread([str2, '/phase', num2str(i), '.jpg'])));
            waitbar(i/numOfPhaseIM, imProPhaseBar); 
        end
    catch ex
        errordlg(['Check file format, make sure have enough images or has right name,',...
                  'Program only support .jpg extension for phase shift images'],'Loading image error!');
        disp(ex);
    end
    delete(imProPhaseBar)
        
end


function cancel_fnc(src, evnt)
    global abort_waitbar
    abort_waitbar = true;
end