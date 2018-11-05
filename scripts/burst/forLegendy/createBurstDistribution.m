
inRootAnalyisDir = '/Volumes/schalllab/Users/Chenchal/Legendy';
burstProbDirPattern = 'Burst_Prob';
burstDbDir = 'burstDB';
cellFilePattern = 'UID_';

surpriseIndexDirs = dir(fullfile(inRootAnalyisDir,[burstProbDirPattern,'*']));

surpriseIndexDirs = {surpriseIndexDirs([surpriseIndexDirs.isdir]==1).name}';

surpriseValStrs = regexprep(surpriseIndexDirs,{'Burst_Prob_','_minus_'},{'','-'});

surpriseVals.signif = cellfun(@str2num,surpriseValStrs);
surpriseVals.si = arrayfun(@(x) -log(x), surpriseVals.signif);
surpriseValStrs = regexprep(surpriseValStrs,{'(\d*E)','-'},{'Signif_$1','_'});


burstDbDirs = cellfun(@(x) fullfile(inRootAnalyisDir,x,burstDbDir), surpriseIndexDirs, 'UniformOutput', false);

distributionTbl = table();
si = [0.5:1:50.5]';
for bb = 1: numel(burstDbDirs)
    bfiles = dir(fullfile(burstDbDirs{bb},[cellFilePattern '*']));
    uids = {bfiles.name}';
    bfiles = strcat({bfiles.folder}',filesep,{bfiles.name}');
    siField = surpriseValStrs{bb};
    fprintf('Doing for significance %s ...\n', siField);
    tic
    parfor ff = 1:numel(bfiles)
        sob = load(bfiles{ff},'sob');
        zz{ff,1} = histcounts([sob.sob{:}],si);
    end
    distributionTbl.(siField) = zz;
    if bb == 1
        distributionTbl.Properties.RowNames = uids;
    end
    clear zz;
    toc
end
% sort by signif values
[~,sortOrder] = sort(surpriseVals.signif,'descend');
burstDistrib.signifVals = surpriseVals.signif(sortOrder);
burstDistrib.distributionTbl = distributionTbl(:,sortOrder);
burstDistrib.si = si(1:end-1)+0.5;



