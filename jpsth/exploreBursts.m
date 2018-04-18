
burstDir = 'data/BurstAnalysis/burstDB';
fileList = dir(fullfile(burstDir,'UID*.mat'));
fileList = {fileList.name}';

cellNo = 296;
fileIndex = find(~cellfun(@isempty,regexp(fileList, num2str(cellNo,'UID_%04d'),'match')));
burstFile = fullfile(burstDir,fileList{fileIndex});


