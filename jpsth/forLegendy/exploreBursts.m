
%% List mat files created for analyzing bursts
baseDir = '/Volumes/schalllab/Users/Chenchal/Legendy';
signfFolders = getFullpaths([baseDir filesep 'Burst_Prob_*']);
burstFiles = cellfun(@(x) getFullpaths([x filesep 'burstDB' filesep 'UID*']),signfFolders,'UniformOutput',false);
burstAlignedFiles = cellfun(@(x) getFullpaths([x filesep 'burstDB' filesep 'UID*']),signfFolders,'UniformOutput',false);
burstAlignedTimeWindowFiles = cellfun(@(x) getFullpaths([x filesep 'burstDB' filesep 'UID*']),signfFolders,'UniformOutput',false);
%% Plot bursts over PSTH for different Surprise levels
currGroup = burstFiles;
si = cell(575,5);
for gr = 1:numel(currGroup)
    currFiles = currGroup{gr};
    for f = 1:numel(currFiles)
       sob = load(currFiles{f},'sob');
       sob=cellfun(@(x) x(:)',sob.sob,'UniformOutput',false);
       sob = [sob{:}];
       si{f,gr} = sob(~isnan(sob));
      
    end
end

