% This function only use for convert png or bmp file to jpg and the right format

function imageConverter(name, format, folder, flag)
    
   if (nargin < 4)
       flag = 'keep';
   end
   
   if (nargin < 3)
       errordlg('Please specify source and destination folder', 'Error Folder');
       return;
   end

   h = waitbar(0, 'Initilize', 'Name', 'Convert Image');
   for i = 1:1:42
       fileNameIn = [folder, '/', name, num2str(i, '%0.02d'), format];
       im = imread(fileNameIn);
       fileNameOut = [folder, '/', num2str(i, '%0.02d'), '.jpg'];
       imwrite(im, fileNameOut);
       if (flag == 'delete')
           delete(fileNameIn);
       end
           
         
       waitbar(i/42, h, ['Converting ...', num2str(round((i/42)*100)), '%']);
   end
   delete(h);
    
end