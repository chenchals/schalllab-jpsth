% input is spiketimes or binned spike times

pairProcessed = load('/Volumes/schalllab/Users/Chenchal/JPSTH/FigsBinWidth_5B/PAIR_0005_D20130820002-RH_SEARCH_DSP10a_FEF_DSP17a_SC.mat');

condition = 'AccurateCorrect';
alignedEvent = 'CueOn';
rowId = find(strcmpi(pairProcessed.(condition).alignedEvent,alignedEvent));

xCell = pairProcessed.(condition).xCellSpikeTimes{rowId,1};
yCell = pairProcessed.(condition).yCellSpikeTimes{rowId,1};

binWidth = pairProcessed.(condition).binWidth(rowId);
alignedTimeWin = pairProcessed.(condition).alignedTimeWin{rowId};

% Correlations Without Synchrony Brody CD, Neural Computation 11, 1537?1551 (1999)

% Cross Corr for each trail
% Eq. 2.1


fx_hump_xcorr = @LIF_xcorr;
[rawHump.y,rawHump.bins,rawHump.f1,rawHump.f2,rawHump.num_pairs] = ...
                    cellfun(@(t1,t2) fx_hump_xcorr(t1,t2,binWidth,alignedTimeWin),...
                            xCell,yCell,'UniformOutput',false);
vectorize = @(x) x(:);
tDiff = @(t1,t2) vectorize((repmat(t1',1,numel(t2))-repmat(t2,numel(t1),1)));

[raw.y,raw.bins] = cellfun(@(t1,t2) hist(tDiff(t1,t2),...
                             (-diff(alignedTimeWin):binWidth:diff(alignedTimeWin))),...
                            xCell,yCell,'UniformOutput',false);
[raw.f1,raw.f2] = cellfun(@(t1,t2) deal(numel(t1)/diff(alignedTimeWin),numel(t2)/diff(alignedTimeWin)),...
                                   xCell,yCell,'UniformOutput',false);
   
                               
% For shuffle corrector:
fx_hump_psth = @LIF_psth;
%[y,x,var_psth] = LIF_psth(events,times,bin_size,T,varargin)
 
[psthXHump.y,psthXHump.x,psthXHump.var_psth] = cellfun(@(t1) fx_hump_psth(zeros(numel(t1),1)',t1,binWidth,alignedTimeWin,'m'),xCell,'UniformOutput',false);
[psthYHump.y,psthYHump.x,psthYHump.var_psth] = cellfun(@(t1) fx_hump_psth(zeros(numel(t1),1)',t1,binWidth,alignedTimeWin,'m'),yCell,'UniformOutput',false);

 
 xPsth = SpikeUtils.psth(xCell,binWidth,alignedTimeWin);
 yPsth = SpikeUtils.psth(yCell,binWidth,alignedTimeWin);
 
 %verify
 xpsthRawHump=cell2mat(psthXHump.y')';
 xpsthRawVarHump=cell2mat(psthXHump.var_psth')';
 
 xpsthRaw=xPsth.spikeCounts./351;
 xpsthRawVar=xPsth.psthVar;
 
 
 d= xpsthRawHump - xpsthRaw;
 d1= xpsthRawVarHump - xpsthRawVar;

 %%%%
 % Jeremiah
 jer = SpikeUtils.jeromiahJpsth(xCell,yCell,alignedTimeWin,binWidth,5);
 my = SpikeUtils.jpsth(xCell,yCell,alignedTimeWin,binWidth,5);
 
 
 


 
