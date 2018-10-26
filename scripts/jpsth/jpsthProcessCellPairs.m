
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
    ZZ = newJpsth(alignedSpikeTimeCellArray,[-200 600],5,5);
    ZZ.X_cell = unitIdsInFile(ZZ.cellPairs(:,1));
    ZZ.Y_cell = unitIdsInFile(ZZ.cellPairs(:,2));
    %verify cell-pairing in newJpsh with pairsTodo
    pairKeys = strcat(unitIdsInFile(ZZ.cellPairs(:,1)),'-',unitIdsInFile(ZZ.cellPairs(:,2)));
    pairsTodo_pairKeys = strcat(pairsTodo.X_cellIdInFile,'-',pairsTodo.Y_cellIdInFile);
    
end