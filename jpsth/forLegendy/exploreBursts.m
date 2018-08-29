
%% List mat files created for analyzing bursts
baseDir = '/Volumes/schalllab/Users/Chenchal/Legendy';
signfFolders = getFullPaths([baseDir filesep 'Bursts_Signif_*']);
burstFiles = cellfun(@(x) getFullPaths([x filesep 'burstDB' filesep 'UID*']),signfFolders,'UniformOutput',false);
burstAlignedFiles = cellfun(@(x) getFullPaths([x filesep 'burstDB' filesep 'UID*']),signfFolders,'UniformOutput',false);
burstAlignedTimeWindowFiles = cellfun(@(x) getFullPaths([x filesep 'burstDB' filesep 'UID*']),signfFolders,'UniformOutput',false);
%% Plot bursts over PSTH for different Surprise levels



%% Sub-functions
function [ out ] = getFullPaths(pathPattern)
    d = dir(pathPattern);
    out = strcat({d.folder}', filesep, {d.name}');
end