% This function use for the waiting process waitbar when reconstruct


% Author: Duong Hong Hung
% Created: 12/2016

function [fwait] = waitWindow()
	
	fwait = figure('name', 'Please wait...', 'Position', [500 450 500 150],...
				   'menubar', 'none');	
	
	str = 'Please wait for the reconstruction process'
	uicontrol('parent', fwait, 'style', 'text', 'string', str,...
			  'Position', [90, 80, 400, 30], 'fontsize', 12,...
			  'horizontalalignment','left', 'BackgroundColor','white');
	
end