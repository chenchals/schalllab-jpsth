function [ outputArg ] = burstTimes2Raster( bobt, eobt, timeWin )
%BURSTTIMES2RASTER Make a 0s and 1s vector for each pair of burst times
%   Creates a zeros vector the  length of range of timeWin bins
%   For every time-bin, add 1 if the time-bin is in burst duration
    dTimeBins = min(timeWin):max(timeWin);
    burstTimes = arrayfun(@(b,e) find(dTimeBins>=b & dTimeBins<=e),bobt,eobt,'UniformOutput',false);
    burstTimes = [burstTimes{:}];
    outputArg = zeros(1,numel(dTimeBins));
    outputArg(burstTimes) = 1; 
end

