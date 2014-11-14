function [Ber_ordered,Test_ids]=get_statistics(WM,n_sub_folders)

Ber_collected = zeros(1,n_sub_folders);

for i = 1:n_sub_folders

id_code = sprintf('_%05d',i);
folder_str = ['./',WM.Sim.Test_dir_name,'/',WM.Sim.out_dir_name,id_code];

list_fold_cmd = ['ls -l ',folder_str,' |  egrep -o "sim(.)*.txt"'];

[status_ls,folder_list] = system(list_fold_cmd);

file_str = [folder_str,'/',folder_list];

fid = fopen(file_str(1:end-1),'r');

if fid~=-1

while feof(fid)==false
    
    line = fgetl(fid);
    
    [token,remain]=strtok(line,' ');
    
    if strcmp(token,'BER')
        
        [token,remain]=strtok(remain,'=');
         [token,remain]=strtok(remain,' ');
        Ber_collected(i)=str2double(remain);
    end
    
end

else
    [status_pwd,curr_path] = system('pwd');
    error('File %s not found actual path is %s',folder_str,curr_path);
    
end


fclose(fid);

end


[Ber_ordered,Test_ids]=sort(Ber_collected,'ascend');

end