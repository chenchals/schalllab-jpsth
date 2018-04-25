
baseDir = '/Volumes/schalllab';
analysisDir = fullfile(baseDir,'Users/Amir/0-chenchal/BurstAnalysis2/burstAlignedTimeWindowDB');
temp = load(fullfile(analysisDir, 'CellInfoDB.mat'));
cellInfoDB = temp.CellInfoDB;
nCells = size(cellInfoDB,1);
files = dir(fullfile(analysisDir,'UID_*.mat'));
%verify #files = no of rows in cellInfoDB
assert(nCells == numel(files),'Number of files do not match number of rows in cellInfoDB');
files = strcat(analysisDir,filesep,{files.name})';
% Get all fileldnames once
temp = load(files{1});
fns = fieldnames(temp);
alignEventTimeWin = temp.alignEventTimeWin;
alignedFns = fns(contains(fns,'_aligned_'));
o = cell(nCells,numel(alignedFns));
    
% processBursting for all cells
parfor s = 1:nCells
    fprintf('cell %d\n',s);
    temp = load(files{s});   
    o(s,:) = cellfun(@(x) cell2mat(temp.(x).isBursting), alignedFns','UniformOutput',false);
end

for i = 1:numel(alignedFns)
    byCells.(alignedFns{i}) = o(:,i); 
end
byCells.alignEventTimeWin=alignEventTimeWin;

% save(fullfile(analysisDir,'AllCellsAlignedTimeWindowed.mat'),'-v7.3','-struct','byCells');

%% Split by sessions. For each session, group cells by trials
sessionNo = unique(cellInfoDB.SessionNo,'stable');
sessionCellIndices = arrayfun(@(x) find(cellInfoDB.SessionNo==x),sessionNo,'UniformOutput',false);

bySessions = cell(numel(sessionNo),numel(alignedFns));
for s = 1:numel(sessionCellIndices)
    cellNos = sessionCellIndices{s};
    nCellsInSession = numel(cellNos);
    for f = 1:numel(alignedFns)
        alignedFn = alignedFns{f};
        temp = byCells.(alignedFn)(cellNos);
        nTrials = size(temp{1},1);
        nBins = size(temp{1},2);
        temp = reshape(cell2mat(temp'),nTrials,nBins,nCellsInSession);
        bySessions{s,f} = arrayfun(@(t) squeeze(temp(t,:,:))',(1:nTrials)','UniformOutput',false);
    end
    clear temp
end
% save by session
for s = 1:numel(sessionNo)
    sNo = sessionNo(s);
    oFile = fullfile(analysisDir,num2str(sNo,'Session_%03d_AlignedTimeWindowed.mat'));
    sVar = bySessions(s,:);
    sOut = struct();
    for i = 1:numel(alignedFns)
        sOut.(alignedFns{i}) = sVar{:,i};
    end
    sOut.alignEventTimeWin=alignEventTimeWin;
%    save(oFile,'-v7.3','-struct','sOut');   
end


