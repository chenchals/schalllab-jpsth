% http://www.translationalneuromodeling.org/tags/eeg/

EEG.srate = 1000;

nyquist = EEG.srate/2;
fLowerBound = 10; %10 Hz
fUpperBound = 30; %30 Hz
transitionWidth = 0.2;
fOrder = round(3*(EEG.srate/fLowerBound));
%%%%%%%%%%%%%%%Filter design%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      ______________________________________________
%      |           (3)-------(4)                    |
%      |           /           \                    |
%      |          /             \                   |  (y = Amplitude of filter)
%      |         /               \                  |  (x = Frequency as fraction of Nyquist)
%      |(1)-----(2)              (5)-------------(6)|
%      |____|____|____|____|____|____|____|____|____|
%      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create filter shape
ffrequencies = [0 (1-transitionWidth)*fLowerBound fLowerBound fUpperBound (1+transitionWidth)*fUpperBound nyquist]/nyquist;

for k = 1:4
    switch k
        case 1
            idealResponse = [0 0 1 1 0 0];
            fName = 'Band pass filtered';
        case 2
            idealResponse = [1 1 0 0 1 1];
            fName = 'Band stop filtered';
        case 3
            idealResponse = [1 1 0 0 0 0];
            fName = 'Low pass filtered';
        case 4
            idealResponse = [0 0 0 0 1 1];
            fName = 'High pass filtered';
    end
end

filterWeights = firls(fOrder, ffrequencies, idealResponse);

% apply filter kernel to obtain band pass filtered signal
filteredData = zeros(EEG.pnts);
filteredData(1,:) = filtfilt(filterWeights, 1, double(EEG.data(1,:,1)));

