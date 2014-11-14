function save_data_n_params(WM)

pwd_cmd = 'pwd';

[status_pwd,curr_path] = system(pwd_cmd);

curr_path_no_newline = curr_path(1:end-1);

test_dir_path =[curr_path_no_newline,'/',WM.Sim.Test_dir_name];

% status_cd = system(go_test_dir);
% 
% if status_cd~=0
%     
%     warning('Cd not successfull');
% end

list_fold_cmd = ['ls ',test_dir_path,' -l | egrep ^d | egrep ',WM.Sim.out_dir_name,'_[0-9]{5}'];

[status_ls,folder_list] = system(list_fold_cmd);

WM.test_id_ndigits = 5;

if isempty(folder_list) || status_ls==2
    
    test_id = '00001'; 
    
else
   get_last_id_cmd = ['ls ',test_dir_path,' -l | egrep ^d | grep -Po ',WM.Sim.out_dir_name,'_"\K[0-9]{5}"'];
   
   [status_getid,stdout_getid] = system(get_last_id_cmd);
   
   tot_char = length(stdout_getid);
   char_per_str = (WM.test_id_ndigits+1);
   n_folders = tot_char/char_per_str;
   
   res_col = reshape(stdout_getid,char_per_str,n_folders)';
   
   last_id = str2double(res_col(end,:));
   
   test_id = sprintf('%05d',last_id+1);
    
end

new_dir_path = [test_dir_path,'/',WM.Sim.out_dir_name,'_',test_id];
    
    make_result_dir_cmd = ['mkdir ',new_dir_path];
    
    [status_mkdir,stdout_mkdir] = system(make_result_dir_cmd);
    
    if status_mkdir==0
    
        date_str = date;
        time_dec = clock;
        time_str =sprintf('%02d:%02d',time_dec(4),time_dec(5));
        test_str = ['_',test_id,'_',date_str,'_',time_str];
        
%     go_result_dir_cmd = ['cd ./',dir_name];
%     
%     [status_godir,stdout_godir] = system(go_result_dir_cmd);
%     
        cp_src_path = [test_dir_path,'/',WM.Sim.out_test_file,'.',WM.Sim.out_test_ext];
        cp_dst_path = [new_dir_path,'/',WM.Sim.out_test_file,test_str,'.',WM.Sim.out_test_ext];
        cp_cmd = ['cp ',cp_src_path,' ',cp_dst_path ];
        [status_cp,stdout_cp] = system(cp_cmd);
    else
        
        error('Error in creating folder exit value %d',status_mkdir);
        
    end
    
    param_file_path = [new_dir_path,'/sim_params',test_str,'.txt'];
    
       %%%%save params
    
    fid = fopen(param_file_path,'w');
    
    fprintf(fid,'Simulation date %s at %s\n',date_str,time_str);
    fprintf(fid,'\n INPUT PARAMS \n\n'); 
    fprintf(fid,'Char rate              = %f\n',WM.Sim.Encoder.Char_Rate);
    fprintf(fid,'Source rate            = %f\n',WM.Sim.Encoder.Source_Rate);
    fprintf(fid,'Max Tx Bw              = %f\n',WM.Sim.Encoder.Tx_max_BW  );    
    fprintf(fid,'Tx Bw                  = %f\n',WM.Sim.Encoder.Tx_BW);
    fprintf(fid,'data source            = %s\n',WM.Sim.Switch_ctrl.data_source);  
    fprintf(fid,'Spreading_code         = %s\n',WM.Sim.Switch_ctrl.Spreading_code);
    fprintf(fid,'Jammer_type            = %s\n',WM.Sim.Switch_ctrl.Jammer_type);   
    fprintf(fid,'hopping                = %s\n',WM.Sim.Switch_ctrl.hopping); 
    if strcmp(WM.Sim.Switch_ctrl.hopping,'on')
    fprintf(fid,'hopping_approx_frequency       = %s\n',WM.Sim.Upconverter.hopping_approx_frequency); 
    fprintf(fid,'hopping_frequency       = %s\n',WM.Sim.Upconverter.hopping_frequency);
    end
    fprintf(fid,'suppression_filter     = %s\n',WM.Sim.Switch_ctrl.suppression_filter);
    if strcmp(WM.Sim.Switch_ctrl.suppression_filter,'on')
    fprintf(fid,'suppression_filt order = %d\n',WM.Sim.SuppFilt.order); 
    end
    fprintf(fid,'data source            = %s\n',WM.Sim.Switch_ctrl.Pow_ctrl );     
    fprintf(fid,'Eb_N0_dB               = %d\n',WM.Sim.Channel.Eb_N0_dB);                      
    fprintf(fid,'tx_filter order        = %d\n',WM.Sim.Encoder.TxFilter.order    ); 
    fprintf(fid,'Time_length            = %f\n',WM.Sim.Time_length); 
    fprintf(fid,'Test_dir_name          = %s\n',WM.Sim.Test_dir_name);
    fprintf(fid,'Test_file_name         = %s\n',WM.Sim.Test_file_name);    
    fprintf(fid,'out_dir_name           = %s\n',WM.Sim.out_dir_name );    
    fprintf(fid,'out_test_file          = %s\n',WM.Sim.out_test_file );    
    fprintf(fid,'Oversampling_factor    = %f\n',WM.Sim.Encoder.Oversampling_factor);        
    fprintf(fid,'Spreading factor       = %f\n',WM.Sim.Encoder.SF);                        
    fprintf(fid,'Frame_len              = %d\n',WM.Sim.Frame_len ); 
    fprintf(fid,'\n OUTPUT DATA \n\n');
    if isvector(WM.Sim.BER_results)==1
        fprintf(fid,'BER                         = %f\n',WM.Sim.BER_results.Data(end,1)); 
        fprintf(fid,'Received Data Errors        = %f\n',WM.Sim.BER_results.Data(end,2)); 
        fprintf(fid,'Received Data               = %f\n',WM.Sim.BER_results.Data(end,3)); 
    end
    
    fclose(fid);
    
 
    
%    go_orig_path_cmd = ['cd ',curr_path_no_newline];
   
%    [status_orig_path,stdout_cd] = system(go_orig_path_cmd);
%    
%    if status_orig_path~=0
%     
%     warning('Cd not successfull');
%    end

end