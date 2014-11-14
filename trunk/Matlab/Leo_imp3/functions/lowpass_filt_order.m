function Hd = lowpass_filt_order(Fs,N,Fc)
%LOWPASS_FILT_ORDER Returns a discrete-time filter object.

% MATLAB Code
% Generated by MATLAB(R) 8.1 and the DSP System Toolbox 8.4.
% Generated on: 03-May-2014 04:44:27

% FIR Window Lowpass filter designed using the FIR1 function.

% All frequency values are in Hz.
% Fs = 48000;  % Sampling Frequency

% N    = 10;       % Order
% Fc   = 10800;    % Cutoff Frequency
flag = 'scale';  % Sampling Flag
Beta = 0.5;      % Window Parameter

% Create the window vector for the design algorithm.
win = kaiser(N+1, Beta);

% Calculate the coefficients using the FIR1 function.
b  = fir1(N, Fc/(Fs/2), 'low', win, flag);
Hd = dsp.FIRFilter( ...
    'Numerator', b);

% [EOF]
