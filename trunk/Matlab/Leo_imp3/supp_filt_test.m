clear all; close all;clc

addpath ./functions/

%%%ppression filter test

% b = fir1(20,0.2);

a = [1,-0.3,+0.005];

figure('name','Freq resp AR'); 
freqz(1,a);

input = [1,zeros(1,100)];%sin(2*pi*0.4*(1:100));


out1 = filter(1,a,input);


out2 = filter(a,1,out1);

figure('name','Freq resp AR inverse'); 
freqz(a,1);

figure('Name','out filter')
stem(out1);
figure('Name','out filter inverse')
stem(out2);


figure('Name','out filter 1-a')
freqz(1-a,1);