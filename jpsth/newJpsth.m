function [outVar, jpsthStruct] = newJpsth(alignedSpkTimes,timeWindow,binWidth,coincidenceBins)
%NEWJPSTH Compute rasters, psth, normalizedJPSTH, xCorrHistogram, coincidenceHistogram
%   alignedSpkTimes: Cell array of {nTrials, kCells} - Aligned spike times of all cells
%                    Example Data: alignedSpkTimes = SpikeTimes.saccade;


minTime = min(timeWindow);
maxTime = max(timeWindow);
coinBins = coincidenceBins;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

timeBins = minTime:binWidth:maxTime;
binEdges = minTime-binWidth/2 : binWidth : maxTime+binWidth/2;
% Function handle for rasters
fx_rasters = @(c) cell2mat(cellfun(@(x) histcounts(x,'BinEdges',binEdges),...
                   c,'UniformOutput',false));
fx_psth = @(rast,binWidth,fx) fx(cell2mat(rast))./binWidth;
% Cross correlation histogram for -lag:lag bins of JPSTH
fx_xcorrh = @(jpsth,lagBins)...
    [-abs(lagBins):abs(lagBins);arrayfun(@(x) mean(diag(jpsth,x)),...
    -abs(lagBins):abs(lagBins))]';
% Coincidence Histogram
fx_coinh = @getCoincidence;

nBins = numel(timeBins);
nTrials = size(alignedSpkTimes,1);
nCells = size(alignedSpkTimes,2);
pairs = nchoosek(1:nCells,2);
nPairs = size(pairs,1);

% Make all vars matlab arrays (single), in case we need to use gpu  processing
rasters = arrayfun(@(x) fx_rasters(x),alignedSpkTimes,'UniformOutput',false);
% Convert rasters of {nTrials, kCells} to {kCells} 
% each cell is a double [nTrials, nBins]
rasters = arrayfun(@(x) cell2mat(rasters(:,x)),(1:nCells)','UniformOutput',false);  

% Compute PSTH stats
psth = (arrayfun(@(x) fx_psth(rasters(x),binWidth,@mean), (1:nCells)','UniformOutput',false));
psthSd = (arrayfun(@(x) fx_psth(rasters(x),binWidth,@std), (1:nCells)','UniformOutput',false));

tic

for i = 1:nPairs
    temp = struct();
    if mod(i,100)
        fprintf('.');
    else
        fprintf('. %d\n',i);
    end
    xCell = pairs(i,1);
    yCell = pairs(i,2);
    xRasters = rasters{xCell};
    yRasters = rasters{yCell};
    xPsth = psth{xCell};
    yPsth = psth{yCell};
    xPsthSd = psthSd{xCell};
    yPsthSd = psthSd{yCell};
    
    % JPSTH Equations from Aertsen et al. 1989
    % Note bins [1,1] is top-left and [n,n] is bottom-right
    temp.rawJpsth = (xRasters'*yRasters)/(nTrials*binWidth^2); % Eq. 3
    predicted = xPsth' * yPsth;			                  % Eq. 4
    unnormalizedJpsth = temp.rawJpsth - predicted;             % Eq. 5
    normalizer = xPsthSd' * yPsthSd;                      % Eq. 7a
    temp.normJpsth = unnormalizedJpsth ./ normalizer;          % Eq. 9
    temp.normJpsth(isnan(temp.normJpsth)) = 0;
    % lagBins for xCorr 
    temp.xCorrHist = fx_xcorrh(temp.normJpsth,floor(numel(timeBins)/2));
    % Coincidence Hist
    temp.coinHist = fx_coinh(temp.normJpsth,coincidenceBins);
    % add to output struct
    jpsthStruct(i)=temp;    
end

toc

outVar.binWidth = binWidth;
outVar.timeBins = timeBins;
outVar.coincidenceLag = coincidenceBins*binWidth;
outVar.cellPairs = pairs;
outVar.rasters = rasters;
outVar.psth = psth;
outVar.psthSd = psthSd;
outVar.jpsth = jpsthStruct;
% save fx for callin on output
outVar.smoothFx = @(v,nPoints,sigma) convn(v,...
              normpdf(-floor(nPoints/2):floor(nPoints/2),0,sigma)...
              ,'same');



%% For testing with Jeremiah Cohen's code 2008
% tic
% for i = 1:1 %size(pairs,1)
%     i1 = pairs(i,1);
%     i2 = pairs(i,2);
%     jeromiah(i) = jpsth(rasters(:,:,i1),rasters(:,:,i2),10);
%     rawJPSTH1 = equation3(rasters(:,:,i1),rasters(:,:,i2));						% Eq. 3 
% 	psthOuterProduct1 = jeromiah(i).psth_1(:) * jeromiah(i).psth_2(:)';			% Eq. 4
% 	unnormalizedJPSTH1 = rawJPSTH1 - psthOuterProduct1;	% Eq. 5
% 	normalizer1 = jeromiah(i).psth_1_sd(:) * jeromiah(i).psth_2_sd(:)';			% Eq. 7a
% 	normalizedJPSTH1 = unnormalizedJPSTH1 ./ normalizer1;
% end
% toc




end

