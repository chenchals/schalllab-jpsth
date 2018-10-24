 
inFile = 'Darwin_SAT_CellInfoTable';
inRootAnalysisDir = '/Volumes/schalllab/Users/Chenchal/JPSTH/';
rootDataDir = '/Volumes/schalllab/data';

load(fullfile(inRootAnalysisDir,inFile));

goodVMIdx = cellfun(@str2num,CellInfoTable.Visual) > 0.5 | cellfun(@str2num,CellInfoTable.Move) > 0.5;

cellsGoodVM = CellInfoTable(goodVMIdx,:);
sessionNums = cellfun(@str2num,cellsGoodVM.SessionNumber);
cellsBySession = arrayfun(@(x) find(sessionNums == x), unique(sessionNums), 'UniformOutput',false);

for s=1:numel(cellsBySession)
    sessionUnits = cellsGoodVM(cellsBySession{s},:);
    
end
