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
%
%author: Duong Hong Hung
%created: 12/2016

function dispProImageGUI(wrappedImage, unWrappedImage)
    
    if (nargin < 2)
        msgbox('Not enough input arguments', 'Error input arguments');
        continue;
    endif   
    hMainWindow = figure('Position',[300, 800, 900, 900],...
                         'menubar', 'none'); 
    
    %Create two panel axes for graycode image
    grayHorPanel = uipanel('Parent', hMainWindow, 'BackgroundColor',...
                           [0.25, 0.1, 0.25], 'ForegroundColor','white',...
                           'Title','Horizontal Decoded Image', ...
                           'Position', [0.0, 0.5, 0.5, 0.5]);
                           
    axesGrayHor = axes('Parent', grayHorPanel, 'POsition', [0.01, 0.01, 0.98, 0.98]);
                           
    grayVerPanel = uipanel('Parent', hMainWindow, 'BackgroundColor',...
                           [0.25, 0.1, 0.25], 'ForegroundColor','white',...
                           'Title','Vertical Decoded Image', ...
                           'Position', [0.5, 0.5, 0.5, 0.5]);
    
    axesGrayVer = axes('Parent', grayVerPanel, 'POsition', [0.01, 0.01, 0.98, 0.98]);    
    
    %Create two panel axes for wrapped and unwrapped phase
    
    phaseWrappedPanel = uipanel('Parent', hMainWindow, 'BackgroundColor',...
                           [0.25, 0.1, 0.25], 'ForegroundColor','white',...
                           'Title','Wrapped phase Image', ...
                           'Position', [0.0, 0.0, 0.5, 0.5]);
    axesWrappedPhase = axes('Parent', phaseWrappedPanel, 'POsition', [0.01, 0.01, 0.98, 0.98]);   
    
    phaseUnwrappedPanel = uipanel('Parent', hMainWindow, 'BackgroundColor',...
                           [0.25, 0.1, 0.25], 'ForegroundColor','white',...
                           'Title','Unwrapped phase Image', ...
                           'Position', [0.5, 0.0, 0.5, 0.5]);                       
                           
    axesUnwrappedPhase = axes('Parent', phaseUnwrappedPanel, 'POsition', [0.01, 0.01, 0.98, 0.98]);
    
endfunction