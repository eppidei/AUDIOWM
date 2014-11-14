function Pb_BPSK=theoretic_BPSK(Eb_N0_dB)

%BPSK in AWGN
Eb_N0 = 10.^(Eb_N0_dB/10);
Q_arg2 = sqrt(2*Eb_N0);
fQ_arg2 = qfunc(Q_arg2);
Pb_BPSK =fQ_arg2;

%BPSK SS no coded Proakis pg. 775
% Q_arg_SS = (4*Processing_gain(z)/N_Pow/Sig_pow);
% Pb_SS = qfunc(Q_arg_SS);
% fprintf('Teoretichal SS BPSK BER = %f\n',Pb_SS);
            
end