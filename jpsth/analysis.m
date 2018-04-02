function [ results ] = analysis()
%%%%%%%%%%%%%%%%%%% User parameters Area %%%%%%%%%%%%%%%%%%%%%%%%
timeWin = [-200 400];
fileToLoad = '/Users/subravcr/Projects/lab-schall/schalllab-jpsth/data/spikeTimes_saccAligned_sess14.mat';
conditionsFile = '/Users/subravcr/Projects/lab-schall/schalllab-jpsth/data/ttx.mat';
load(fileToLoad);
[~,datafile,ext] = fileparts(fileToLoad);
datafile = [datafile ext];
origSpkTimes = SpikeTimes.saccade;
% Conditions to select trials
load(conditionsFile);
[ ~, sessionConditionFile, ext] = fileparts(conditionsFile);
sessionConditionFile = [sessionConditionFile ext];
session = 14;
condition = 'GO';
trials = ttx.(condition){session};
% Unit Ids, channels, layers
unitIds = 1:size(origSpkTimes,2);
unitChannelIds = [1, 2, 3, 4, 4, 5, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 9, 10, 10, 11, 12, 13, 14, 14, 14, 15, 17, 18, 19];
% Attached is the   ttx  file I explained to you in person.
% The session of interest is session 14, with 29 neurons.
% For the 29 neurons, the depths in channel units relative to the surface are:
% 1, 2, 3, 4, 4, 5, 5, 5, 6, 6, 7, 7, 8, 8, ||||||| 9, 9, 9, 10, 10, 11, 12, 13, 14, 14, 14, 15, 17, 18, 19
%

cellIdsTable = table();
cellIdsTable.unitIds = unitIds';
cellIdsTable.channelNo = unitChannelIds';
cellIdsTable.upperLayer = (unitChannelIds<=8)';
cellIdsTable.lowerLayer = (unitChannelIds>8)';
% Create groups for analysis
units = arrayfun(@(x) {x},cellIdsTable.unitIds);
% group cell Ids by channel
channelUnits = arrayfun(@(x) find(cellIdsTable.channelNo==x),...
    unique(cellIdsTable.channelNo),'UniformOutput',false);
% Upper layer units
upperLayerUnits = arrayfun(@(x) find(cellIdsTable.channelNo==x),...
    unique(cellIdsTable.channelNo(cellIdsTable.upperLayer)),'UniformOutput',false);
% Lower layer units
lowerLayerUnits = arrayfun(@(x) find(cellIdsTable.channelNo==x),...
    unique(cellIdsTable.channelNo(cellIdsTable.lowerLayer)),'UniformOutput',false);

layerUnits = {vertcat(upperLayerUnits{:}); vertcat(lowerLayerUnits{:})};

groups = {'units', 'channelUnits', 'layerUnits'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% prune spkTimes . ?
spkTimesTrials = origSpkTimes(trials,:);
results = struct();
for g = 1:3 %numel(groups)
    
    clearvars prefix units2Use allPsth allPsthPsp psthBins allRasters rasterBins temp allBursts pltRows pltCols
    
    selGroup = groups{g};
    %units2Use = eval(selGroup);
    % use these Ids...
    switch selGroup
        case 'units'
            units2Use = arrayfun(@(x) {x},cellIdsTable.unitIds);
            titles = cellfun(@(x) num2str(x,'Unit Id #%02d'),units2Use,'UniformOutput',false);
            analysisType = 'Single Unit';
            pltRows = 5;
            pltCols = 6;
        case 'channelUnits'
            channels  = unique(cellIdsTable.channelNo);
            units2Use = arrayfun(@(x) find(cellIdsTable.channelNo==x),...
                unique(cellIdsTable.channelNo),'UniformOutput',false);
            titles = arrayfun(@(x) num2str(x,'Channel #%02d'),channels,'UniformOutput',false);
            analysisType = 'Pooled units per Channel';
            pltRows = 3;
            pltCols = 6;
        case 'layerUnits'
            units2Use = {
                % upper layer
                cell2mat(arrayfun(@(x) find(cellIdsTable.channelNo==x),...
                unique(cellIdsTable.channelNo(cellIdsTable.upperLayer)),'UniformOutput',false))';
                % lower layer
                cell2mat(arrayfun(@(x) find(cellIdsTable.channelNo==x),...
                unique(cellIdsTable.channelNo(cellIdsTable.lowerLayer)),'UniformOutput',false))';
                };
            titles = {'Upper layers' 'Lower layers'};
            analysisType = 'Pooled units per Layer';
            pltRows = 2;
            pltCols = 1;
            
    end
    
    % aggregate by channels
    spkTimes = SpikeFx.groupSpikeTimes(spkTimesTrials, units2Use);
    
    % All Rasters
    temp = arrayfun(@(x) SpikeFx.rasters(spkTimes(:,x),timeWin),...
        1:size(spkTimes,2),'UniformOutput',false);
    allRasters = cellfun(@(x) x.rasters,temp,'UniformOutput',false);
    rasterBins = temp{1}.rasterBins;
    clearvars temp
    
    % All PSTHs
    psthBinWidth = 1;
    temp = arrayfun(@(x) SpikeFx.psth(spkTimes(:,x),psthBinWidth,timeWin,@nanmean),1:size(spkTimes,2),'UniformOutput',false);
    allPsth =  cellfun(@(x) x.psth,temp,'UniformOutput',false);
    psthBins = temp{1}.psthBins;
    allPsthPsp = cellfun(@(x) convn(x',SpikeFx.pspKernel,'same')',allPsth,'UniformOutput',false);
    clearvars temp
    
    % Compute bursts
    plotProgress = 0;
    fprintf('Running burst detector...\n')
    %allBursts = cell(nTrials,numel(idsToUse));
    parfor c = 1:size(spkTimes,2)
        fprintf('%02d/%02d\n',c,size(spkTimes,2));
        x = spkTimes(:,c);
        allBursts(:,c) = SpikeFx.burstAnalysis(x,timeWin,plotProgress);
    end
    fprintf('done\n')
    plotResults(titles, allPsthPsp, psthBins, allRasters, rasterBins, allBursts, pltRows, pltCols);
    
    results(g).analysisTime = datetime;
    results(g).datafile = datafile;
    results(g).session = session;
    results(g).condition = condition;
    results(g).analysisPrefix = analysisType;
    results(g).titles = titles;
    results(g).unitGroups = units2Use;
    results(g).allPsthPsp = allPsthPsp;
    results(g).psthBins = psthBins;
    results(g).allRasters = allRasters;
    results(g).rasterBins = rasterBins;
    results(g).allBursts = allBursts;
end
end


function plotResults(titles, psthAllGroups, psthTimes, rastersAllGroups, rasterTimes, burstsAllGroups, plotRows, plotCols)
%%%% Plot rasters %%%%
bobT = arrayfun(@(x) x{1}.bobT,burstsAllGroups,'UniformOutput',false);
eobT = arrayfun(@(x) x{1}.eobT,burstsAllGroups,'UniformOutput',false);
maxFrs = max(cellfun(@max,psthAllGroups));
maxFrRound = round(maxFrs/5)*5;

figure
for cellId = 1:numel(titles)
    currTitle = titles{cellId};
    subplot(plotRows,plotCols,cellId);
    SpikeFx.plotPsth(psthAllGroups{cellId}, psthTimes,maxFrRound);
    hold on
    SpikeFx.plotRastersAndBursts(rastersAllGroups{cellId},rasterTimes,bobT(:,cellId),eobT(:,cellId));
    hold off
    title(currTitle);
    xlabel('Saccade aligned');
    ylabel('Firing rate (Hz)');
    drawnow
end

end



