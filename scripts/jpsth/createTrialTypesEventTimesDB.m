function [TrialTypesDB, TrialEventTimesDB] = createTrialTypesEventTimesDB()
inFile = 'SATCellInfoDB';
rootDataDir = '/Volumes/schalllab/data';
inRootAnalysisDir = '/Volumes/schalllab/Users/Chenchal/JPSTH';
thomasSatFile = '/Volumes/schalllab/Users/Thomas/SAT/Data/data_SAT_SEF.mat';

%% Process
db = load(fullfile(inRootAnalysisDir,inFile));
temp = load(thomasSatFile,'-regexp','^(moves|info)(Da|Eu)$');
thomasSat = [struct2table(temp.infoDa.SAT);struct2table(temp.infoEu.SAT)];
thomasSat.resptime = [{temp.movesDa.resptime},{temp.movesEu.resptime}]';

uniqMonkSessNo = unique(db.CellInfoDB.monkSessNo);
uniqSessionFile = unique(db.CellInfoDB.datafile);
uniqSessionFullfile = cellfun(@(x,f) fullfile(rootDataDir,...
    regexprep(x(1),{'D','E'},{'Darwin','Euler'}),'SAT/Matlab',f),...
    uniqMonkSessNo, uniqSessionFile,'UniformOutput',false);

sessions = regexprep(uniqSessionFile,'(.*)-.*','$1');
idx2ThomasSat = cell2mat(cellfun(@(x) find(ismember(sessions,x)),thomasSat.session,'UniformOutput',false));
% Create TrialTypes for each session
% Regexp for all vars ending in '_' and not starting with Eye or Pupil
vars2LoadRegEx = '.*_$(?<!^(Eye|Pupil).*)|saccLoc';
TrialTypesDB = struct();
TrialEventTimesDB = struct();
for s = 1:numel(uniqSessionFullfile)
    sessionFile = uniqSessionFullfile{s};
    vars = load(sessionFile,'-regexp',vars2LoadRegEx);
    
    fprintf('Doing session [%s]...\n',sessionFile);
    
    nTrials = size(vars.Correct_,1);
    TrialTypesDB.session{s,1} = sessions{s};
    %% Trial type and conditions
    % From Thomas' code
    % info(kk).condition = transpose(uint8(SAT_(:,1))); %1==accurate, 3==fast
    accurate = vars.SAT_(:,1) == 1;
    fast = vars.SAT_(:,1) == 3;
    correct = vars.Correct_(:,2) ==1;
    % From Thomas' code
    % Response information
    nosacc = vars.Errors_(:,2) == 1;
    err_hold = vars.Errors_(:,4) == 1;
    err_dir = vars.Errors_(:,5) == 1;
    err_time = vars.Errors_(:,6) == 1 | vars.Errors_(:,7) == 1;
    % Different Trial types
    TrialTypesDB.Accurate{s,1} = accurate;
    TrialTypesDB.AccurateCorrect{s,1} = accurate & correct;
    TrialTypesDB.AccurateErrorHold{s,1} = accurate & err_hold;
    TrialTypesDB.AccurateErrorChoice{s,1} = accurate & err_dir;
    TrialTypesDB.AccurateErrorTiming{s,1} = accurate & err_time;
    TrialTypesDB.AccurateErrorNoSaccade{s,1} = accurate & nosacc;
    TrialTypesDB.Fast{s,1} = fast;
    TrialTypesDB.FastCorrect{s,1} = fast & correct;
    TrialTypesDB.FastErrorHold{s,1} = fast & err_hold;
    TrialTypesDB.FastErrorChoice{s,1} = fast & err_dir;
    TrialTypesDB.FastErrorTiming{s,1} = fast & err_time;
    TrialTypesDB.FastErrorNoSaccade{s,1} = fast & nosacc;
    % Stimulus/Response Location
    TrialTypesDB.SingletonLoc{s,1} = vars.Target_(:,2);
    TrialTypesDB.ResponseLoc{s,1} = vars.saccLoc;
    
    %% SAT event times
    TrialEventTimesDB.session{s,1} = sessions{s};
    TrialEventTimesDB.CueOn{s,1} = nan(nTrials,1);
    if isfield(vars,'Target_')
        TrialEventTimesDB.CueOn{s,1} = vars.Target_(:,1);       
    end
    TrialEventTimesDB.FixAcquisition{s,1} = nan(nTrials,1);
    if isfield(vars,'FixAcqTime_')
        TrialEventTimesDB.FixAcquisition{s,1} = vars.FixAcqTime_(:,1);       
    end
    TrialEventTimesDB.TargetDeadline{s,1} = nan(nTrials,1);
    if isfield(vars,'SAT_')
        temp = vars.SAT_(:,3);
        temp(temp > 1000) = NaN;
        TrialEventTimesDB.TargetDeadline{s,1} = temp; 
        clearvars temp;
    end    
    TrialEventTimesDB.SaccadePrimaryTempo{s,1} = nan(nTrials,1);
    if isfield(vars,'SRT')
        TrialEventTimesDB.SaccadePrimaryTempo{s,1} = vars.SRT(:,1);       
    end
    TrialEventTimesDB.ToneOn{s,1} = nan(nTrials,1);
    if isfield(vars,'ToneOn_')
        TrialEventTimesDB.ToneOn{s,1} = vars.ToneOn_(:,1);       
    end
    TrialEventTimesDB.RewardOn{s,1} = nan(nTrials,1);
    if isfield(vars,'JuiceOn_')
        TrialEventTimesDB.RewardOn{s,1} = vars.JuiceOn_(:,1);       
    end

    % from Data saved by Thomas.
    TrialEventTimesDB.SaccadePrimary{s,1} = nan(nTrials,1);
    if isfield(thomasSat,'resptime')
        TrialEventTimesDB.SaccadePrimaryTempo{s,1} = [thomasSat(idx2ThomasSat(s)).resptime{:}]';       
    end   
end
TrialTypesDB = struct2table(TrialTypesDB);
TrialEventTimesDB = struct2table(TrialEventTimesDB);

end
