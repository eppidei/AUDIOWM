function WM=WM_Sim_config(Time_length,Approx_fec_byte_rate,Tx_approx_BW,Carrier_Freq,hopping_approx_frequency,...
                  hopping,Frame_len,suppression_filter,supp_filt_order,Eb_N0_dB,Jammer_type,fec,fec_k,fec_n)

addpath ./functions

WM.Sim.Frame_len    = Frame_len;%WM.Sim.Encoder.SF;

%%%%%% ENVIRONMENT PARAMS

WM.Sim.Fs_audio   = 44100;
WM.Sim.Fs_audio_frame_based =WM.Sim.Fs_audio/WM.Sim.Frame_len; 
WM.Sim.Channel.BW          = WM.Sim.Fs_audio/2;
WM.Sim.Message_length      =fec_k;
fec_ratio=fec_k/fec_n;
if strcmp(fec,'on')
    WM.Sim.FEC_ratio       = fec_ratio;
    
elseif strcmp(fec,'off')
    WM.Sim.FEC_ratio       = 1;
else
    error('valid fec option is on or off');
end
WM.Sim.Codeword_length      = (fec_n);
%%%%%% SIMULATION PARAMS

WM.Sim.Time_length =Time_length;
WM.Sim.Test_dir_name = 'audio_test';
WM.Sim.Test_file_name    =  'Balmorhea - Days.wav';
WM.Sim.out_dir_name      =  'Test';
WM.Sim.out_test_file     = 'jammed';
WM.Sim.out_test_ext     = 'wav';



%%%%%%%% USER primary PARAMS
WM.Sim.Encoder.FEC_approx_charRate      = Approx_fec_byte_rate;
WM.Sim.Encoder.FEC_approx_Rate          = WM.Sim.Encoder.FEC_approx_charRate*8;
WM.Sim.Encoder.Tx_max_BW                   = 11e3;
WM.Sim.Encoder.Tx_approx_BW                = Tx_approx_BW;
WM.Sim.Encoder.Carrier_Freq                = Carrier_Freq;
if WM.Sim.Encoder.Tx_approx_BW + WM.Sim.Encoder.Carrier_Freq>WM.Sim.Encoder.Tx_max_BW 
   
    error('band exceed max BW');
    
end
WM.Sim.Upconverter.hopping_band           =WM.Sim.Encoder.Tx_max_BW-( WM.Sim.Encoder.Tx_approx_BW +WM.Sim.Encoder.Carrier_Freq);
WM.Sim.Upconverter.hopping_approx_frequency  = hopping_approx_frequency;
WM.Sim.Upconverter.hopping_frequency  =WM.Sim.Upconverter.hopping_approx_frequency- mod(WM.Sim.Upconverter.hopping_approx_frequency,WM.Sim.Fs_audio_frame_based);



%%%%%%%%%% USER secondary PARAMS
  WM.Sim.Switch_ctrl.data_source   = 'random';
 WM.Sim.Switch_ctrl.Spreading_code = 'random';
 WM.Sim.Switch_ctrl.Jammer_type    = Jammer_type;
 WM.Sim.Switch_ctrl.hopping        = hopping;
 WM.Sim.Switch_ctrl.suppression_filter        =suppression_filter;
 WM.Sim.SuppFilt.order = supp_filt_order;
 WM.Sim.Channel.Jammer_source = ['./',WM.Sim.Test_dir_name,'/',WM.Sim.Test_file_name];
 WM.Sim.Switch_ctrl.Pow_ctrl       ='on';
 WM.Sim.Channel.Eb_N0_dB                       = Eb_N0_dB;
 WM.Sim.Encoder.TxFilter.order                = 288*2;



%%%%%% DERIVED PARAMS
WM.Sim.Encoder.Oversampling_factor        = round(WM.Sim.Channel.BW/WM.Sim.Encoder.Tx_approx_BW);
WM.Sim.Encoder.Tx_BW                      = WM.Sim.Channel.BW/WM.Sim.Encoder.Oversampling_factor;
WM.Sim.Encoder.Tx_Rate                      = (2*WM.Sim.Encoder.Tx_BW);
WM.Sim.Encoder.SF                         = round(WM.Sim.Encoder.Tx_Rate/(WM.Sim.Encoder.FEC_approx_Rate));
% WM.Sim.Frame_len                            = Frame_len;%WM.Sim.Encoder.SF;
WM.Sim.Encoder.Source_Rate                = WM.Sim.Encoder.Tx_Rate/WM.Sim.Encoder.SF*WM.Sim.FEC_ratio;
WM.Sim.Encoder.Char_Rate                = WM.Sim.Encoder.Source_Rate/8;
WM.Sim.Encoder.Source_Ts   = 1/WM.Sim.Encoder.Source_Rate;
WM.Sim.Encoder.Source_BW   = (WM.Sim.Encoder.Source_Rate)/2;
% WM.Sim.Encoder.SF          = 
WM.Sim.Encoder.SourceGain   = 1;
if strcmp(WM.Sim.Switch_ctrl.data_source,'random')
WM.Sim.Encoder.Source.Switch = 1;

elseif strcmp(WM.Sim.Switch_ctrl.data_source,'constant')
    WM.Sim.Encoder.Source.Switch = 0;
else
    
    error('Data source type unknown');
    
end
%%% INPUT ERROR CHECKS

if WM.Sim.Encoder.Tx_BW>WM.Sim.Channel.BW
   error('Bandwidth too high for the channel'); 
end
if (WM.Sim.Encoder.Carrier_Freq+ WM.Sim.Encoder.Tx_BW/2>WM.Sim.Channel.BW )
   error('Carrier frequency out of range'); 
end

if WM.Sim.Encoder.Carrier_Freq==0
   
    warning('Carrier frequency for carrier power balancing reasons (till now) must be not zero');
    
end
    


%%%SAMPLE Times ... quelli evidenziati da simulink sono Frame times=sample_time*frame_len

WM.Sim.SampleTimes.Tsource   = WM.Sim.Encoder.Source_Ts;
WM.Sim.SampleTimes.Tcoded   = WM.Sim.Encoder.Source_Ts*WM.Sim.FEC_ratio;
WM.Sim.SampleTimes.Tspreader = WM.Sim.Encoder.Source_Ts/WM.Sim.Encoder.SF*WM.Sim.FEC_ratio;
if WM.Sim.SampleTimes.Tspreader<(1/WM.Sim.Encoder.Tx_Rate)-1e-10 || WM.Sim.SampleTimes.Tspreader>(1/WM.Sim.Encoder.Tx_Rate)+1e-10
    
    error('Sample time problem Spreader rate = %f Tx_rate = %f',1/WM.Sim.SampleTimes.Tspreader,WM.Sim.Encoder.Tx_Rate);
    
end
WM.Sim.SampleTimes.Tchannel = 1/WM.Sim.Fs_audio;

%%%%%%% MISSION PARAMS

WM.Sim.Modulation_type         = 'BPSK';
WM.Sim.order_M               = modulation_parameters(WM.Sim.Modulation_type);
WM.Sim.PhaseOff                = 0;
WM.Sim.Phase_encod_type        = 'Gray';
WM.Sim.bit_x_symbol            = log2(WM.Sim.order_M);
WM.Sim.seed_rand_msg            = 11;
WM.Sim.alg_rand_message             = 'swb2712';
WM.Sim.seed_spreading_sequence               = 38;
WM.Sim.alg_spreading_sequence                = 'swb2712';


%%%%%%%FEC

  load_system('WM_Sim');
if strcmp(fec,'on')
   
    %fec encoder
    type='add';
    subsystem = 'WM_Sim/FEC/Block';
    block_name = 'BCH Encoder';
    block_params.name_str={'N','K'};
    block_params.val_str={num2str(WM.Sim.Codeword_length),num2str(WM.Sim.Message_length)};
    block_params.n_params=length(block_params.name_str);
    inport_name='uncoded_i';
    oport_name='coded_o';
    library_name='commblkcod2';
    add_or_bypass_SISO_block(type,subsystem,block_name,block_params,inport_name,oport_name,library_name);

   
    %fec decoder
     type='add';
    subsystem = 'WM_Sim/FEC_decod/Block';
    block_name = 'BCH Decoder';
    block_params.name_str={'N','K'};
    block_params.val_str={num2str(WM.Sim.Codeword_length),num2str(WM.Sim.Message_length)};
    block_params.n_params=length(block_params.name_str);
    inport_name='coded_i';
    oport_name='decoded_o';
    library_name='commblkcod2';
    add_or_bypass_SISO_block(type,subsystem,block_name,block_params,inport_name,oport_name,library_name);

    
elseif strcmp(fec,'off')
    
 type='bypass';
    subsystem = 'WM_Sim/FEC/Block';
    block_name = 'BCH Encoder';
    block_params.name_str={'N','K'};
    block_params.val_str={num2str(WM.Sim.Codeword_length),num2str(WM.Sim.Message_length)};
    block_params.n_params=length(block_params.name_str);
    inport_name='uncoded_i';
    oport_name='coded_o';
    library_name='commblkcod2';
    add_or_bypass_SISO_block(type,subsystem,block_name,block_params,inport_name,oport_name,library_name);
    %%% fec encoder

   
    %%% fec decoder
      type='bypass';
    subsystem = 'WM_Sim/FEC_decod/Block';
    block_name = 'BCH Decoder';
    block_params.name_str={'N','K'};
    block_params.val_str={num2str(WM.Sim.Codeword_length),num2str(WM.Sim.Message_length)};
    block_params.n_params=length(block_params.name_str);
    inport_name='coded_i';
    oport_name='decoded_o';
    library_name='commblkcod2';
    add_or_bypass_SISO_block(type,subsystem,block_name,block_params,inport_name,oport_name,library_name);
    

 else
     
     error('fec can be only on or off,actual is %s',fec);
end


%%%%BURG SUPP
if strcmp(suppression_filter,'on')
   
 
    subsystem = 'WM_Sim/RX_chain/Burg suppresion';
   bpath = find_system(subsystem,'Name','Burg AR Estimator');
   bpath2 = find_system(subsystem,'Name','Suppression Filter');
   iport_h = find_system(subsystem,'FindAll','on','type','block','Name','signal_i');
   oport_h = find_system(subsystem,'FindAll','on','type','block','Name','filterd_o');
   burg_h= find_system(subsystem,'FindAll','on','type','block','Name','Burg AR Estimator');
   
   if isempty(bpath)
       bpath2=[subsystem,'/Burg AR Estimator'];
   add_block('dspparest3/Burg AR Estimator',bpath2,'ord',num2str(WM.Sim.SuppFilt.order),'fcn','A','inheritOrder','off');
   else
       str=sprintf('%s',bpath{1});
       warning('block %s already present',str);
   end
   
   if isempty(bpath2)
       bpath2=[subsystem,'/Suppression Filter'];
   add_block('Simulink/Discrete/Discrete Filter',bpath2,'FilterStructure','Direct Form II Transposed','Denominator','[1]','NumeratorSource','Input port','InitialStates','0','ExternalReset','None','InputProcessing','Columns as channels (frame based)','SampleTime','-1','a0EqualsOne','on');
   else
       str=sprintf('%s',bpath2{1});
       warning('block %s already present',str);
   end
   
   
   
   line_h1 = find_system(subsystem,'FindAll','on','type','line','SrcBlockHandle',iport_h);
    if isempty(line_h1)
        warning('Burg input line has been already removed');
   else
       delete_line(line_h1);
   end
   
   line_h2 = find_system(subsystem,'FindAll','on','type','line','DstBlockHandle',oport_h);
   if isempty(line_h2)
        warning('Burg output line has been already removed');
   else
        delete_line(line_h2);
   end
   
    line_h3 = find_system(subsystem,'FindAll','on','type','line','SrcBlockHandle',burg_h);
   if isempty(line_h3)
        warning('Burg internal line has been already removed');
   else
        delete_line(line_h3);
   end
   
   add_line(subsystem,'signal_i/1','Burg AR Estimator/1','autorouting','on');
   add_line(subsystem,'signal_i/1','Suppression Filter/1','autorouting','on');
   add_line(subsystem,'Burg AR Estimator/1','Suppression Filter/2','autorouting','on');
    add_line(subsystem,'Suppression Filter/1','filterd_o/1','autorouting','on');
   
elseif strcmp(suppression_filter,'off')   
    
bpath = find_system('WM_Sim','Name','Burg AR Estimator');
bpath2 = find_system('WM_Sim','Name','Suppression Filter');

   subsystem = 'WM_Sim/RX_chain/Burg suppresion';
   iport_h = find_system(subsystem,'FindAll','on','type','block','Name','signal_i');
   oport_h = find_system(subsystem,'FindAll','on','type','block','Name','filterd_o');
   burg_h= find_system(subsystem,'FindAll','on','type','block','Name','Burg AR Estimator');
  line_h3 = find_system(subsystem,'FindAll','on','type','line','SrcBlockHandle',burg_h);
   if isempty(bpath)
      warning('Burg AR Estimator has been already removed');
   else
      delete_block(bpath);
   end
   
   if isempty(bpath2)
      warning('Suppression Filter has been already removed');
   else
      delete_block(bpath2);
   end
   
   line_h1 = find_system(subsystem,'FindAll','on','type','line','SrcBlockHandle',iport_h);
   if isempty(line_h1)
        warning('BCH Encoder input line has been already removed');
   else
       delete_line(line_h1);
   end
   
   line_h2 = find_system(subsystem,'FindAll','on','type','line','DstBlockHandle',oport_h);
   if isempty(line_h2)
        warning('BCH Encoder output line has been already removed');
   else
        delete_line(line_h2);
   end
   
    
   if isempty(line_h3)
        warning('Burg internal line has been already removed');
   else
        delete_line(line_h3);
   end
   
   add_line(subsystem,'signal_i/1','filterd_o/1','autorouting','on');
else
    
    error('suppressio filter can be only on or off,actual is %s',suppression_filter);
    
end


%%%%%SPREADER

WM.Sim.Encoder.Spreader.seed_code_real    =   44;
WM.Sim.Encoder.Spreader.alg_code_real    =   'shr3cong';
WM.Sim.Encoder.Spreader.Gain              = 1;
if strcmp(WM.Sim.Switch_ctrl.Spreading_code,'random')
    WM.Sim.Encoder.Spreader.Switch              = 1;
elseif strcmp(WM.Sim.Switch_ctrl.Spreading_code,'trivial')
    WM.Sim.Encoder.Spreader.Switch              = 0;
else
   error('Spreading mode unknown'); 
end
%%% TX PARAMS

if strcmp(WM.Sim.Switch_ctrl.Pow_ctrl,'on')
    
    WM.Sim.Encoder.Pow_ctrl.Switch = 1;
    
elseif strcmp(WM.Sim.Switch_ctrl.Pow_ctrl,'off')
    
    WM.Sim.Encoder.Pow_ctrl.Switch = 0;
    
else
    error('pow ctrl mode unknown');
end

WM.Sim.Encoder.TxFilter.desired_latency = 3*WM.Sim.Encoder.SF;
if mod(WM.Sim.Encoder.TxFilter.desired_latency,WM.Sim.Encoder.SF)~=0
    
    error(' Tx-Rx filter latency %f must be multiple of SF for easy delay compensation for BER estimate',WM.Sim.Encoder.TxFilter.desired_latency);
end
if mod(WM.Sim.Encoder.TxFilter.order,2)==1 
    
   warning('Filter order %f odd , ensure delay compensation is correct',WM.Sim.Encoder.TxFilter.order);
end
if mod(WM.Sim.Encoder.TxFilter.order,WM.Sim.Encoder.Oversampling_factor*2)~=0
    
   error('Make filter order integer multiple of  WM.Sim.Encoder.Oversampling_factor*2=%d',WM.Sim.Encoder.Oversampling_factor*2);
end

WM.Sim.Encoder.TxFilter.Gain  =  1;
WM.Sim.Encoder.TxFilter.OversamplingFactor = WM.Sim.Encoder.Oversampling_factor;
WM.Sim.Encoder.TxFilter.GroupDelay = WM.Sim.Encoder.TxFilter.order /2/WM.Sim.Encoder.Oversampling_factor;
WM.Sim.Encoder.TxFilter.RollOffFactor = 0.2;
WM.Sim.Encoder.TxFilter.Latency_compensation = WM.Sim.Encoder.TxFilter.desired_latency-WM.Sim.Encoder.TxFilter.GroupDelay;
% WM.Sim.Encoder.TxFilter.Delay = WM.Sim.Encoder.TxFilter.GroupDelay*WM.Sim.Encoder.TxFilter.OversamplingFactor;
%WM.Sim.Encoder.TxFilter.Delay*2;

%%%% UPCONVERTER

WM.Sim.Upconverter.CosGain =  1;
WM.Sim.Upconverter.SinGain = -WM.Sim.Upconverter.CosGain;
WM.Sim.Upconverter.Seed_hopping = 55;
if strcmp(WM.Sim.Switch_ctrl.hopping,'off')
    WM.Sim.Upconverter.hopping_div_vact = 1; %patch when hopping_div_vact=Inf but hopping='off' 2 FIX in Random Source Sample Time
elseif strcmp(WM.Sim.Switch_ctrl.hopping,'on')
    WM.Sim.Upconverter.hopping_div_vact = round(WM.Sim.Fs_audio/WM.Sim.Upconverter.hopping_frequency);
    if isinf(WM.Sim.Upconverter.hopping_div_vact)
        error('hopping_div_fact Infinite');
    end
else
    error('Hopping switch unknown !!!!!');
end


if strcmp (WM.Sim.Switch_ctrl.hopping,'on')
    WM.Sim.Upconverter.hopping_switch = 0;
elseif strcmp (WM.Sim.Switch_ctrl.hopping,'off')
    WM.Sim.Upconverter.hopping_switch = 1;
else
    error('hopping undefined');
end


%%%CHANNEL PARAMS

WM.Sim.Channel.AWGN_Custom.seed_noise_real               = 33;
% WM.Sim.Channel.AWGN_Custom.alg_noise_real                = 'shr3cong';
WM.Sim.Channel.AWGN_Custom.seed_noise_imag               = 22;
% WM.Sim.Channel.AWGN_Custom.alg_noise_imag                = 'shr3cong';

WM.Sim.Channel.Pb_BPSK_AWGN             = theoretic_BPSK((WM.Sim.Channel.Eb_N0_dB));
if WM.Sim.Frame_len>1
WM.Sim.Channel.Code_delay = 2*WM.Sim.Encoder.TxFilter.desired_latency+WM.Sim.Frame_len;%WM.Sim.Encoder.TxFilter.GroupDelay;
else
   WM.Sim.Channel.Code_delay = 2*WM.Sim.Encoder.TxFilter.desired_latency;
end

if strcmp(WM.Sim.Switch_ctrl.Jammer_type,'noise')
    WM.Sim.Channel.Switch = 1;
elseif strcmp(WM.Sim.Switch_ctrl.Jammer_type,'audio')
    WM.Sim.Channel.Switch = 0;
else
    error('unknown switch value');
end

%%%%%%%%%%%%%%%%%%%%%%CHANNEL STATISTICS

% [jammer_data, WM.WM.Sim.Channel.Jammer_fs] =audioread(WM.Sim.Channel.Jammer_source);
% if (WM.WM.Sim.Channel.Jammer_fs ~=(1/WM.Sim.SampleTimes.Tchannel))
%     error(' Channel sample time not correct');
% end
% jammer_data_mono = jammer_data(:,1);
% jammer_data_integrated = zeros(1,fix(length(jammer_data_mono)/WM.Sim.Encoder.SF));
% 
% for i=1 : length(jammer_data_integrated)
%     
%     idx =  (i-1)*WM.Sim.Encoder.SF+1: (i)*WM.Sim.Encoder.SF;
%    jammer_data_integrated(i)=sum( jammer_data_mono(idx));
%     
% end
% 
% nbins = 5000;
% [nelements_data,xcenters_data]= hist(jammer_data_mono,nbins);
% norm_fact_data = sum(nelements_data);
% 
% [nelements_data_integrated,xcenters_data_integrated]=hist(jammer_data_integrated,nbins);
% norm_fact_data_integrated = sum(nelements_data_integrated);
% 
% figure('Name','Histogram of audio data');
% norm_elements_data = nelements_data./norm_fact_data;
% plot(xcenters_data,norm_elements_data);
% % histfit(jammer_data_mono,nbins);
% norm_elements_integrated = nelements_data_integrated./norm_fact_data_integrated;
% figure('Name','Histogram of audio data ID Over SF');
% plot(xcenters_data_integrated,norm_elements_integrated);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Input signal power for Simulink AWGN Block (SNR varia modificando Noise)
WM.Sim.Channel.AWGN.IN_Signal_pow=0.94;
%%& Input signal power for Simulink AWGN Custom Block (SNR varia modificando Signal)
WM.Sim.Channel.AWGN_Custom.Noise_reference_pow = 1;
WM.Sim.Channel.AWGN_Custom.Noise_amp_r=sqrt(WM.Sim.Channel.AWGN_Custom.Noise_reference_pow/2);
WM.Sim.Channel.AWGN_Custom.Noise_amp_i=sqrt(WM.Sim.Channel.AWGN_Custom.Noise_reference_pow/2);

%     N_Pow_db = 10*log10(WM.Sim.Channel.AWGN_Custom.Noise_reference_pow);
%     
Es_N0_dB =  WM.Sim.Channel.Eb_N0_dB  + 10*log10(WM.Sim.bit_x_symbol);
WM.Sim.Channel.AWGN_Custom.SNR_dB = Es_N0_dB - 10*log10(WM.Sim.Encoder.Oversampling_factor*WM.Sim.Encoder.SF);
%     Sig_pow_db = N_Pow_db + SNR_dB;
%     Sig_pow = 10^(Sig_pow_db/10);
%     Sig_amp = sqrt(Sig_pow);
    
WM.Sim.SNR_Calc.Scope.Data_history_len = 50000;
WM.Sim.Probe_system.Histogram.low_limit    = -2;%-WM.Sim.Encoder.SF;
WM.Sim.Probe_system.Histogram.high_limit    = +2;%+WM.Sim.Encoder.SF;
WM.Sim.Probe_system.Histogram.nbins    = 2*WM.Sim.Encoder.SF;
WM.Sim.Probe_system.RX_spreading.data_history_len = 100000;

%%%%BANDPASS


% WM.Sim.Decoder.Bandpass.desired_latency  = WM.Sim.Encoder.Oversampling_factor*WM.Sim.Encoder.SF;
% WM.Sim.Decoder.Bandpass.grpdel = 156;
% 
% if WM.Sim.Decoder.Bandpass.desired_latency<WM.Sim.Decoder.Bandpass.grpdel
%    
%     error('Correct the filter order');
% end
% 
% WM.Sim.Decoder.Bandpass.margin = 500;
% 
% WM.Sim.Decoder.Bandpass.f1 = WM.Sim.Encoder.Carrier_Freq-WM.Sim.Encoder.Tx_BW-WM.Sim.Decoder.Bandpass.margin;
% WM.Sim.Decoder.Bandpass.f2 = WM.Sim.Encoder.Carrier_Freq+WM.Sim.Encoder.Tx_BW+WM.Sim.Decoder.Bandpass.margin;
% WM.Sim.Decoder.Bandpass.delta_band_f = WM.Sim.Encoder.Tx_BW+WM.Sim.Decoder.Bandpass.margin;
% 
% % order = 512;
% % WM.Sim.Decoder.Bandpass.Hd = bandpass_filt_order(1/WM.Sim.SampleTimes.Tchannel,order,WM.Sim.Encoder.Carrier_Freq-WM.Sim.Encoder.Tx_BW-WM.Sim.Decoder.Bandpass.margin,...
% %      WM.Sim.Encoder.Carrier_Freq-WM.Sim.Encoder.Tx_BW,WM.Sim.Encoder.Carrier_Freq+WM.Sim.Encoder.Tx_BW,WM.Sim.Encoder.Carrier_Freq+WM.Sim.Encoder.Tx_BW+WM.Sim.Decoder.Bandpass.margin);
% 
% WM.Sim.Decoder.Bandpass.compensation_delay = WM.Sim.Decoder.Bandpass.desired_latency-WM.Sim.Decoder.Bandpass.grpdel;
% % WM.Sim.Decoder.Lowpass.Delay = WM.Sim.Decoder.Lowpass.Hd.order/2;
% 
% WM.Sim.Decoder.Spreader.Latency = WM.Sim.Decoder.Bandpass.desired_latency/WM.Sim.Encoder.Oversampling_factor;

%Suppression filter


% WM.Sim.SuppFilt.delay = WM.Sim.SuppFilt.order/2;
 WM.Sim.IntDump.AddictionalOffset = 0;%WM.Sim.Frame_len+WM.Sim.SuppFilt.delay;

if strcmp(WM.Sim.Switch_ctrl.suppression_filter,'on')
    WM.Sim.SuppFilt.tx_delay =0;%WM.Sim.SuppFilt.delay/ WM.Sim.Encoder.SF;
    WM.Sim.SuppFilt.Switch = 1;
    
elseif strcmp(WM.Sim.Switch_ctrl.suppression_filter,'off')
    WM.Sim.SuppFilt.tx_delay=0;
    WM.Sim.SuppFilt.Switch = 0;
 
else
    
    error('Suppression filter not set');
end

%%%%%%%%%%%%%%%%%%%%%%%%

%%%Calcolo dei delay in tempo 

WM.Sim.FrameTimes.Tsource   = WM.Sim.Encoder.Source_Ts*WM.Sim.Frame_len;
WM.Sim.FrameTimes.Tcoded   = WM.Sim.FrameTimes.Tsource*WM.Sim.FEC_ratio;
WM.Sim.FrameTimes.Tspreader = WM.Sim.FrameTimes.Tcoded/WM.Sim.Encoder.SF;
WM.Sim.FrameTimes.Tchannel = 1/WM.Sim.Fs_audio*WM.Sim.Frame_len;
WM.Sim.FrameTimes.TFEC = WM.Sim.FrameTimes.Tsource*WM.Sim.Message_length/WM.Sim.Frame_len;
WM.Sim.FrameTimes.TFEC_decod = WM.Sim.FrameTimes.Tcoded*WM.Sim.Codeword_length/WM.Sim.Frame_len;
%%%%%%%%%%%Time delays%%%%%%%%%%%%%%
%%%FEC coder
if ( mod(WM.Sim.Frame_len,WM.Sim.Message_length)==0)
    Fec_Timedelay_buf1 = 0;
else
    Fec_Timedelay_buf1 = WM.Sim.FrameTimes.TFEC;%0.798
end

    Fec_Timedelay_fec  = 0;

if (mod(WM.Sim.Codeword_length,WM.Sim.Frame_len)==0)
    FEc_Timedelay_buf2 = 0;
else
    FEc_Timedelay_buf2 = WM.Sim.FrameTimes.Tcoded;%0
end
WM.Sim.FEC.Time_delay = Fec_Timedelay_buf1+Fec_Timedelay_fec+FEc_Timedelay_buf2;
%%%TX Chain
TX_chain_Timedelay=WM.Sim.Encoder.TxFilter.desired_latency*WM.Sim.SampleTimes.Tspreader;
WM.Sim.Tx_chain.Time_delay = TX_chain_Timedelay;
%%%RX Chain
RX_chain_Timedelay=TX_chain_Timedelay;
WM.Sim.Rx_chain.Time_delay = RX_chain_Timedelay;

%FEC decoder
if ( mod(WM.Sim.Frame_len,WM.Sim.Codeword_length)==0)
    
    Fecdecod_Timedelay_buf1=0;
    
else
    Fecdecod_Timedelay_buf1 = WM.Sim.FrameTimes.TFEC_decod;%0.791
end

    Fecdecod_Timedelay_fecdecod  = 0;


     if (mod(WM.Sim.Message_length,WM.Sim.Frame_len)==0)
         
         FEcdecod_Timedelay_buf2=0;
     else
        FEcdecod_Timedelay_buf2 = WM.Sim.FrameTimes.Tsource;
     end

WM.Sim.FEC_decod.Time_delay = Fecdecod_Timedelay_buf1+Fecdecod_Timedelay_fecdecod+FEcdecod_Timedelay_buf2;

%Code align
if (strcmp(fec,'on'))
    if (WM.Sim.Frame_len==1)
        Code_align_Timedelay = (WM.Sim.FrameTimes.TFEC_decod)-mod(FEc_Timedelay_buf2+WM.Sim.Tx_chain.Time_delay+WM.Sim.Rx_chain.Time_delay+Fecdecod_Timedelay_buf1+WM.Sim.SampleTimes.Tcoded,WM.Sim.FrameTimes.TFEC_decod);
    else
       
            Code_align_Timedelay = (WM.Sim.FrameTimes.TFEC_decod)-mod(FEc_Timedelay_buf2+WM.Sim.Tx_chain.Time_delay+WM.Sim.Rx_chain.Time_delay+Fecdecod_Timedelay_buf1+WM.Sim.FrameTimes.Tcoded+WM.Sim.SampleTimes.Tcoded,WM.Sim.FrameTimes.TFEC_decod);
        
    end
else
    Code_align_Timedelay = 0;%(WM.Sim.FrameTimes.TFEC_decod)-mod(FEc_Timedelay_buf2+WM.Sim.Tx_chain.Time_delay+WM.Sim.Rx_chain.Time_delay+Fecdecod_Timedelay_buf1+WM.Sim.FrameTimes.Tcoded,WM.Sim.FrameTimes.TFEC_decod);
end;
WM.Sim.Fec_decod_delay_comp.Time_delay = Code_align_Timedelay;



tol=1e-10;
%latencies evaluated at coderate
WM.Sim.FEC.delay_coderate = WM.Sim.FEC.Time_delay/WM.Sim.SampleTimes.Tcoded;
WM.Sim.FEC.delay_coderate =check_integer(WM,'WM.Sim.FEC.delay_coderate','tolerance',tol,'warning');

WM.Sim.Tx_chain.delay_coderate=WM.Sim.Tx_chain.Time_delay/WM.Sim.SampleTimes.Tcoded;
WM.Sim.Tx_chain.delay_coderate=check_integer(WM,'WM.Sim.Tx_chain.delay_coderate','tolerance',tol,'warning');

WM.Sim.Rx_chain.delay_coderate=WM.Sim.Rx_chain.Time_delay/WM.Sim.SampleTimes.Tcoded;
WM.Sim.Rx_chain.delay_coderate=check_integer(WM,'WM.Sim.Rx_chain.delay_coderate','tolerance',tol,'warning');

WM.Sim.Fec_decod_delay_comp.delay_coderate=WM.Sim.Fec_decod_delay_comp.Time_delay/WM.Sim.SampleTimes.Tcoded;
WM.Sim.Fec_decod_delay_comp.delay_coderate=check_integer(WM,'WM.Sim.Fec_decod_delay_comp.delay_coderate','tolerance',tol,'warning');

WM.Sim.FEC_decod.delay_coderate=WM.Sim.FEC_decod.Time_delay/WM.Sim.SampleTimes.Tcoded;
WM.Sim.FEC_decod.delay_coderate=check_integer(WM,'WM.Sim.FEC_decod.delay_coderate','tolerance',tol,'warning');

WM.Sim.addictional_latency_coderate=1;
%latencies evaluated at sourcerate
WM.Sim.FEC.delay_sourcerate = WM.Sim.FEC.Time_delay/WM.Sim.SampleTimes.Tsource;
% check_integer(WM,'WM.Sim.FEC.delay_sourcerate','exact',0,'warning');

WM.Sim.Tx_chain.delay_sourcerate=WM.Sim.Tx_chain.Time_delay/WM.Sim.SampleTimes.Tsource;
% check_integer(WM,'WM.Sim.Tx_chain.delay_sourcerate','exact',0,'warning');

WM.Sim.Rx_chain.delay_sourcerate=WM.Sim.Rx_chain.Time_delay/WM.Sim.SampleTimes.Tsource;
% check_integer(WM,'WM.Sim.Rx_chain.delay_sourcerate','exact',0,'warning');

WM.Sim.Fec_decod_delay_comp.delay_sourcerate=WM.Sim.Fec_decod_delay_comp.Time_delay/WM.Sim.SampleTimes.Tsource;
% check_integer(WM,'WM.Sim.Fec_decod_delay_comp.delay_sourcerate','exact',0,'warning');

WM.Sim.FEC_decod.delay_sourcerate=WM.Sim.FEC_decod.Time_delay/WM.Sim.SampleTimes.Tsource;
% check_integer(WM,'WM.Sim.FEC_decod.delay_sourcerate','exact',0,'warning');
WM.Sim.addictional_latency_sourcerate=WM.Sim.addictional_latency_coderate*WM.Sim.FEC_ratio;


if (WM.Sim.Fec_decod_delay_comp.delay_coderate==0)
  type='bypass';
    subsystem = 'WM_Sim/FEC_decod_delay_comp';
    block_name = 'Delay';
    block_params.name_str={};
    block_params.val_str={};
    block_params.n_params=0;
    inport_name='inp_i';
    oport_name='out_o';
    library_name='Simulink/Discrete';
    add_or_bypass_SISO_block(type,subsystem,block_name,block_params,inport_name,oport_name,library_name);
    
else
    
    type='add';
    subsystem = 'WM_Sim/FEC_decod_delay_comp';
    block_name = 'Delay';
    block_params.name_str={'DelayLength','InputProcessing'};
    block_params.val_str={num2str(WM.Sim.Fec_decod_delay_comp.delay_coderate),'Columns as channels (frame based)'};
    block_params.n_params=length(block_params.name_str);
    inport_name='inp_i';
    oport_name='out_o';
    library_name='Simulink/Discrete';
    add_or_bypass_SISO_block(type,subsystem,block_name,block_params,inport_name,oport_name,library_name);
    
end


 if WM.Sim.Frame_len==1
%    WM.Sim.Tx_delay_eq_coderate = addictional_latency_coderate+tx_filt_latency_coderate+rx_filt_latency_coderate+WM.Sim.decoder_data_align;
%     WM.Sim.Tx_delay_eq = WM.Sim.Tx_delay_eq_coderate*WM.Sim.FEC_ratio+ WM.Sim.FEC.delay+ WM.Sim.FEC_decod.delay;%+WM.Sim.Decoder.Bandpass.desired_latency/(WM.Sim.Encoder.Oversampling_factor*WM.Sim.Encoder.SF);%+WM.Sim.Decoder.Lowpass.Delay/(WM.Sim.SampleTimes.Tsource/WM.Sim.SampleTimes.Tspreader);
    WM.Sim.Tx_delay_eq_coderate = WM.Sim.addictional_latency_coderate+WM.Sim.Tx_chain.delay_coderate+WM.Sim.Rx_chain.delay_coderate+WM.Sim.Fec_decod_delay_comp.delay_coderate;
    WM.Sim.Tx_delay_eq = WM.Sim.addictional_latency_sourcerate+WM.Sim.FEC.delay_sourcerate+WM.Sim.Tx_chain.delay_sourcerate+WM.Sim.Rx_chain.delay_sourcerate+WM.Sim.Fec_decod_delay_comp.delay_sourcerate+WM.Sim.FEC_decod.delay_sourcerate;
 else
%     
%      delay_temp = addictional_latency_coderate+tx_filt_latency_coderate+rx_filt_latency_coderate+WM.Sim.decoder_data_align;
% %     WM.Sim.Tx_delay_eq_coderate =delay_temp +WM.Sim.Frame_len;
%      WM.Sim.Tx_delay_eqold =(delay_temp*WM.Sim.FEC_ratio)+fix(WM.Sim.Frame_len/WM.Sim.Encoder.SF)+ WM.Sim.FEC.delay+ WM.Sim.FEC_decod.delay;%+WM.Sim.Decoder.Bandpass.desired_latency/(WM.Sim.Encoder.Oversampling_factor*WM.Sim.Encoder.SF);%+WM.Sim.Decoder.Lowpass.Delay/(WM.Sim.SampleTimes.Tsource/WM.Sim.SampleTimes.Tspreader);  
    WM.Sim.Tx_delay_eq_coderate = WM.Sim.Frame_len+WM.Sim.addictional_latency_coderate+WM.Sim.Tx_chain.delay_coderate+WM.Sim.Rx_chain.delay_coderate+WM.Sim.Fec_decod_delay_comp.delay_coderate;

        WM.Sim.Tx_delay_eq =WM.Sim.Frame_len*WM.Sim.FEC_ratio+WM.Sim.addictional_latency_sourcerate+WM.Sim.FEC.delay_sourcerate+WM.Sim.Tx_chain.delay_sourcerate+WM.Sim.Rx_chain.delay_sourcerate+WM.Sim.Fec_decod_delay_comp.delay_sourcerate+WM.Sim.FEC_decod.delay_sourcerate;  

  end


WM.Sim.Tx_delay_eq_coderate=check_integer(WM,'WM.Sim.Tx_delay_eq_coderate','tolerance',tol,'error');
WM.Sim.Tx_delay_eq=check_integer(WM,'WM.Sim.Tx_delay_eq','tolerance',tol,'error');

% if ( mod(WM.Sim.Tx_delay_eq,1) ~=0)
%     
%    warning(' tx_filt_latency %f is a not integer and BER compensation cannot be done easily\n comment the line if you wanna run the sim without exact BER check',WM.Sim.Tx_delay_eq);
% end


close_system('WM_Sim',1);


