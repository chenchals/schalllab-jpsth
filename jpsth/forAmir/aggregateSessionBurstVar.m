
baseDir = '/Volumes/schalllab';
matDataDir = fullfile(baseDir, 'Users/Amir/Analysis/Mat_DataFiles');
analysisDir = fullfile(baseDir,'Users/Amir/0-chenchal/BurstAnalysis2/burstDB');
temp = load(fullfile(analysisDir, 'CellInfoDB.mat'));
cellInfoDB = temp.CellInfoDB;
nCells = size(cellInfoDB,1);
files = dir(fullfile(analysisDir,'UID_*.mat'));
%verify #files = no of rows in cellInfoDB
assert(nCells == numel(files),'Number of files do not match number of rows in cellInfoDB');
files = strcat(analysisDir,filesep,{files.name})';

sessionNo = unique(cellInfoDB.SessionNo,'stable');
sessionCellIndices = arrayfun(@(x) find(cellInfoDB.SessionNo==x),sessionNo,'UniformOutput',false);

for s = 1:numel(sessionCellIndices)
    sNo = sessionNo(s);
    oFile = fullfile(analysisDir,num2str(sNo,'Session_%03d_EyeX_Aligned.mat'));
    cellNos = sessionCellIndices{s};
    cellInfo = cellInfoDB(cellNos,:);
    eyeXSize = whos('-file',fullfile(matDataDir,[cellInfoDB.dataFile{cellNos(1)} '.mat']),'EyeX_');
    eyeXSize = eyeXSize.size(1);
    timeWin = load(files{cellNos(1)}, 'timeWin');
    timeWin = timeWin.timeWin;
    % adjust end of tWin 
    timeWin = cellfun(@(x) [x(1) x(2)-1], timeWin,'UniformOutput', false);
    % Extend last trial timeWin to eyeXSize
    timeWin{end}(2) = eyeXSize;
    % Extend First trial timeWin from 1
    timeWin{1}(1) = 1;
    % output for session
    oS = cell(numel(cellNos),1);
    oB = cell(numel(cellNos),1);
    oE = cell(numel(cellNos),1);
    parfor c = 1:numel(cellNos)
        fn = files{cellNos(c)};
        fprintf('Doing Session %3d, cell UID %04d...\n',s,cellNos(c));
        temp = load(fn, 'bobT', 'eobT');
        isBursting = BurstUtils.convert2logical(temp.bobT,temp.eobT,timeWin);
        isBursting = cell2mat(isBursting');
        % assert size of logical array is correct
        assert(numel(isBursting) == eyeXSize, 'The isBursting logical array does NOT align with EyeX_ data points. Aborting');
        % assert the first bursting spike in the logical array
        assert(find(isBursting,1,'first') == min(cell2mat(temp.bobT')),...
                'The first bursting spike does NOT align with first bobT for session. Aborting');
        % assert the last bursting spike in the logical array
        assert(find(isBursting,1,'last') == max(cell2mat(temp.eobT')),...
                'The last bursting spike does NOT align with last eobT for session. Aborting');       
        oS{c} = isBursting; 
        crossings = diff(isBursting);
        oB{c} = find(crossings==1)+1;
        oE{c} = find(crossings==-1);
    end
    out.bobT = oB;
    out.eobT = oE;
    out.isBursting = oS;
    out.sessionNo = sNo;
    out.cellInfo = cellInfo;
    fprintf('Writing to file %s...\n',oFile);
    save(oFile,'-struct','out');
    clearvars out;
end




