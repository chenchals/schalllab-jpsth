function [outVar, jpsthTable] = newJpsth(alignedSpkTimes,unitNames,timeWindow,binWidth,coinBins)
%NEWJPSTH Compute rasters, psth, normalizedJPSTH, xCorrHistogram, coincidenceHistogram
%   alignedSpkTimes: Cell array of {nTrials, kCells} - Aligned spike times of all cells
%                    Example Data: alignedSpkTimes = SpikeTimes.saccade;
% Example:
% load('data/spikeTimes_saccAligned_sess14.mat');
% [oVar, oJpsth]=newJpsth(SpikeTimes.saccade,[-200 1000],1,10);

minTime = min(timeWindow);
maxTime = max(timeWindow);
coincidenceBins = coinBins;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

binEdges = minTime-binWidth/2 : binWidth : maxTime+binWidth/2;

%% Define function handles to call %%
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
%% Compute pairs to be usedfor JPSTH %%
timeBins = minTime:binWidth:maxTime;
nTrials = size(alignedSpkTimes,1);
nCells = size(alignedSpkTimes,2);
pairs = nchoosek(1:nCells,2);
nPairs = size(pairs,1);

%% Compute Rasters and psth stats for all cells %%
% Make all vars matlab arrays (single), in case we need to use gpu  processing
rasters = arrayfun(@(x) fx_rasters(x),alignedSpkTimes,'UniformOutput',false);
% Convert rasters of {nTrials, kCells} to {kCells} 
% each cell is a double [nTrials, nBins]
rasters = arrayfun(@(x) cell2mat(rasters(:,x)),(1:nCells)','UniformOutput',false);  

% Compute PSTH stats
psth = (arrayfun(@(x) fx_psth(rasters(x),binWidth,@mean), (1:nCells)','UniformOutput',false));
psthSd = (arrayfun(@(x) fx_psth(rasters(x),binWidth,@std), (1:nCells)','UniformOutput',false));

%% Compute JPSTH for each pair %%
tic
for i = 1:nPairs
    temp = struct();
    if mod(i,100)
        fprintf('.');
    else
        fprintf('. %d\n',i);
    end
    temp.xCellId = unitNames{pairs(i,1)};
    temp.yCellId = unitNames{pairs(i,2)};
    temp.xCellNo = pairs(i,1);
    temp.yCellNo = pairs(i,2);
    temp.timeBins = {minTime:binWidth:maxTime};
    temp.xRasters = rasters{temp.xCellNo};
    temp.yRasters = rasters{temp.yCellNo};
    temp.xPsth = psth(temp.xCellNo);
    temp.yPsth = psth(temp.yCellNo);
    temp.xPsthSd = psthSd(temp.xCellNo);
    temp.yPsthSd = psthSd(temp.yCellNo);
    temp.nTrials = nTrials;
    temp.binWidth = binWidth;
    temp.coincidenceBins = coincidenceBins;
    % JPSTH Equations from Aertsen et al. 1989
    % Note bins [1,1] is top-left and [n,n] is bottom-right
    temp.rawJpsth = (temp.xRasters'*temp.yRasters)/(nTrials*binWidth^2); % Eq. 3
    predicted = temp.xPsth{1}' * temp.yPsth{1};			           % Eq. 4
    unnormalizedJpsth = temp.rawJpsth - predicted;             % Eq. 5
    normalizer = temp.xPsthSd{1}' * temp.yPsthSd{1};                           % Eq. 7a
    temp.normJpsth = unnormalizedJpsth ./ normalizer;          % Eq. 9
    temp.normJpsth(isnan(temp.normJpsth)) = 0;
    % lagBins for xCorr 
    temp.xCorrHist = fx_xcorrh(temp.normJpsth,floor(numel(timeBins)/2));
    % Coincidence Hist
    temp.coinHist = fx_coinh(temp.normJpsth,coincidenceBins);
    % add to output struct
    jpsthTable(i)=temp;    
end
toc
jpsthTable = struct2table(jpsthTable);
outVar.jpsth = jpsthTable;
% save fx for callin on output
outVar.smoothFx = @(v,nPoints,sigma) convn(v,...
              normpdf(-floor(nPoints/2):floor(nPoints/2),0,sigma),'same');

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

