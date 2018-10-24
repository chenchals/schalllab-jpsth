 
inFile = 'SAT_CellInfoDB';
inRootAnalysisDir = '/Volumes/schalllab/Users/Chenchal/JPSTH/';
monkNameMap = containers.Map({'D' 'E'},{'Darwin','Euler'});
rootDataDir = '/Volumes/schalllab/data';

db = load(fullfile(inRootAnalysisDir,inFile));

goodVMIdx = db.CellInfoTable.visual > 0.5 | db.CellInfoTable.move > 0.5;
cellsGoodVM = db.CellInfoTable(goodVMIdx,:);

uniqMonkSessNo = unique(cellsGoodVM.monkSessNo);
cellsBySession = arrayfun(@(x) find(contains(cellsGoodVM.monkSessNo,x)), uniqMonkSessNo, 'UniformOutput',false);
varsForPairs = {'UID','cellIdInFile','depth','area','unitFuncType','RF','MF'};
nextPairId = 0;
JpsthPairCellInfo = table();
for s=1:numel(cellsBySession)
    res = cellsGoodVM(cellsBySession{s},:);
    if size(res,1) > 1 % we have more than 1 unit
        result.CellInfoTable = cellsGoodVM(cellsBySession{s},:);
        sessName = char(strcat(uniqMonkSessNo{s},'-',regexprep(unique(result.CellInfoTable.datafile),'(\d)-.*','$1')));
        monkName = monkNameMap(unique(result.CellInfoTable.monk));
        pairRowIds = sortrows(combnk(1: size(result.CellInfoTable,1), 2),[1 2]);
        nPairs = size(pairRowIds,1);
        pairs = table();
        pairs.Pair_UID = cellstr(num2str(((1:nPairs)+ nextPairId)','PAIR_%04d'));
        pairs.datafile = result.CellInfoTable.datafile(pairRowIds(:,1));
        for v = 1:numel(varsForPairs)
            cName = varsForPairs{v};
            pairs.(['X_' cName]) = result.CellInfoTable.(cName)(pairRowIds(:,1));
            pairs.(['Y_' cName]) = result.CellInfoTable.(cName)(pairRowIds(:,2));
        end
        pairs.X_visMovFix = arrayfun(@(x) result.CellInfoTable{x,{'visual', 'move', 'fix'}},pairRowIds(:,1),'UniformOutput',false);
        pairs.Y_visMovFix = arrayfun(@(x) result.CellInfoTable{x,{'visual', 'move', 'fix'}},pairRowIds(:,2),'UniformOutput',false);
        nextPairId = nextPairId + nPairs;
        JpsthPairCellInfo = [JpsthPairCellInfo;pairs]; %#ok<AGROW>
    end
    result.PairInfoTable = pairs;
    oDir = fullfile(inRootAnalysisDir,monkName,sessName);
    if ~exist(oDir,'dir')
        mkdir(oDir);
    end
    save(fullfile(oDir,[sessName '_PAIRS.mat']),'-struct','result');
end
save(fullfile(inRootAnalysisDir,'JPSTH_PAIRS_CellInfoTable.mat'),'JpsthPairCellInfo');

format2f = @(numFormat,cellArrayDouble) regexprep(arrayfun(@(x) num2str(x{1},numFormat),cellArrayDouble,'UniformOutput',false),'^(.*)$','\[$1\]');
JpsthPairCellInfo.X_RF=format2f('%d ',JpsthPairCellInfo.X_RF);
JpsthPairCellInfo.Y_RF=format2f('%d ',JpsthPairCellInfo.Y_RF);
JpsthPairCellInfo.X_MF=format2f('%d ',JpsthPairCellInfo.X_MF);
JpsthPairCellInfo.Y_MF=format2f('%d ',JpsthPairCellInfo.Y_MF);
JpsthPairCellInfo.X_visMovFix=format2f('%.2f ',JpsthPairCellInfo.X_visMovFix);
JpsthPairCellInfo.Y_visMovFix=format2f('%.2f ',JpsthPairCellInfo.Y_visMovFix);

writetable(JpsthPairCellInfo,fullfile(inRootAnalysisDir,'JPSTH_PAIRS_CellInfoTable.csv'));