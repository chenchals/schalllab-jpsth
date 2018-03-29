
%%%%%%%%%%%%%%%%%%% User parameters Area %%%%%%%%%%%%%%%%%%%%%%%%
timeWin = [-200 400];
load('/Users/subravcr/Projects/lab-schall/schalllab-jpsth/data/spikeTimes_saccAligned_sess14.mat');
origSpkTimes = SpikeTimes.saccade;
% Conditions to select trials
load('/Users/subravcr/Projects/lab-schall/schalllab-jpsth/data/ttx.mat');
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

 groups = {'unitIds', 'channelUnits', 'layerUnits'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% prune spkTimes . ?
spkTimesTrials = origSpkTimes(trials,:);
for g = 3:3 %numel(groups)
    selGroup = groups{g};
    units2Use = eval(selGroup);
    % use these Ids...
    switch selGroup
        case 'unitIds'
          idsToUse = cellIdsTable.unitIds;
          prefix = 'Unit Id #';
          pltRows = 5;
          pltCols = 6;
        case 'channelUnits'
          idsToUse = unique(cellIdsTable.channelNo);
          prefix = 'Channel #'; 
          pltRows = 3;
          pltCols = 6;
        case 'layerUnits'
          idsToUse = 1:numel(units2Use);
          prefix = 'Layer #'; 
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
    
    % Compute bursts
    % c1Burst = SpikeFx.burstAnalysis(spkTimes(:,1),[-200 400],0);
    plotProgress = 0;
    fprintf('Running burst detector...\n')
    %allBursts = cell(nTrials,numel(idsToUse));
    for c = 1:size(spkTimes,2)
        fprintf('%02d/%02d\n',c,size(spkTimes,2));
        x = spkTimes(:,c);
        allBursts(:,c) = SpikeFx.burstAnalysis(x,timeWin,plotProgress);
    end
    fprintf('done\n')
    
    plotResults(prefix, idsToUse, allPsthPsp, psthBins, allRasters, rasterBins, allBursts, pltRows, pltCols);
end

function plotResults(titlePrefix, ids, psthAllGroups, psthTimes, rastersAllGroups, rasterTimes, burstsAllGroups, plotRows, plotCols)
%%%% Plot rasters %%%%
bobT = arrayfun(@(x) x{1}.bobT,burstsAllGroups,'UniformOutput',false);
eobT = arrayfun(@(x) x{1}.eobT,burstsAllGroups,'UniformOutput',false);
maxFrs = max(cellfun(@max,psthAllGroups));
maxFrRound = round(maxFrs/5)*5;

figure
for cellId = 1:numel(ids)
    subplot(plotRows,plotCols,cellId);
    SpikeFx.plotPsth(psthAllGroups{cellId}, psthTimes,maxFrRound);
    hold on
    SpikeFx.plotRastersAndBursts(rastersAllGroups{cellId},rasterTimes,bobT(:,cellId),eobT(:,cellId));
    hold off
    title(strcat(titlePrefix,num2str(ids(cellId),'%02d')));
    xlabel('Saccade aligned');
    ylabel('Firing rate (Hz)');
    drawnow
end

end



