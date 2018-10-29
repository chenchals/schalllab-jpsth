
rootDataDir = '/Volumes/schalllab/data';
rootAnalysisDir = '/Volumes/schalllab/Users/Chenchal/JPSTH';
jpsthResultsDir = fullfile(rootAnalysisDir,'Figs');
if ~exist(jpsthResultsDir, 'dir')
    mkdir(jpsthResultsDir);
end
arrayTime = 3500; % constant for SAT?
loadVars={'Target_'
    'TrialStart_'
    'Errors_'
    'Correct_'
    'Decide_'
    'SaccDir_'
    'Stimuli_'
    'MStim_'
    'SAT_'
    'FixOn_'
    'FixTime_Jit_'
    'FixAcqTime_'
    'BellOn_'
    'JuiceOn_'
    'MG_Hold_'
    'SRT'
    'saccLoc'
    'Hemi'
    'RFs'
    'MFs'
    'BrainID'};

% load variable: JpsthPairsCellInfo
load('/Volumes/schalllab/Users/Chenchal/JPSTH/JPSTH_PAIRS_CellInfoTable.mat')

JpsthPairCellInfo.folder = cellfun(@(x) fullfile(rootDataDir,...
                            regexprep(x(1),{'D','E'},{'Darwin','Euler'}),'SAT/Matlab'),...
                            JpsthPairCellInfo.datafile,'UniformOutput',false);
sessFiles = JpsthPairCellInfo.datafile;
pairUids = JpsthPairCellInfo.Pair_UID;
sessionRowIds = arrayfun(@(x) find(contains(sessFiles,x)), unique(sessFiles),'UniformOutput',false);

for s = 1:numel(sessionRowIds)
    pairsTodo = JpsthPairCellInfo(sessionRowIds{s},:);   
    unitIdsInFile = unique([pairsTodo.X_cellIdInFile;pairsTodo.Y_cellIdInFile]);
    file2load = fullfile(pairsTodo.folder{1},pairsTodo.datafile{1});
    vars2load = [loadVars;unitIdsInFile];
    S = load(file2load,vars2load{:});   
    alignTime = S.Target_(:,1);
    nTrials = size(S.TrialStart_,1);
    nUnits = numel(unitIdsInFile);
    alignedSpikeTimeCellArray = cell(nTrials,nUnits);
    for u = 1:nUnits
        unit = S.(unitIdsInFile{u});
        alignedSpikeTimeCellArray(:,u) = arrayfun(@(x) unit(x,unit(x,:)~=0)-arrayTime,(1:nTrials)','UniformOutput',false);
    end
    [~,jpsthTable] = newJpsth(alignedSpikeTimeCellArray,unitIdsInFile,[-200 600],10,10);
    %verify cell-pairing in newJpsh with pairsTodo
    jpsthStruct_pairKeys = strcat(jpsthTable.xCellId,'-',jpsthTable.yCellId);
    pairsTodo_pairKeys = strcat(pairsTodo.X_cellIdInFile,'-',pairsTodo.Y_cellIdInFile);
     % the number of pairs match AND all the rows match as-is or
     % one of the arrays conatin all items may be in a different order?    
     if isequaln(jpsthStruct_pairKeys,pairsTodo_pairKeys) || ...
                sum(contains(jpsthStruct_pairKeys,pairsTodo_pairKeys)) == numel(jpsthStruct_pairKeys))
            jpsthTable.sortIdxs = cellfun(@(x) find(contains(pairsTodo_pairKeys,x)),jpsthStruct_pairKeys);
            jpsthTable =  [sortrows(jpsthTable,'sortIdxs') pairsTodo];
            
     else
        error('*****Number of pairs done by newJpsth does not match the pairsToDo\n******\n');
     end    
end