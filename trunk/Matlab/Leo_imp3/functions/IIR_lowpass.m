function Hd = IIR_lowpass(N,F3dB)
%IIR_LOWPASS Returns a discrete-time filter System object.

% MATLAB Code
% Generated by MATLAB(R) 8.1 and the DSP System Toolbox 8.4.
% Generated on: 09-May-2014 17:46:03

% N    = 2;    % Order
% F3dB = 0.2;  % 3-dB Frequency

h = fdesign.lowpass('n,f3db', N, F3dB);

Hd = design(h, 'butter', ...
    'SystemObject', true);



