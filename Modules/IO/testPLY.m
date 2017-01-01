
%
%Data.vertex.x = [0;0;0;0;1;1;1;1];
%Data.vertex.y = [0;0;1;1;0;0;1;1];
%Data.vertex.z = [0;1;1;0;0;1;1;0];
%Data.face.vertex_indices = {[0,1,2,3],[7,6,5,4], ...
%        [0,4,5,1],[1,5,6,2],[2,6,7,3],[3,7,4,0]};
%plywrite(Data,'cube.ply','ascii');


vertex = struct('x',[0;0;0;0;1;1;1;1], 'y', [0;0;1;1;0;0;1;1], 'z', [0;1;1;0;0;1;1;0]);
%face = struct('vertext_indices', cell(1,6));
% face.vertex_indices = {[0,1,2,3],[7,6,5,4],[0,4,5,1],[1,5,6,2],[2,6,7,3],[3,7,4,0]};
		 
Data1 = struct('vertex', vertex);
ply_write(Data1,'cube.ply','double');
% ply_display('cube.ply');