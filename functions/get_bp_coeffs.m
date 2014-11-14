function num = get_bp_coeffs (fs,grpdel,f1,f2)

B=(f2-f1)/fs; % calcola l'ampiezza complessiva della banda normalizzata a fs
%
% Calcola la risposta a 73 coefficienti, simmetrici intorno allo 0
% grpdel=512;
filter_length=grpdel*2+1;
h=zeros(1,filter_length);
%
for i=1:grpdel,
h(i+1+grpdel)=B*sin(pi*B*i)/(pi*B*i);
h(grpdel+1-i)=h(i+1+grpdel);
end
h(grpdel+1)=B;
%
%coefficienti del filtro
window=hanning(filter_length);
hfiltro=window'.*h;
norm=sum(hfiltro);
hfiltro=hfiltro/norm;

% figure
% plot(20*log10(abs(fft(hfiltro))));

Fc=(f1+f2)/2;
wc=2*pi*Fc;
time = 0:1/fs:length(hfiltro)*1/fs-1/fs;
num=hfiltro.*exp(wc*1i*time);

end