%% Cross-area JPSTH analysis of cell pairs
% FEF_SC both X and Y cell must be Visual 
% [includes V,VM]
%-----------------------------------
%   Criteria      |  XCell  |  YCell
%-----------------|---------|-------
%            Area |  FEF    |   SC
% [Vis, Mov, Fix] | [1,~,~] | [1,~,~]
%-----------------------------------
%
%      RF of Cells          |
%---------------------------|------------
%         Targ. IN X & IN Y |   AND(X,Y)
%       Targ. IN X NOT in Y |   XOR(X,Y)
%       Targ. IN Y NOT in X |   XOR(X,Y)
% Targ. NOT in X & NOT in Y |   NOT(X|Y)
%-----------------------------------
%    
%% Options for JPSTH computation
binWidth = 5;
% -25 to +25 ms
coincidenceBins = 5;
area1 = 'FEF';
area2 = 'SC';

rootDataDir = '/Volumes/schalllab/data';
rootAnalysisDir = '/Volumes/schalllab/Users/Chenchal/JPSTH';
jpsthResultsDir = fullfile(rootAnalysisDir,['FEF_SC_Visual' num2str(binWidth,'_%dB')]);
if ~exist(jpsthResultsDir, 'dir')
    mkdir(jpsthResultsDir);
end

% Info files
jpshPairsFile = fullfile(rootAnalysisDir,'JPSTH_PAIRS_CellInfoDB.mat');
trialTypesFile = fullfile(rootAnalysisDir,'TrialTypesDB.mat');
trialEventTimesFile = fullfile(rootAnalysisDir,'TrialEventTimesDB.mat');
% Setup time windows for different event time alignment, the field names
% SHALL correspond to column names for trialEventTimes below.
alignEventTimeWin = containers.Map;
alignEventTimeWin('CueOn') = [-700 400];
%% Load all JPSTH pair information
% load variable: JpsthPairsCellInfo
jpsthCellPairs = load(jpshPairsFile);
jpsthCellPairs = jpsthCellPairs.JpsthPairCellInfoDB;

% Filter cell pairs for FEF/SC
jpsthCellPairs = jpsthCellPairs(contains(jpsthCellPairs.X_area,area1) & contains(jpsthCellPairs.Y_area,area2),:);
% Filter cell pairs for Visual = 1.0
visIdx = cellfun(@(x,y) x(1)==1 & y(1)==1, jpsthCellPairs.X_visMovFix,jpsthCellPairs.Y_visMovFix);
jpsthCellPairs = jpsthCellPairs(visIdx,:);

% Data files for the filtered cell pairs
jpsthCellPairs.folder = cellfun(@(x) fullfile(rootDataDir,...
    regexprep(x(1),{'D','E'},{'Darwin','Euler'}),'SAT/Matlab'),...
    jpsthCellPairs.datafile,'UniformOutput',false);
sessFiles = jpsthCellPairs.datafile;
% Group by session
rowIdsOfPairsBySession = arrayfun(@(x) find(contains(jpsthCellPairs.datafile,x)), ...
                    unique(jpsthCellPairs.datafile),'UniformOutput',false);
sessions = regexprep(unique(jpsthCellPairs.datafile),'-RH_.*mat','');

%% Load Trial Types and Trial Event Times and filter for the sessions of interest above
% TrialTypes
trialTypes = load(trialTypesFile);
trialTypes = trialTypes.TrialTypesDB;
% Filter trialTypes to have only sesisons of interest
trialTypes = trialTypes(cellfun(@(x) find(strcmpi(trialTypes.session, x)),sessions),:);
% TrialEventTimes
trialEventTimes = load(trialEventTimesFile);
trialEventTimes = trialEventTimes.TrialEventTimesDB;
%retain only sesisons which have jpsth pairs
trialEventTimes = trialEventTimes(cellfun(@(x) find(strcmpi(trialEventTimes.session, x)),sessions),:);
% Available conditions - 
% (Accurate|Fast)*(Correct|ErrorHold|ErrorChoice|ErrorTiming|ErrorNoSaccade)
availConditions = regexp(trialTypes.Properties.VariableNames,'(Accurate.+)|(Fast.+)','match');
availConditions = [availConditions{:}]';

%% Group by singleton location in RF fo X and Y cell
rfLocNames = {'inXandY','inXnotY','inYnotX','notInXorY'};
fx_groupRFs = @(xRF,yRF) deal(xRF, yRF, intersect(xRF,yRF), setdiff(xRF,yRF),...
                setdiff(yRF,xRF), setdiff(0:7,[xRF(:);yRF(:)]));
[rfLocs.xRF,rfLocs.yRF,rfLocs.(rfLocNames{1}),rfLocs.(rfLocNames{2}),rfLocs.(rfLocNames{3}),rfLocs.(rfLocNames{4})] = ...
    cellfun(@(xRF,yRF) fx_groupRFs(xRF,yRF), jpsthCellPairs.X_RF, jpsthCellPairs.Y_RF,'UniformOutput',false);
rfLocs = struct2table(rfLocs);
%% For each grouped cell pairs by session dir JPSTHs for every pair
for s = 1:numel(rowIdsOfPairsBySession)
    rowIdsForPairs = rowIdsOfPairsBySession{s};
    pairsTodo = jpsthCellPairs(rowIdsForPairs,:);
    nPairs = size(pairsTodo,1);
    file2load = fullfile(pairsTodo.folder{1},pairsTodo.datafile{1});
    [~,sessionName] = fileparts(file2load);
    sessionTrialEventTimes = trialEventTimes(s,:);
    sessionTrialTypes = trialTypes(s,:);
    sessionRfLocs = rfLocs(rowIdsForPairs,:);
    fprintf('\nDoing JPSTH for session [%s].......\n',sessionName);
    % for each pair of cells
    tempConditions = struct();
    for pair = 1:nPairs
        currPair = pairsTodo(pair,:);
        XCellId = currPair.X_cellIdInFile{1};
        YCellId = currPair.Y_cellIdInFile{1};
        pairFilename = char(join({currPair.Pair_UID{1},sessionName,...
            XCellId,currPair.X_area{1},...
            YCellId,currPair.Y_area{1}},'_'));
        fprintf('Processing Pair : %s...\n',pairFilename);
        units = load(file2load,XCellId,YCellId);
        for rf = 1:numel(rfLocNames)
            rfLocName = rfLocNames{rf};
            rfLocs = sessionRfLocs.(rfLocName){pair};
            if isempty(rfLocs) || isnan(rfLocs)
                tempConditions.(rfLocName) = [];
            else
                
            end
            
        end
        % Save for the current pair
    end
end


