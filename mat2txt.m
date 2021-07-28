[mat_files, mat_path] = uigetfile('*.mat',...
    'Select actuator drive files', 'MultiSelect','on');

    if iscell(mat_files) == 0
        mat_files = {mat_files};
    end

type = '.txt';
    
for i=1:size(mat_files,2)
    load(fullfile(mat_path,mat_files{i}));
    Vel(length(Time)) = 0;
    
    T_move = table(round(Pos.',5), round(PosZ.',5), round(Time.',5),round(Vel.',5)...
        ,'VariableNames',{'Pos','Posz','Time','Vel'});
    writetable(T_move, fullfile(mat_path,strcat(mat_files{i}(1:end-4),type)), 'Delimiter','\t');
    
    
end