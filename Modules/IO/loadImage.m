%This function is used for load graycoded and phase shift images 
%

%Author: Duong Hong Hung
%Created: 12/2016 

function loadImage()
    
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
    imProBar = waitbar(0,'Loading graycode Images ...');
    for i = 1:1:numOfGrayIM
        grayIM{1,i} = rgb2gray(imread([str1, '/', num2str(i, '%0.02d'), '.bmp']));
        waitbar(i/numOfGrayIM);
    endfor
    
    close imProBar;
        
endfunction 