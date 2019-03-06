%% using 3 rd butterworth filtering 
load '/database/BCICIV_calib_ds1a.mat '
signal=double(cnt);
Fs=100;
[b,a]=butter(3,[8 30]/(Fs/2),'bandpass'); 
signal=filter(b,a,signal);
