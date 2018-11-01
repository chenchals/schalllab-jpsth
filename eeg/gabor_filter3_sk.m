function ...
    fs=gabor_filter3_sk(rs,srate,vk,sk)

% function ...
%     fs=gabor_filter3_sk(rs,srate,vk,sk);
%
% input --
%     rs: 1xN real-valued time series of raw signal
%     srate: number of samples per second
%     vk: mean frequency value of gaussian envelope of Gabor time-frequency atom
%     sk: bandwidth parameter
%
% output --
%     fs: 1xN complex-valued time series of filtered signal

Nt=length(rs);
Nv=2^ceil(log2(Nt));

v=single((srate/Nv)*(0:Nv-1));
inds=(v>(srate/2));
v(inds)=v(inds)-srate;

rs_fd=fft(rs,Nv);
rs_fd(v<0)=0;
rs_fd(v>0)=2*rs_fd(v>0);

Gk=exp(-pi*exp(sk)*(v-vk).^2); % un-normalized
Gk=Gk*(sqrt(length(v))/norm(Gk)); % because of discrete sampling and different time/freq sample numbers

fs_fd=rs_fd.*Gk;
fs=ifft(fs_fd,Nv);
fs=fs(1:Nt);

end







