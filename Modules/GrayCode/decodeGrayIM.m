% This function use for decode gray code patterns

% Author: Duong Hong Hung
% Created: 12/2016


function [decodedData] = decodeGrayIM(grayIM, grayThresh)
    % Estimate column/row label for each pixel (i.e., decode Gray codes).
    % Note: G{j,k} is the estimated Gray code for "orientation" j and camera k.
    %       D{j,k} is the integer column/row estimate.
    %       M{j,k} is the per-pixel mask (i.e., pixels with enough contrast).
    numOfPattern = 42;
    Group = cell(1, 2);
    decodedData = cell(1, 2);
    Mask = cell(1, 2);
    
    % Check images input
    if isempty(grayIM)
        errordlg('Please load gray code images before do this step', 'Decode Error');
        return;
    end
    
    cam_width = size(grayIM{1,1}(:,:,1), 2);
    cam_height = size(grayIM{1,1}(:,:,1), 1);
    proj_width = 1024;
    proj_height = 768;
    
    [~,offset] = graycode(proj_width, proj_height);
   
    frameIdx = 3;    
    for i = 1:2
        if (i == 1)
            h = waitbar(0, 'Initilize', 'Name', 'Vertical decode');
        elseif (i == 2)
            h = waitbar(0, 'Initilize', 'Name', 'Horizontal decode');
        end
        
        Group{1, i} = zeros(cam_height,cam_width,(numOfPattern - 2)/4,'uint8');
        Mask{1, i} = false(cam_height,cam_width);
        for j = 1:1:(numOfPattern - 2)/4
            % Separate two type of gray image
            grayA = grayIM{1, frameIdx};
            frameIdx = frameIdx + 1;
            grayB = grayIM{1, frameIdx};
            frameIdx = frameIdx + 1;
            
            % Eliminate all pixels that do not exceed contrast threshold.
            Mask{1, i}(abs(grayA-grayB) > 255*grayThresh) = true;
            
            % Estimate current bit of Gray code from image pair.
            bitPlane = zeros(cam_height,cam_width,'uint8');
            bitPlane(grayA(:,:) >= grayB(:,:)) = 1;
            Group{1, i}(:,:,j) = bitPlane;

            waitbar(j/(numOfPattern*0.25 - 0.5), h,...
                ['Decoding ...', num2str(round(j*100/((numOfPattern - 2)/4))), '%']);
        end
        delete(h);
                    
        decodedData{1, i} = gray2dec(Group{1, i})-offset(i);
        decodedData{1, i}(~Mask{1, i}) = NaN;
    end

    % Eliminate invalid column/row estimates.
    % Note: This will exclude pixels if either the column or row is missing.
    %       D{j,k} is the column/row for "orientation" j and camera k.
    %       mask{k} is the overal per-pixel mask for camera k.
    mask = Mask{1};
    for j = 1:size(decodedData,1)
      if j == 1
         decodedData{j}(decodedData{j} > cam_width) = NaN;
      else
         decodedData{j}(decodedData{j} > cam_height) = NaN;
      end
      decodedData{j}(decodedData{j} < 1) = NaN;
      for i = 1:size(decodedData,1)
         decodedData{j}(~Mask{i}) = NaN;
         mask =  mask & Mask{i};
      end
    end
end