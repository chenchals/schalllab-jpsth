 
inFile = 'Darwin_SAT_CellInfoTable';
inRootAnalysisDir = '/Volumes/schalllab/Users/Chenchal/JPSTH/';
rootDataDir = '/Volumes/schalllab/data';

load(fullfile(inRootAnalysisDir,inFile));

goodVMIdx = cellfun(@str2num,CellInfoTable.Visual) > 0.5 | cellfun(@str2num,CellInfoTable.Move) > 0.5;

cellsGoodVM = CellInfoTable(goodVMIdx,:);
sessionNums = unique(cellfun(@str2num,cellsGoodVM.SessionNumber));
cellsBySession = arrayfun(@(x) find(cellfun(@str2num,cellsGoodVM.SessionNumber) == x), sessionNums, 'UniformOutput',false);

for s=1:numel(sessionNums)
    sessionUnits = cellsGoodVM(cellsBySession{s},:);
    
end
