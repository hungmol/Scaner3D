%This function use for calculate wrapped phase
%Input: handle object of main figure
%Output: wrapped phase and unwrapped phase data

%Author: Duong Hong Hung
%Created: 12/2016

function [wPhi, uPhi] = calWrappedPhase(handles)
    
    phaseIM = getappdata(handles, 'phaseIM');
    wPhi = 0;
    uPhi = 0;
    if isempty(phaseIM)
        errordlg('Please load phase shift image before do this step', 'Error');
        return;
    end
    
    wPhi = single(atan2(sqrt(3)*(phaseIM{1,1} - phaseIM{1,3}), 2*phaseIM{1,2} - phaseIM{1,1} - phaseIM{1,3}));
    
    %unwrapped phase
    uPhi = Miguel_2D_unwrapper(wPhi);
    
end