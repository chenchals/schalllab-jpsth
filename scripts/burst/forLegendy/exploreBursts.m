
%% List mat files created for analyzing bursts
rootDir = '/mnt/teba'; %'/Volumes/schalllab' '/Users/Chenchal/Legendy';
baseDir = fullfile(rootDir,'Users/Chenchal/Legendy');
outDir = fullfile(baseDir,'BurstFigures');
if ~exist(outDir,'dir')
    mkdir(outDir);
end
probFolders = getFullpaths([baseDir filesep 'Burst_Prob_*']);
burstFiles = cellfun(@(x) getFullpaths([x filesep 'burstDB' filesep 'UID*']),probFolders,'UniformOutput',false);
%burstAlignedFiles = cellfun(@(x) getFullpaths([x filesep 'burstDB' filesep 'UID*']),signfFolders,'UniformOutput',false);
%burstAlignedTimeWindowFiles = cellfun(@(x) getFullpaths([x filesep 'burstDB' filesep 'UID*']),signfFolders,'UniformOutput',false);
%% Plot bursts over PSTH for different Surprise levels
currGroup = burstFiles;
si = cell(numel(currGroup{1}),numel(probFolders));
for gr = 1:numel(currGroup)
    currFiles = currGroup{gr};
    parfor f = 1:numel(currFiles)
       sob = load(currFiles{f},'sob');
       sob=cellfun(@(x) x(:)',sob.sob,'UniformOutput',false);
       sob = [sob{:}];
       si{f,gr} = double(sob(~isnan(sob)));   
    end
end

[~, probColNames] = cellfun(@fileparts,probFolders,'UniformOutput',false); 
cellBurstsBySurprise=cell2table(si);
cellBurstsBySurprise.Properties.VariableNames=probColNames;
[~, cellIds] = cellfun(@fileparts,burstFiles{1},'UniformOutput',false); 
sessIds = regexp(cellIds,'session_\d{3}','match');
sessIds = [sessIds{:}]';
cellBurstsBySurprise = [cell2table(sessIds,'VariableNames',{'SessionId'}) ...
                        cell2table(cellIds,'VariableNames',{'CellId'}) ...
                        cellBurstsBySurprise];

save(fullfile(outDir,'cellBurstsBySurprise.mat'), 'cellBurstsBySurprise', 'burstFiles');

% find min/max surprise for each cellId

