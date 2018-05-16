function ...
    filtered_signal=gabor_filter(raw_signal,sampling_rate,center_frequency,fractional_bandwidth)

% function ...
%     filtered_signal=gabor_filter(raw_signal,sampling_rate,center_frequency,fractional_bandwidth);
%
% input --
%     raw_LFP: 1xN real-valued time series of raw signal
%     sampling_rate: number of samples per second
%     center_frequency: mean frequency value of gaussian envelope of Gabor time-frequency atom
%     fractional_bandwidth: bandwidth parameter, frequency-domain standard deviation proportional to center_frequency*fractional_bandwidth
%
% output --
%     filtered_LFP: 1xN complex-valued time series of filtered signal

srate=sampling_rate;
v0=center_frequency;
fbw=fractional_bandwidth; % 0.25 is good default value, stay within 0.05-0.6

c0=0; % no chirp in chirplet -> reduces to gabor atom with gaussian envelope

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% from get_signal_parameters.m:
% initialize:
clear sp
sp.sampling_rate=srate;
sp.number_points_time_domain=length(raw_signal);
maxpower2=2^23; % to avoid out-of-memeory issues;
% check this on your machine, machine-specific threshold
if sp.number_points_time_domain<maxpower2
    sp.number_points_frequency_domain=2^ceil(log2(sp.number_points_time_domain)); % fixed parameter for computational ease
else
    sp.number_points_frequency_domain=sp.number_points_time_domain;
end
sp.time_step_size=1/sp.sampling_rate; % determined
sp.frequency_step_size=sp.sampling_rate/sp.number_points_frequency_domain; % determined
sp.time_support=sp.time_step_size*(0:sp.number_points_time_domain-1);
sp.time_support=single(sp.time_support);
sp.frequency_support=sp.frequency_step_size*(0:sp.number_points_frequency_domain-1); % determined
sp.frequency_support=single(sp.frequency_support);
inds=sp.frequency_support>(sp.sampling_rate/2);
sp.frequency_support(inds)=sp.frequency_support(inds)-sp.sampling_rate;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% from complete_chirplet_parameters.m
s0=log((2*log(2))/(fbw^2*pi*v0^2));
% start with new chirplet structure, reenter given parameters:
clear g
g.center_time=0;
g.center_frequency=v0;
g.duration_parameter=s0;
g.chirp_rate=0;
g.fractional_bandwidth=[];
g.time_domain_standard_deviation=[];
g.frequency_domain_standard_deviation=[];
g.time_frequency_covariance=[];
g.time_frequency_correlation_coefficient=[];
g.std_multiple_for_support=6;
% calculate other properties:
g.time_domain_standard_deviation=...
    sqrt(exp(s0)/(4*pi));
g.frequency_domain_standard_deviation=...
    sqrt((exp(-s0)+c0^2*exp(s0))/(4*pi));
g.time_frequency_covariance=(c0*exp(s0))/(4*pi);
g.time_frequency_correlation_coefficient=...
    g.time_frequency_covariance*(...
    g.time_domain_standard_deviation*...
    g.frequency_domain_standard_deviation)^-1;
g.fractional_bandwidth=2*sqrt(2*log(2))*...
    g.frequency_domain_standard_deviation/v0;% fwhm/center_frequency
% fwhm == full-width, half-max value for Gaussian function


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% from make_chirplet.m
% use short variable names for equations
t0=g.center_time;
v0=g.center_frequency;
s0=g.duration_parameter;
c0=g.chirp_rate;
tstd=g.time_domain_standard_deviation;
vstd=g.frequency_domain_standard_deviation;
% time support:
% shift g.center_time to fall on sp.time_support
if (g.center_time<sp.time_support(1))||... % before signal
        (g.center_time>sp.time_support(end)) % after signal
    g.center_time=mod(g.center_time,sp.time_support(end));
end
temp1=abs(sp.time_support-g.center_time);
[trash,center_index]=min(temp1); % sp.time_support index closest to g.center_time
numinds=length(0:...
    sp.time_step_size:...
    tstd*g.std_multiple_for_support);
support_inds=center_index+(-numinds:numinds);
support_inds=mod(support_inds,sp.number_points_time_domain);
support_inds(support_inds==0)=sp.number_points_time_domain;
g.signal_time_support_indices=support_inds;
g.time_support=sp.time_support(g.signal_time_support_indices);
t=sp.time_support(center_index)+...
    sp.time_step_size*(-numinds:numinds);
g.ptime=t;
% chirplet in time domain:
g.time_domain=2^(1/4)*exp(-s0/4)*... % normalizer for R (not Z)
    exp(-exp(-s0)*pi*(t-t0).^2).*... % amplitude envelope
    exp(2*pi*1i*v0*(t-t0)).*... % frequency modulation
    exp(pi*1i*c0*(t-t0).^2);    % linear frequency chirp
g.time_domain=g.time_domain/norm(g.time_domain); % need to normalize due to discrete sampling
% frequency support
v=sp.frequency_support; % in Hz
g.signal_frequency_support_indices=find(...
    (v0-g.std_multiple_for_support*vstd<=v)&...
    (v<=v0+g.std_multiple_for_support*vstd));
% shorten to include only chirplet support
v=v(g.signal_frequency_support_indices);
g.frequency_support=v;
g.pfrequency=g.frequency_support;
% chirplet in frequency domain:
Gk=2^(1/4)*sqrt(-1i*c0+exp(-s0))^-1*...
    exp(-s0/4+...
    (exp(s0)*pi*(v-v0).^2)/(-1+1i*c0*exp(s0)));
n1=sqrt(sp.number_points_frequency_domain)/norm(Gk);
Gk=n1*Gk; % because of discrete sampling and different time/freq sample numbers
g.filter=Gk; % at center time of zero, use this for convolution filtering
g.frequency_domain=Gk.*exp(-2*pi*1i*v*t0); % translation in time to tk





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% from make_signal_structure.m
s.frequency_domain=fft(raw_signal,...
    sp.number_points_frequency_domain);
if sum(abs(imag(raw_signal)))~=0 % signal already complex
    s.time_domain=raw_signal; % do not change
else
    s.time_domain=[];
    s.time_domain=ifft(s.frequency_domain,...
        sp.number_points_frequency_domain);
    s.time_domain=s.time_domain(...
        1:sp.number_points_time_domain);
    % this step scales analytic signal such that
    % real(analytic_signal)=raw_signal, but note that
    % analytic signal energy is double that of raw signal energy
    % sum(abs(raw_signal).^2)=0.5*sum(abs(s.time_domain).^2)
    s.frequency_domain(sp.frequency_support<0)=0;
    s.frequency_domain(sp.frequency_support>0)=...
        2*s.frequency_domain(sp.frequency_support>0);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% from filter_with_chirplet.m
%initialize
fs.time_domain=zeros(size(s.time_domain));
fs.frequency_domain=zeros(size(s.frequency_domain));
fs.frequency_domain(g.signal_frequency_support_indices)=...
    s.frequency_domain(g.signal_frequency_support_indices).*...
    g.filter;
fs.time_domain=ifft(fs.frequency_domain,sp.number_points_frequency_domain);
fs.time_domain=fs.time_domain(1:sp.number_points_time_domain);


% finish:
filtered_signal=fs.time_domain;


% USE filtered_signal above, but note that amplitude is not in same units as raw_signal
% that is, units not conserved
% (but filter is always unit-energy signal [discrete L2 norm])

% Below may conserve units (microvolts, etc), but needs to be verified
% % % normalize power levels, not needed if you just want phase or relative
% % % amplitude:
% % filtered_signal=filtered_signal/norm(filtered_signal);
% % weight=dot(raw_signal,filtered_signal);
% % filtered_signal=weight*filtered_signal;

