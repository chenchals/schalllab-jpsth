baseDir = '/Volumes/schalllab';
analysisDir = fullfile(baseDir,'Users/Amir/0-chenchal/BurstAnalysis/burstAlignedTimeWindowDB2');
temp = load(fullfile(analysisDir, 'TrialTypesDB.mat'));
trialTypes = temp.ttx;
clear temp;
temp = load(fullfile(analysisDir, 'CellInfoDB.mat'));
cellInfoDB = temp.CellInfoDB;
clear temp;
% List of files that were run through burst detector
% each file should correspond to a row in cellInfoDB
fileList = dir(fullfile(analysisDir, 'UID*.mat'));
fileList = strcat(analysisDir,filesep,{fileList.name}');
% Blacklist cell-IDs that were not analyzed/failed to analyze
blacklistedUIDs = setdiff(cellInfoDB.UID,cellfun(@(x) x,regexp(fileList,'UID_\d+','match')));

%%=== For each session aggregate cells ======
% Which row indices in the cellInfoDB to group and analyze/explore
% All cells for a session: (need sessionNo)
%   cellUIDsToExplore = find(cellInfoDB.SessionNo == 14);
% All cells for a channel for a session (need channelNo and sessionNo)
%   cellUIDsToExplore = find(cellInfoDB.SessionNo == 14 & cellInfoDB.depth == 8);
% All cells grouped by channel for a session (need sessionChannel array, and sessionNo) 
%    sessionChannels = unique(cellInfoDB.depth(cellInfoDB.SessionNo==14),'stable'); 
%    cellUIDsToExplore = arrayfun(@(chNo) find(cellInfoDB.SessionNo == 14 & cellInfoDB.depth == chNo),sessionChannels,'UniformOutput',false);

sessionNo = 14;
sessionChannels = unique(cellInfoDB.depth(cellInfoDB.SessionNo==sessionNo),'stable');   
cellUIDsToExplore = find(cellInfoDB.SessionNo == sessionNo);

grouped = iscell(cellUIDsToExplore);
for i = 1:numel(cellUIDsToExplore)
    if grouped
        cellNos = cellUIDsToExplore{i};
    else 
        cellNos = cellUIDsToExplore(i);
    end
    
end



