%   GUI for display decode image and phase image
            %-------------------------
            %|           |           |
            %|           |           |
            %|           |           |
            %|           |           |
            %|           |           |
            %-------------------------
            %|           |           |
            %|           |           |
            %|           |           |
            %|           |           |
            %|           |           |
            %-------------------------
%Input: four arguments
%       + 1 : graycode image with orientation is horizontal
%       + 2 : graycode image with orientation is vertical
%       + 3 : wrapped phase image
%       + 4 : unwrapped phase image 
%
%Output: NO

%author: Duong Hong Hung
%created: 12/2016

function dispProImageGUI(grayHor, grayVer, wrappedImage, unWrappedImage)
    
    if (nargin < 4)
        msgbox('Not enough input arguments', 'Error input arguments');
        return;
    end
    
    hMainWindow = figure('Position',[300, 800, 900, 900],...
                         'menubar', 'none'); 
    
    %Create two panel axes for graycode image
    grayHorPanel = uipanel('Parent', hMainWindow, 'BackgroundColor',...
                           [0.25, 0.1, 0.25], 'ForegroundColor','white',...
                           'Title','Horizontal Decoded Image', ...
                           'Position', [0.0, 0.5, 0.5, 0.5]);
                           
    axesGrayHor = axes('Parent', grayHorPanel, 'Position', [0.01, 0.01, 0.98, 0.98]);
                           
    grayVerPanel = uipanel('Parent', hMainWindow, 'BackgroundColor',...
                           [0.25, 0.1, 0.25], 'ForegroundColor','white',...
                           'Title','Vertical Decoded Image', ...
                           'Position', [0.5, 0.5, 0.5, 0.5]);
    
    axesGrayVer = axes('Parent', grayVerPanel, 'Position', [0.01, 0.01, 0.98, 0.98]);    
    
    %Create two panel axes for wrapped and unwrapped phase
    
    phaseWrappedPanel = uipanel('Parent', hMainWindow, 'BackgroundColor',...
                           [0.25, 0.1, 0.25], 'ForegroundColor','white',...
                           'Title','Wrapped phase Image', ...
                           'Position', [0.0, 0.0, 0.5, 0.5]);
    axesWrappedPhase = axes('Parent', phaseWrappedPanel, 'Position', [0.01, 0.01, 0.98, 0.98]);   
    
    phaseUnwrappedPanel = uipanel('Parent', hMainWindow, 'BackgroundColor',...
                           [0.25, 0.1, 0.25], 'ForegroundColor','white',...
                           'Title','Unwrapped phase Image', ...
                           'Position', [0.5, 0.0, 0.5, 0.5]);                       
                           
    axesUnwrappedPhase = axes('Parent', phaseUnwrappedPanel, 'Position', [0.01, 0.01, 0.98, 0.98]);
    
    %Show picture
    if ~isempty(grayHor)
        imagesc(grayHor, 'Parent', axesGrayHor);
    end
    
    if ~isempty(grayVer)
        imagesc(grayVer, 'Parent', axesGrayVer);
    end
    colormap(jet(256));
    
%    colormap(gray(256));
    if ~isempty(wrappedImage)
        imagesc(wrappedImage, 'Parent', axesWrappedPhase);
    end
    
    if ~isempty(unWrappedImage)
        imagesc(unWrappedImage, 'Parent', axesUnwrappedPhase);
    end   
    colormap(gray(256));
end