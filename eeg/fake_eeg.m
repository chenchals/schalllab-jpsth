
% From: https://www.researchgate.net/post/Do_you_know_any_fx_formulas_for_EEG-like_signal_generation
% Modified: Chenchal

% randomizer for repeatable results
rng('default'); % Mersenne Twister with seed 0
% Frequency params
fMin = 0;
fMax = 100;
nSines = 100;
Fs = linspace(fMin,fMax,nSines)';
% time params
minT = 0;
maxT = 1;
sampleRate = 1000;
ts = linspace(minT,maxT,sampleRate*maxT);
randomizePhase = false;
% random phase difference times
% when starting at 0 deg phase, peaks of sine waves
% pd = 1./Fs; %period of sine waves
% peaksAt = pd./1; % in seconds
% t = t - peaksAt;
if randomizePhase
    t = arrayfun(@(x) randsample(ts,length(ts)),(1:nSines)','UniformOutput',false);
    t = cell2mat(t);
else
    t = repmat(ts,nSines,1);
end

% amplitudes - Currently random for number of sines
As = rand(nSines,1);
%As = ones(nSines,1);
% time varying amplitute scaling - 
% currently set to 1 for all sine waves across time
As_scaling = ones(size(t));
% time varying sine waves
YComponents = (As.*As_scaling).*sin(2*pi*(Fs.*t));
% summed amplitudes of all sine waves
Y = sum(YComponents);
figure
 plot(ts(1,:),Y);
% hold on
% plot(ts(1,:),YComponents(1:end,:))
% hold off
