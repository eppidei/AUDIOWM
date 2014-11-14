%%%%%%%%%%%%%%%%%%%%%%%% PROGRAMMATIC SIMULINK SIMULATION SCRIPT

clear all;close all;clc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% LAUNCHING SIMULINK SCRIPT

matlab_sim=true;

%%%%SIM PARAMS

Approx_char_rate            = [1,5,10];
Time_length                 = 60;
Carrier_Freq                = [500 ,1e3,1.5e3];
hopping_approx_frequency    = [200,700,1300];
hopping                     = {'on','off'};
suppression_filter          = {'on','off'};
supp_filt_order             = 8;
Eb_N0_dB                    = -10;
Frame_len                   = 256;
Tx_approx_BW                = [8e3,9e3];

n_params = length(Approx_char_rate)*length(Carrier_Freq)*length(hopping_approx_frequency)*...
    length(hopping)*length(suppression_filter)*length(supp_filt_order)*length(Eb_N0_dB)*length(Tx_approx_BW);

test_idx=0;

for i=1:length(Approx_char_rate)
    for j=1:length(Carrier_Freq)
        for k=1:length(hopping_approx_frequency)
            for w=1:length(Tx_approx_BW)
                for s=1:length(hopping)
                    for t=1:length(suppression_filter);
    
                        Ch_rate = Approx_char_rate(i);
                        Car_freq = Carrier_Freq(j);
                        Tx_app_bw = Tx_approx_BW(w);
                        hop_approx_freq = hopping_approx_frequency(k);
                        hoppi = char(hopping(s));
                        supp_filt = char(suppression_filter(t));

                        WM=WM_Sim_config(Time_length,Ch_rate,Tx_app_bw,Car_freq,hop_approx_freq,...
                                      hoppi,Frame_len,supp_filt,supp_filt_order,Eb_N0_dB,'audio');
                        paramNameValStruct.SimulationMode = 'accelerator';
                        paramNameValStruct.SaveState      = 'off';
                        paramNameValStruct.StopTime        = 'WM.Sim.Time_length';
                        % paramNameValStruct.StateSaveName  = 'xoutNew';
%                         paramNameValStruct.SaveOutput     = 'on';
%                         paramNameValStruct.OutputSaveName = 'youtNew';
%                         g0=get_param('WM_Sim/Probing_system/Despreaded_hist','ScopeConfiguration');
%                         g0.OpenAtSimulationStart=false;
%                         s0=set_param('WM_Sim/Probing_system/Despreaded_hist','ScopeConfiguration',g0);
                        
                        simOut = sim('WM_Sim',paramNameValStruct);
                        WM.Sim.BER_results=simOut.get('BER_results_simout');
                        clc;
                        save_data_n_params(WM);
                        test_idx=test_idx+1;
                        fprintf('Finished test n  %05d\n',test_idx);
                    end
                end
            end
        end
    end
end

[Ber_ordered,Test_ids]=get_statistics(WM,test_idx);
fid = fopen('./audio_test/Test_report.txt','w');
fprintf(fid,'TestID    BER\n\n');
for i=1:test_idx
fprintf(fid,'%d        %f\n',Test_ids(i),Ber_ordered(i));
end
fclose(fid);