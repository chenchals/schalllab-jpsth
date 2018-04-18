

trailStart = 'TrialStart_';
alignEvent = 'Target_';
timeWin = [-100 600];
ttxCond = 'GO';

matFileDir = '/Volumes/schalllab/Users/Amir/Analysis/Mat_DataFiles';
burstDir = 'data/BurstAnalysis/burstDB';
temp = load(fullfile(burstDir, 'ttx.mat'));
ttx = temp.ttx;
clear temp;
temp = load(fullfile(burstDir, 'cellInfoDB.mat'));
cellInfoDB = temp.cellInfoDB;
clear temp;
% List of files that were run throigh burst detector
% each file should correspond to a row in cellInfoDB
fileList = dir(fullfile(burstDir, 'UID*.mat'));
fileList = strcat(burstDir,filesep,{fileList.name}');
% Blacklist cell-IDs that were not analyzed/failed to analyze
blacklistedUIDs = setdiff(cellInfoDB.UID,cellfun(@(x) x,regexp(fileList,'UID_\d+','match')));

sessionNo = 14;
% specify which cell IDS corresponding to row indices int he cellInfoDB to
% analyze/explore
% to analyze all cells 
%   cellUIDsToExplore = 1:size(cellInfoDB,1);
% to analyze on session 14 cells:
%   cellUIDsToExplore = find(cellInfoDB.SessionNo == 14);
% to analyze cells by channel=8 and session=14 
%   cellUIDsToExplore = find(cellInfoDB.SessionNo == 14 & cellInfoDB.depth == 8);
% to analyze cells as groups by channel (give an array of channel nos) for session=14 
%    sessionChannels = unique(cellInfoDB.depth(cellInfoDB.SessionNo==14),'stable'); 
%    cellUIDsToExplore = arrayfun(@(chNo) find(cellInfoDB.SessionNo == 14 & cellInfoDB.depth == chNo),sessionChannels,'UniformOutput',false);
   
cellUIDsToExplore = find(cellInfoDB.SessionNo == sessionNo);
grouped = iscell(cellUIDsToExplore);
for i = 1:numel(cellUIDsToExplore)
    if grouped
        cellNos = cellUIDsToExplore{i};
    else 
        cellNos = cellUIDsToExplore(i);
    end
    cellBursts{i,1} = BurstUtils.loadCellBursts(cellNos,fileList,blacklistedUIDs);
    
end



