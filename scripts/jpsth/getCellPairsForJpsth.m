 
inFile = 'SAT_CellInfoDB';
inRootAnalysisDir = '/Volumes/schalllab/Users/Chenchal/JPSTH/';
monkNameMap = containers.Map({'D' 'E'},{'Darwin','Euler'});
rootDataDir = '/Volumes/schalllab/data';

db = load(fullfile(inRootAnalysisDir,inFile));

 t=table();
 t.monkSessionNum = unique(db.CellInfoTable.monkSessNo);
 t.session = regexprep(unique(db.CellInfoTable.datafile),'^([A-Z]\d*)-RH.*$','$1');
 t.nUnits = cell2mat(cellfun(@(x) sum(contains(db.CellInfoTable.datafile,x)),unique(db.CellInfoTable.datafile),'UniformOutput',false));

goodVMIdx = db.CellInfoTable.visual > 0.5 | db.CellInfoTable.move > 0.5;
cellsGoodVM = db.CellInfoTable(goodVMIdx,:);

uniqMonkSessNo = unique(cellsGoodVM.monkSessNo);
cellsBySession = arrayfun(@(x) find(contains(cellsGoodVM.monkSessNo,x)), uniqMonkSessNo, 'UniformOutput',false);
varsForPairs = {'UID','cellIdInFile','depth','area','unitFuncType','RF','MF'};
nextPairId = 0;
JpsthPairCellInfo = table();

for s=1:numel(cellsBySession)
    res = cellsGoodVM(cellsBySession{s},:);
    session = regexprep(res.datafile{1},'^([A-Z]\d*)-RH.*$','$1');
    tIdx = contains(t.session,session);
    if size(res,1) <= 1
        t.nCellsForJpsth(tIdx) = 0;
        t.nPairsJpsth(tIdx) = 0;
        continue;
    elseif size(res,1) > 1 % we have more than 1 unit
        result.CellInfoTable = cellsGoodVM(cellsBySession{s},:);
        sessName = char(strcat(uniqMonkSessNo{s},'-',regexprep(unique(result.CellInfoTable.datafile),'(\d)-.*','$1')));
        monkName = monkNameMap(unique(result.CellInfoTable.monk));
        pairRowIds = sortrows(combnk(1: size(result.CellInfoTable,1), 2),[1 2]);
        nPairs = size(pairRowIds,1);
        pairs = table();
        pairs.Pair_UID = cellstr(num2str(((1:nPairs)+ nextPairId)','PAIR_%04d'));
        pairs.datafile = result.CellInfoTable.datafile(pairRowIds(:,1));   
        
        t.nCellsForJpsth(tIdx) = size(result.CellInfoTable,1);
        t.nPairsJpsth(tIdx) = nchoosek(size(result.CellInfoTable,1),2);
        t.firstPairUID(tIdx) = pairs.Pair_UID(1);
        t.lastPairUID(tIdx) = pairs.Pair_UID(end);
        
        for v = 1:numel(varsForPairs)
            cName = varsForPairs{v};
            pairs.(['X_' cName]) = result.CellInfoTable.(cName)(pairRowIds(:,1));
            pairs.(['Y_' cName]) = result.CellInfoTable.(cName)(pairRowIds(:,2));
        end
        pairs.X_visMovFix = arrayfun(@(x) result.CellInfoTable{x,{'visual', 'move', 'fix'}},pairRowIds(:,1),'UniformOutput',false);
        pairs.Y_visMovFix = arrayfun(@(x) result.CellInfoTable{x,{'visual', 'move', 'fix'}},pairRowIds(:,2),'UniformOutput',false);
        nextPairId = nextPairId + nPairs;
        JpsthPairCellInfo = [JpsthPairCellInfo;pairs]; %#ok<AGROW>
        tempSumm =table();
        tempSumm.sessionName = sessName;
        
        
    end
    result.PairInfoTable = pairs;
    oDir = fullfile(inRootAnalysisDir,monkName,sessName);
    if ~exist(oDir,'dir')
        mkdir(oDir);
    end
    fprintf('Writing file %s\n',[sessName '_PAIRS.mat']);
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

t;

t
% redo session

