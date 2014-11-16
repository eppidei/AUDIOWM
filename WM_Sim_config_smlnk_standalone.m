%%%%%%%%%%%%%%%%%%%%%%%% PROGRAMMATIC SIMULINK SIMULATION SCRIPT

clear all;close all;clc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% LAUNCHING SIMULINK SCRIPT

matlab_sim=false;

%%%%SIM PARAMS

Approx_char_rate            = 10;%coded effective to bedivided by fec ratio
Time_length                 = 20;
Carrier_Freq                = 500 ;
hopping_approx_frequency    = 200;
hopping                     = 'off';
suppression_filter          = 'off';
supp_filt_order             = 8;
Eb_N0_dB                    = 10;
Frame_len                   = 1;
Tx_approx_BW                = 9e3;
fec                         = 'on';
fec_k                   = 5;
fec_n                   = 15;

  close_system('WM_Sim',1);

WM=WM_Sim_config(Time_length,Approx_char_rate,Tx_approx_BW,Carrier_Freq,hopping_approx_frequency,...
                                      hopping,Frame_len,suppression_filter,supp_filt_order,Eb_N0_dB,'noise',fec,fec_k,fec_n);

 open_system('WM_Sim');