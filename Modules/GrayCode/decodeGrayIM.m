% This function use for decode gray code patterns

% Author: Duong Hong Hung
% Created: 12/2016


function decodeGrayIM(grayIM, grayThresh)
    % Estimate column/row label for each pixel (i.e., decode Gray codes).
    % Note: G{j,k} is the estimated Gray code for "orientation" j and camera k.
    %       D{j,k} is the integer column/row estimate.
    %       M{j,k} is the per-pixel mask (i.e., pixels with enough contrast).
    cam_width = size(grayIM{1,1}(2));
    cam_height = size(grayIM{1,1}(1));
    proj_width = 1024;
    proj_height = 768;
    
    [~,offset] = graycode(proj_width, proj_height);
    
    disp('+ Recovering projector rows/columns from structured light sequence...');
    numOfPattern = 42;
    G = cell(1, (numOfPattern-2)*0.5);
    D = cell(1, (numOfPattern-2)*0.5);
    M = cell(1, (numOfPattern-2)*0.5);

    frameIdx = 3;
    for i = 1:1:numOfPattern
       G{1, i} = zeros(size(T{1}{1},1),size(T{1}{1},2),size(A,2),'uint8');
       M{1, i} = false(size(T{1}{1},1),size(T{1}{1},2));
       
       % Separate two type of gray image
       grayA = grayIM{1, frameIdx};
       frameIdx = frameIdx + 1;
       grayB = grayIM{1, frameIdx};
       frameIdx = frameIdx + 1;
       
       % Eliminate all pixels that do not exceed contrast threshold.
       M{1, i}(abs(grayA-grayB) > 255*grayThresh) = true;
       
       % Estimate current bit of Gray code from image pair.
       bitPlane = zeros(size(T{1}{1},1),size(T{1}{1},2),'uint8');
       bitPlane(grayA(:,:) >= grayB(:,:)) = 1;
       G{j,k}(:,:,i) = bitPlane;
       
       if strcmp(seqType,'Gray')
          D{j,k} = gray2dec(G{j,k})-offset(j);
       else
          D{j,k} = bin2dec(G{j,k})-offset(j);
       end
          D{j,k}(~M{j,k}) = NaN;
    end

    % Eliminate invalid column/row estimates.
    % Note: This will exclude pixels if either the column or row is missing.
    %       D{j,k} is the column/row for "orientation" j and camera k.
    %       mask{k} is the overal per-pixel mask for camera k.
    mask = cell(1,nCam);
    mask = M{1,k};
    for j = 1:size(D,1)
        if j == 1
            D{j,k}(D{j,k} > width) = NaN;
        else
            D{j,k}(D{j,k} > height) = NaN;
        end
        D{j,k}(D{j,k} < 1) = NaN;
        for i = 1:size(D,1)
            D{j,k}(~M{i,k}) = NaN;
            mask{k} =  mask{k} & M{i,k};
        end
    end

%    % Display recovered projector column/row.
%    figure(1); clf;
%    imagesc(D{1,1}); axis image; colormap(jet(256));
%    title('Recovered Projector Column Indices'); drawnow;
%    figure(2); clf;
%    imagesc(D{2,1}); axis image; colormap(jet(256));
%    title('Recovered Projector Row Indices'); drawnow;
%    figure(3); clf;
%    imagesc(T{1}{1}); axis image; colormap(jet(256));
%    title('Reference Image for Texture Mapping'); drawnow;

endfunction