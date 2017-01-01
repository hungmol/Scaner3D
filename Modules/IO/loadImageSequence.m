% This function use for load sequence for graycode image

function [decodedOutput] = loadImageSequence(listOfDir, grayThresh)
    decodedOuput = {};
    numOfGrayIM = 42;
   
    if (nargin < 1)
        errordlg('Not enough input argument', 'Error Argument');
        return;
    end
    
    decodedOutput = cell(length(listOfDir), 2);
    grayIM = cell(1, numOfGrayIM);
    
    global abort_waitbar;
    abort_waitbar = false;
    
    %----------------- Load Graycoded Images-------------------                         
    grayMatrix = inv([1.0 0.956 0.621; 1.0 -0.272 -0.647; 1.0 -1.106 1.703]);
    indexGrayConvert = grayMatrix(1,:)';
    
    for j = 1:length(listOfDir)
        imProBar = waitbar(0, 'Initilize', 'Name', 'Loading graycode images',...
                           'CreateCancelBtn', {@cancel_fnc});
        try    
            str = listOfDir(j).name;
            for i = 1:1:numOfGrayIM
                if (abort_waitbar == true)
                    return;
                end
                
                if (i == 1 || i == 2)
                    grayIM{1,i} = imread([str, '/', num2str(i, '%0.02d'), '.jpg']);
                else
                
                    temp = imread([str, '/', num2str(i, '%0.02d'), '.jpg']);
                    grayIM{1,i} = imlincomb(indexGrayConvert(1), temp(:,:,1),...
                                            indexGrayConvert(2), temp(:,:,2),...
                                            indexGrayConvert(3), temp(:,:,3),'double');
                end
                
                waitbar(i/numOfGrayIM, imProBar, ['Loading ...', num2str(round(i/numOfGrayIM*100)), '%']);
            end
         catch ex
            errordlg(['Check file format, make sure have enough images or has right name,',...
                      'Program only support jpg extension for graycode images'],'Loading image error!');
            disp(ex);
            return;
        end
        delete(imProBar);   
        %--------------------------------------------------------------------------------------
        
        %%%%%%%%%%%%%%----Decode image----%%%%%%%%%%%%%%%%%
        decodedTemp = decodeGrayIM(grayIM, grayThresh);
        decodeOutput{j, 1} = decodedTemp{1, 1};
        decodeOutput{j, 2} = decodedTemp{1, 2};
    end
end

function cancel_fnc(src, evnt)
    global abort_waitbar
    abort_waitbar = true;
end