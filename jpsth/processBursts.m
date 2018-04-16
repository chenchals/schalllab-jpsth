function processBursts()

    dataDir ='/Volumes/schalllab/Users/Amir/Analysis/Mat_DataFiles';
    cellInfoDbFile = 'data/Analysis/burstDB/cellInfoDB.mat';
    analysisDir = 'data/Analysis/burstDB';
    % Load cell inforamation database table
    temp = load(cellInfoDbFile);
    cellInfoTable = temp.cellInfoDB;
    clearvars temp cellInfoDB cellInfoDbFile

    parfor i = 1:size(cellInfoTable,1)
        cellInfo = cellInfoTable(i,:);
        datafile = fullfile(dataDir, cellInfo.dataFile{1});
        sessionNo = cellInfo.SessionNo;
        analysisFile = fullfile(analysisDir,[cellInfo.UID '_session_' num2str(sessionNo,'%03d')]);
        cellId = cellInfo.cellIdInFile{1};
        fprintf('Analyzing bursts for \n');
        disp(cellInfo);
        [spkTimes, timeWins] = getSpikeTimesByTrials(datafile,cellId);
        oBursts = BurstUtils.detectBursts(spkTimes,timeWins);
        BurstUtils.saveOutput(analysisFile,oBursts,'cellInfo',cellInfo);
        fprintf('wrote file %s\n\n',analysisFile);
    end

end

%% internal fx for getting and spiketime data by trials 
function [ spkTimes, timeWins ] = getSpikeTimesByTrials(datafile, cellId)
    vars2load = {'TrialStart_',cellId};
    temp = load(datafile,vars2load{:});
    unitTimes = temp.(cellId);
    trialStart = temp.TrialStart_;
    clear temp
    spkTimes = arrayfun(@(t) unitTimes(unitTimes>=trialStart(t) & unitTimes<trialStart(t+1)),...
        [1:numel(trialStart)-1]','UniformOutput',false);
    spkTimes{end+1} = unitTimes(unitTimes>=trialStart(end));
    timeWins = [trialStart(:) [trialStart(2:end);unitTimes(end)]];
end
