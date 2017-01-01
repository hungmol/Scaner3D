function [pointCloud] = reconstructGrayCode(figHandle)
  
    if (nargin < 1)
        errordlg('Check input data', 'Error not enough input argument');
        return;
    end
     
    calibData = getappdata(figHandle, 'calibData');
    
    if isempty(calibData)
        errordlg('Do not find the calibration data, make sure you have loaded it',...
                 'Error Calibration Data');
        return;
    end
    
    % Rotation matrix and translate matrix of projector
    Rproj = calibData.R;
    Tproj = calibData.T;
    
    %Camera coordinate
    cameraCoord = [0; 0; 0];
    
    % Projector coordinate
    projCoord = -Rproj*Tproj;
    
    % Get the intrinsic of camera from calibData
    fc_Cam = [calibData.cam_K(1, 1); calibData.cam_K(2, 2)];
    cc_Cam = [calibData.cam_K(1, 3); calibData.cam_K(2, 3)];
    alpha_c_Cam = 0.0;
    kc_Cam = calibData.cam_kc;
    
    % Get the intrinsic of projector from calibData
    fc_Proj = [calibData.proj_K(1, 1); calibData.proj_K(2, 2)];
    cc_Proj = [calibData.proj_K(1, 3); calibData.proj_K(2, 3)];
    alpha_c_Proj = 0.0;
    kc_Proj = calibData.proj_kc;
    
    % Find the index not a number (NAN) in both vertical and horizontal decoded data
    grayHor = getappdata(figHandle, 'grayHor');
    grayVer = getappdata(figHandle, 'grayVer');
    
    if isempty(grayHor) 
        errordlg('The horizontal decoded data is empty, please check again', 'Error Data input');
        return;
    elseif  isempty(grayVer)
        errordlg('The vertical decoded data is empty, please check again', 'Error Data input');
        return;
    end
    
    properIndex = find(~isnan(grayHor) & ~isnan(grayVer));
    
    % Using line intersect line to reconstruct object
    numOfPoints = length(properIndex);
    
    % Calculate the ray come from projector coordinate through pixel in image
    projRay  = pixel2ray([grayHor(properIndex) grayVer(properIndex)]',fc_Proj,cc_Proj,kc_Proj,alpha_c_Proj);
    projRay = Rproj'*projRay;
    
    % Calculate the ray come from camera coordinate through pixel
    grayIM = getappdata(figHandle, 'grayIM');
    camWidth = size(grayIM{1,1}(:,:,1), 2);
    camHeight = size(grayIM{1,1}(:,:,1), 1);

%    c = 1:camWidth;
%    r = 1:camHeight;
    [C,R] = meshgrid(1:camWidth, 1:camHeight);
    camRay = [C(:) R(:)]';
    camRay = pixel2ray(camRay(:,properIndex),fc_Cam, cc_Cam, kc_Cam, alpha_c_Cam);
    
    % Reconstruct point cloud 
    pointCloud = intersectLineWithLine3D(repmat(cameraCoord,1,numOfPoints), camRay,...
                                     repmat(projCoord,1,numOfPoints),projRay);
    
end


function [points,IDX] = reconstruct_goccam(D,S,w_cam,h_cam,idx,DD,DM,dist)
    %Load thong so calib
    disp('+ Thuc hien dung lai hinh....Xin doi!');
    %Xac dinh ma tran quay va tinh tien cho may chieu
    Rs = S.R;
    Ts = S.T;
    Oc = [0;0;0]; %goc camera
    P = -Rs'*Ts;  %goc may chieu

    % Intrinsic parameters of camera:
    fc_cam = [S.cam_K(1,1); S.cam_K(2,2)]; % Focal Length
    cc_cam = [S.cam_K(1,3); S.cam_K(2,3)]; % Principal point
    alpha_c_cam =  0.0 ; % Skew
    kc_cam = S.cam_kc; % Distortion

    % Intrinsic parameters of projector:
    fc_proj = [S.proj_K(1,1); S.proj_K(2,2)]; % Focal Length
    cc_proj = [S.proj_K(1,3); S.proj_K(2,3)]; % Principal point
    alpha_c_proj =  0.0 ; % Skew
    kc_proj = S.proj_kc; % Distortion    
    if isempty(idx)
        idx       = find(~isnan(D{1,1}) & ~isnan(D{2,1}));
    end
    npts      = length(idx);
    
    %Tinh tia cua may chieu
    if (DD == 1 && DM == 0)
        Np  = pixel2ray([D{1}(idx) D{2}(idx)]',fc_proj,cc_proj,kc_proj,alpha_c_proj);
    end
    
    %Tinh cac tia cua camera
    c = 1:w_cam;
    r = 1:h_cam;
    [C,R] = meshgrid(c,r);
    Nc_temp = [C(:) R(:)]';
    
    %Tim cac tia tu may chieu de dung lai mat phang
    if (DD == 0 && DM == 1)
        idx       = find(~isnan(D{1}));
        npts      = length(idx);
        nx_proj = 1024;
        ny_proj = 768;
        c = 1:nx_proj;
        r = 1:ny_proj;
        [C,R] = meshgrid(c,r);
        np  = pixel2ray([C(:) R(:)]',fc_proj,cc_proj,kc_proj,alpha_c_proj);
        np = Rs'*(np - Ts*ones(1,size(np,2)));
        Np = zeros([ny_proj nx_proj 3]);
        Np(:,:,1) = reshape(np(1,:),ny_proj,nx_proj);
        Np(:,:,2) = reshape(np(2,:),ny_proj,nx_proj);
        Np(:,:,3) = reshape(np(3,:),ny_proj,nx_proj);
    end
    Nc = pixel2ray(Nc_temp(:,idx),fc_cam,cc_cam,kc_cam,alpha_c_cam);
    
    %Tinh tia cua camera
    [points] = goccam(Oc,P,D,idx,DD,DM,Np,Nc,Rs,npts);
  
    %%%%%%%%%%%%%%%%%%%%%%%
    %loai bo diem khong thuoc pham vi giup giam nhieu
    a = points(1,:);
    b = points(2,:);
    c = points(3,:);
    IDX = find(points(3,:) < dist);
    a = a(IDX);
    b = b(IDX);
    c = c(IDX);
    points = [a;b;c];
    %%%%%%%%%%%%%%%%%%%%%%%
    
end

%%
function [points] = goccam(Oc,P,D,idx,DD,DM,Np,Nc,Rs,npts)
%Kiem tra xem nguoi dung chon phuong phap dung hinh la duong-duong hay duong-mat
    if(DD == 1 && DM == 0) 
        %%Giao duong voi duong
        %Tinh lai cac tia cua projector
        Np  = Rs'*Np;
        %Ket qua khi goc chon la mat phang reference
        points = intersectLineWithLine3D(repmat(Oc,1,npts),Nc,repmat(P,1,npts),Np);
    elseif (DD == 0 && DM == 1)
        %tinh giao duong voi mat
        nx_proj = 1024;
        wPlaneCol = zeros(nx_proj,4);
        %Dung lai 1024 mat phang di qua goc may chieu theo phuong thang
        %dung
        for i = 1:nx_proj
            wPlaneCol(i,:) = ...
                fitPlane([P(1); Np(:,i,1)],[P(2); Np(:,i,2)],[P(3); Np(:,i,3)]);
        end
        points = intersectLineWithPlane(repmat(Oc,1,npts),Nc,wPlaneCol(D{1}(idx),:)');       
    end
    points(3,:) = abs(points(3,:)); %dao nguoc truc z
    pause(0.5);
    disp('+ Xu ly xong');    
%%
end