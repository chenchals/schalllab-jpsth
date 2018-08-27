% CREATEBURSTSDB Runs poissBurst on sigle units for all sessions.  The cell
%   information/parameters for each single unit is defined in each row in
%   the CellInfoDB.mat file. 
%   The .mat data file for each cell specifed in the is loaed form the [dataDir] variable 
%   Results of processing each row of this table is saved to filename that
%   is a concatenation of cellId and session no: [UID_0000_session_000.mat]
%   in [analysisDir] variable. 

%     dataDir ='/Volumes/schalllab/Users/Amir/Analysis/Mat_DataFiles';
%     cellInfoDbFile = 'data/Analysis/burstDB/cellInfoDB.mat';
%     analysisDir = 'data/Analysis/burstDB';
% On Teba
    significance = 1E-5;
    dataDir ='/mnt/teba/Users/Amir/Analysis/Mat_DataFiles';
    analysisDir = '/mnt/teba/Users/Chenchal/Legendy/Bursts_Signif_1E_minus_05/burstDB';
    cellInfoDbFile = fullfile(analysisDir,'CellInfoDB.mat');
    % Load cell inforamation database table
    temp = load(cellInfoDbFile);
    CellInfoDB = temp.CellInfoDB;
    clearvars temp cellInfoDB cellInfoDbFile
    
    %parpool(20);
    parfor i = 1:size(CellInfoDB,1)
        cellInfo = CellInfoDB(i,:);
        datafile = fullfile(dataDir, cellInfo.dataFile{1});
        sessionNo = cellInfo.SessionNo;
        analysisFile = fullfile(analysisDir,[cellInfo.UID '_session_' num2str(sessionNo,'%03d')]);
        cellId = cellInfo.cellIdInFile{1};
        fprintf('Analyzing bursts for \n');
        disp(cellInfo);
        [spkTimes, timeWins] = getSpikeTimesByTrials(datafile,cellId);
        oBursts = BurstUtils.detectBursts(spkTimes,timeWins,'Significance', significance);
        BurstUtils.saveOutput(analysisFile,oBursts,'cellInfo',cellInfo);
        fprintf('wrote file %s\n\n',analysisFile);
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
    lastSpkTime = unitTimes(end);
    if lastSpkTime < trialStart(end) % no spikes afetr lastSpkTime
        lastSpkTime = trialStart(end) + 1;
    end
    timeWins = [trialStart(:) [trialStart(2:end);lastSpkTime]];
end