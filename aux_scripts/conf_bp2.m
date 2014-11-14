%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%        generazione filtri  BP(down-upconversion) demon
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;close all;clc

fs =  44100;

f1= 987.5000;
f2= 1.3012e+04;
% Sintesi di filtro passa basso su banda scelta da operatore
%
B=(f2-f1)/fs; % calcola l'ampiezza complessiva della banda normalizzata a fs
%
% Calcola la risposta a 73 coefficienti, simmetrici intorno allo 0
ncoeff=512;
filter_length=ncoeff*2+1;
h=zeros(1,filter_length);
%
w1=2*pi*f1/fs;
w2=2*pi*f2/fs;
for ii=1:ncoeff,
h(ii+1+ncoeff)=(sin(w2*ii)-sin(w1*ii))/(pi*ii);
h(ncoeff+1-ii)=h(ii+1+ncoeff);
end
h(ncoeff+1)=(w2-w1)/pi;

f_axe = 0 : fs/(filter_length-1) : fs;
%
%coefficienti del filtro

window=hanning(filter_length);
hfiltro_win=window'.*h;
norm=sum(hfiltro_win);

hfiltro_norm=hfiltro_win;

figure
plot(f_axe,20*log10(abs(fft(hfiltro_norm))));
figure
plot(f_axe,unwrap(angle(fft(hfiltro_norm))));
% Fc=(f1+f2)/2;
% wc=2*pi*Fc;
% time = 0:1/fs:length(hfiltro)*1/fs-1/fs;
% BP_filter_demon=hfiltro.*exp(wc*1i*time);
% 
% figure
% plot(20*log10(abs(fft(BP_filter_demon))));
% figure
% plot(unwrap(angle(fft(BP_filter_demon))));

