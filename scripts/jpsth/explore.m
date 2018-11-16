% input is spiketimes or binned spike times
%figDir = '/Volumes/schalllab/Users/Chenchal/JPSTH/FigsBinWidth_5/PAIR_0226_E20130829001-RH_SEARCH_DSP16a_SEF_DSP17a_SC.mat';%
figDir = '/Volumes/schalllab/Users/Chenchal/JPSTH/FigsBinWidth_5';%
files = dir(fullfile(figDir,'PAIR*.mat'));
fns = {files.name}';
files = strcat({files.folder}',filesep,{files.name}');
conditions = whos('-file',files{1});
conditions = {conditions.name}';
conditions(strcmpi(conditions,'cellPairInfo'))=[];
alignedEvents = {'CueOn';'SaccadePrimary';'RewardOn'};
jpMinMax = struct();
fx_minmax = @(x) [min(x(:)) max(x(:))];
for ii = 1:numel(files)
    currFile = files{ii};
    [~,pairName] = fileparts(currFile);
    jpMinMax(ii).pairName = pairName;
    tic
    pairConds = load(currFile);
    cellPairInfo = pairConds.cellPairInfo;
    for cc = 1:numel(conditions)
        condition = conditions{cc};
        pair = pairConds.(condition);
        if isempty(pair)
            jpMinMax(ii).(condition) = nan(3,2);
        else

            jpsth = pair.normalizedJpsth;
            jpMinMax(ii).(condition) = cell2mat(cellfun(fx_minmax,jpsth,'UniformOutput',false));
            jpMinMax(ii).(['grand_' condition])= fx_minmax(jpMinMax(ii).(condition));

            %imagesc(flipud(jpsth));
            
        end
        title(pairName,'Interpreter','none')
    end % each condition
    toc
end