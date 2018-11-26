 
inFile = 'SATCellInfoDB';
inRootAnalysisDir = '/Volumes/schalllab/Users/Chenchal/JPSTH/';
monkNameMap = containers.Map({'D' 'E'},{'Darwin','Euler'});
rootDataDir = '/Volumes/schalllab/data';

db = load(fullfile(inRootAnalysisDir,inFile));

 JpsthPairSummary=table();
 JpsthPairSummary.monkSessionNum = unique(db.CellInfoDB.monkSessNo);
 JpsthPairSummary.session = regexprep(unique(db.CellInfoDB.datafile),'^([A-Z]\d*)-RH.*$','$1');
 JpsthPairSummary.nUnits = cell2mat(cellfun(@(x) sum(contains(db.CellInfoDB.datafile,x)),unique(db.CellInfoDB.datafile),'UniformOutput',false));

goodVMIdx = db.CellInfoDB.visual > 0.5 | db.CellInfoDB.move > 0.5;
cellsGoodVM = db.CellInfoDB(goodVMIdx,:);

uniqMonkSessNo = unique(cellsGoodVM.monkSessNo);
cellsBySession = arrayfun(@(x) find(contains(cellsGoodVM.monkSessNo,x)), uniqMonkSessNo, 'UniformOutput',false);
varsForPairs = {'UID','cellIdInFile','depth','area','unitFuncType','RF','MF','Isolation','ThomasRF','ThomasMF','ThomasVis'};
nextPairId = 0;
JpsthPairCellInfoDB = table();

for s=1:numel(cellsBySession)
    res = cellsGoodVM(cellsBySession{s},:);
    session = regexprep(res.datafile{1},'^([A-Z]\d*)-RH.*$','$1');
    tIdx = contains(JpsthPairSummary.session,session);
    if size(res,1) <= 1
        JpsthPairSummary.nCellsForJpsth(tIdx) = 0;
        JpsthPairSummary.nPairsJpsth(tIdx) = 0;
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
        
        JpsthPairSummary.nCellsForJpsth(tIdx) = size(result.CellInfoTable,1);
        JpsthPairSummary.nPairsJpsth(tIdx) = nchoosek(size(result.CellInfoTable,1),2);
        JpsthPairSummary.firstPairUID(tIdx) = pairs.Pair_UID(1);
        JpsthPairSummary.lastPairUID(tIdx) = pairs.Pair_UID(end);
        
        for v = 1:numel(varsForPairs)
            cName = varsForPairs{v};
            pairs.(['X_' cName]) = result.CellInfoTable.(cName)(pairRowIds(:,1));
            pairs.(['Y_' cName]) = result.CellInfoTable.(cName)(pairRowIds(:,2));
        end
        pairs.X_visMovFix = arrayfun(@(x) result.CellInfoTable{x,{'visual', 'move', 'fix'}},pairRowIds(:,1),'UniformOutput',false);
        pairs.Y_visMovFix = arrayfun(@(x) result.CellInfoTable{x,{'visual', 'move', 'fix'}},pairRowIds(:,2),'UniformOutput',false);
        nextPairId = nextPairId + nPairs;
        JpsthPairCellInfoDB = [JpsthPairCellInfoDB;pairs]; %#ok<AGROW>
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
save(fullfile(inRootAnalysisDir,'JPSTH_PAIRS_CellInfoDB.mat'),'JpsthPairCellInfoDB');

format2f = @(numFormat,cellArrayDouble) regexprep(arrayfun(@(x) num2str(x{1},numFormat),cellArrayDouble,'UniformOutput',false),'^(.*)$','\[$1\]');
JpsthPairCellInfoDB.X_Isolation=num2str(JpsthPairCellInfoDB.X_Isolation);
JpsthPairCellInfoDB.Y_Isolation=num2str(JpsthPairCellInfoDB.Y_Isolation);
JpsthPairCellInfoDB.X_RF=format2f('%d ',JpsthPairCellInfoDB.X_RF);
JpsthPairCellInfoDB.Y_RF=format2f('%d ',JpsthPairCellInfoDB.Y_RF);
JpsthPairCellInfoDB.X_MF=format2f('%d ',JpsthPairCellInfoDB.X_MF);
JpsthPairCellInfoDB.Y_MF=format2f('%d ',JpsthPairCellInfoDB.Y_MF);
JpsthPairCellInfoDB.X_ThomasRF=format2f('%d ',JpsthPairCellInfoDB.X_ThomasRF);
JpsthPairCellInfoDB.Y_ThomasRF=format2f('%d ',JpsthPairCellInfoDB.Y_ThomasRF);
JpsthPairCellInfoDB.X_ThomasMF=format2f('%d ',JpsthPairCellInfoDB.X_ThomasMF);
JpsthPairCellInfoDB.Y_ThomasMF=format2f('%d ',JpsthPairCellInfoDB.Y_ThomasMF);
JpsthPairCellInfoDB.X_visMovFix=format2f('%.2f ',JpsthPairCellInfoDB.X_visMovFix);
JpsthPairCellInfoDB.Y_visMovFix=format2f('%.2f ',JpsthPairCellInfoDB.Y_visMovFix);

writetable(JpsthPairCellInfoDB,fullfile(inRootAnalysisDir,'JPSTH_PAIRS_CellInfoTable.csv'));

save(fullfile(inRootAnalysisDir,'JPSTH-PAIR-Summary.mat'), 'JpsthPairSummary');
writetable(JpsthPairSummary,fullfile(inRootAnalysisDir,'JPSTH-PAIR-Summary.csv'))


