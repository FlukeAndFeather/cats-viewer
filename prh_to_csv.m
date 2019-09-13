%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Load PRH mat file first %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set working directory to cats-viewer project folder
cats_dir = uigetdir('~', 'Select cats-viewer project folder');
cd(cats_dir);

datetime = datestr(DN, 'yyyy-mm-dd HH:MM:SS.FFF');
Ax = Aw(:,1);
Ay = Aw(:,2);
Az = Aw(:,3);
Mx = Mw(:,1);
My = Mw(:,2);
Mz = Mw(:,3);
Gx = Gw(:,1);
Gy = Gw(:,2);
Gz = Gw(:,3);
x = geoPtrack(:,1);
y = geoPtrack(:,2);
tbl = table(datetime, p, Ax, Ay, Az, Mx, My, Mz, Gx, Gy, Gz, x, y, pitch, roll);
tbl.speed = speed.JJ;
writetable(tbl, [cats_dir '/data/' INFO.whaleName '/' INFO.whaleName ' 10Hzprh.csv']);
