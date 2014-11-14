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
for ii=1:ncoeff,
h(ii+1+ncoeff)=B*sin(pi*B*ii)/(pi*B*ii);
h(ncoeff+1-ii)=h(ii+1+ncoeff);
end
h(ncoeff+1)=B;
%
%coefficienti del filtro
window=hanning(filter_length);
hfiltro=window'.*h;
norm=sum(hfiltro);
hfiltro=hfiltro/norm;

figure
plot(20*log10(abs(fft(hfiltro))));
figure
plot(unwrap(angle(fft(hfiltro))));
Fc=(f1+f2)/2;
wc=2*pi*Fc;
time = 0:1/fs:length(hfiltro)*1/fs-1/fs;
BP_filter_demon=hfiltro.*exp(wc*1i*time);

figure
plot(20*log10(abs(fft(BP_filter_demon))));
figure
plot(unwrap(angle(fft(BP_filter_demon))));

