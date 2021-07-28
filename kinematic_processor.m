% close all
clear all
format bank

%--------------------------------------------------------------------------
% Input settings - USER TO MODIFY
%--------------------------------------------------------------------------

%---Index of files to be procesed------------------------------------------
save_check = 1; % 1 = save info, 0 = do not save info 
%--------------------------------------------------------------------------

disp('Select actuator data file ');
[kinematic_files, kinematic_path] = uigetfile('*.txt',...
    'Select actuator file', 'MultiSelect','on');

if iscell(kinematic_files) == 0 
    kinematic_files = {kinematic_files};
end

%--------------------------------------------------------------------------

for i = 1:size(kinematic_files,2)
    disp(kinematic_files{i});
T_imp = readtable(strcat(kinematic_path,kinematic_files{i}));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Clean up data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

find_neg = find(T_imp.Vel<0,1);

if ~isempty(find_neg)
    T_imp = T_imp(1:find_neg-1,:);
end

PosZ = T_imp.Posz;
Time = T_imp.Time;

[T_exp] = kinematic_calculator(Time, PosZ);

if save_check == 1
    saveData(T_imp, kinematic_path, strcat(kinematic_files{i}(1:end-4),'-corrected'));
    file_name = strcat(kinematic_files{i}(1:end-4),'-polyCoeff');
    saveData(T_exp, kinematic_path, file_name);
end
end
