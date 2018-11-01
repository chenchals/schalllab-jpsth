inFile = 'SATCellInfoDB';
rootDataDir = '/Volumes/schalllab/data';
inRootAnalysisDir = '/Volumes/schalllab/Users/Chenchal/JPSTH';

db = load(fullfile(inRootAnalysisDir,inFile));

uniqMonkSessNo = unique(db.CellInfoDB.monkSessNo);
cellNosBySession = arrayfun(@(x) find(contains(db.CellInfoDB.monkSessNo,x)), uniqMonkSessNo, 'UniformOutput',false);
uniqSessionFile = unique(db.CellInfoDB.datafile);

uniqSessionFullfile = cellfun(@(x,f) fullfile(rootDataDir,...
    regexprep(x(1),{'D','E'},{'Darwin','Euler'}),'SAT/Matlab',f),...
    uniqMonkSessNo, uniqSessionFile,'UniformOutput',false);
% Create TrialTypes for each session
% Regexp for all vars ending in '_' and not starting with Eye or Pupil
vars2LoadRegEx = '.*_$(?<!^(Eye|Pupil).*)|saccLoc';
[mapTarget_,mapErrors_] = SATDefinitions();
TrialTypesDB = struct();
TrialEventTimesDB = struct();
fieldDescriptions = containers.Map();
for s = 1:numel(uniqSessionFullfile)
    sessionFile = uniqSessionFullfile{s};
    vars = load(sessionFile,'-regexp',vars2LoadRegEx);
    %% Decode Target_ variable
    keys = mapTarget_.IndexToName.keys;
    for k = 1: numel(keys)
        key = keys{k};
        fn = mapTarget_.IndexToName(key);
        TrialTypesDB.(fn){s,1} = vars.Target_(:,key);
        fieldDescriptions(fn) = ['var Target_(:,',num2str(key),'):', mapTarget_.IndexToDesc(key)];
    end
    nKeys = numel(keys);
    while nKeys < size(vars.Target_,2)
        nKeys = nKeys + 1;
        fn = num2str(nKeys,'Target_Column%d');
        TrialTypesDB.(fn){s,1} = vars.Target_(:,nKeys);
        fieldDescriptions(fn) = ['var Target_(:,',num2str(nKeys),'):','Unknown' ];
    end
    %  From Thomas' code
    TrialTypesDB.tgt_octant{s,1} = vars.Target_(:,2) + 1;
    fieldDescriptions('tgt_octant') = 'Thomas: Target location - 1 based';
    TrialTypesDB.tgt_eccen{s,1} = vars.Target_(:,12);
    fieldDescriptions('tgt_eccen') = 'Thomas: Target Eccentricity';
    
    %% Decode Errors_ variable
    keys = mapErrors_.IndexToName.keys;
    for k = 1: numel(keys)
        key = keys{k};
        fn = mapErrors_.IndexToName(key);
        TrialTypesDB.(fn){s,1} = vars.Errors_(:,key) == 1;
        fieldDescriptions(fn) = ['var Errors_(:,',num2str(key),'):', mapErrors_.IndexToDesc(key)];
    end
    nKeys = numel(keys);
    while nKeys < size(vars.Errors_,2)
        nKeys = nKeys + 1;
        fn = num2str(nKeys,'Errors_Column%d');
        TrialTypesDB.(fn){s,1} = vars.Errors_(:,nKeys) == 1;
        fieldDescriptions(fn) = ['var Errors_(:,',num2str(nKeys),'):','Unknown' ];
    end
    % From Thomas' code
    % Response information
    TrialTypesDB.err_nosacc{s,1} = vars.Errors_(:,2) == 1;
    fieldDescriptions('err_nosacc') = 'Thomas: Error No Saccade';
    TrialTypesDB.err_hold{s,1} = vars.Errors_(:,4) == 1;
    fieldDescriptions('err_hold') = 'Thomas: Error Hold';
    TrialTypesDB.err_dir{s,1} = vars.Errors_(:,5) == 1;
    fieldDescriptions('err_dir') = 'Thomas: Error Choice';
    TrialTypesDB.err_time1{s,1} = vars.Errors_(:,6) == 1;
    fieldDescriptions('err_time1') = 'Thomas: Used to compute Timing error';
    TrialTypesDB.err_time2{s,1} = vars.Errors_(:,7) == 1;
    fieldDescriptions('err_time1') = 'Thomas: Used to compute Timing error';
    TrialTypesDB.err_time{s,1} = vars.Errors_(:,6) == 1 | vars.Errors_(:,7) == 1;
    fieldDescriptions('err_time') = 'Thomas: Error Timing = (err_time1 | err_time2)';
 
    %% Decode SAT_ variable
        % From Thomas' code
        % info(kk).condition = transpose(uint8(SAT_(:,1))); %1==accurate, 3==fast
        TrialTypesDB.condition{s,1} = vars.SAT_(:,1);
        TrialTypesDB.condition_accurate{s,1} = vars.SAT_(:,1) == 1;
        TrialTypesDB.condition_fast{s,1} = vars.SAT_(:,1) == 3;
        %Target/stimulus information
        temp = vars.SAT_(:,3);
        temp(temp > 1000) = NaN;
        TrialTypesDB.tgt_deadline{s,1} = temp;
    
    
    %outcomeTbl.sacc_octant = vars.saccLoc + 1;
    
    %Check this: Neurophys/compute_SDF_from_reward_SAT.m
    %  idx_corr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_hold);
    % idx_errtime = (~binfo(kk).err_dir & binfo(kk).err_time);
    % idx_errdir  = ( binfo(kk).err_dir & ~binfo(kk).err_time);

    
    
    % Process Times separately
    %outcomeTbl.tempo_RT = vars.SRT(:,1); %TEMPO estimate of RT
    
    
end


%% Code from Thomas -
function [ info ] = load_task_info_for_reference( info , sessions , num_trials , type )

NUM_SESSIONS = length(sessions);

for kk = 1:NUM_SESSIONS
    file_kk = [sessions(kk).folder,'/',sessions(kk).name(1:16),type,'.mat'];
    
    info(kk).session = sessions(kk).name(1:12);
    
    %no DET data for Da/Eu first session
    if (strcmp(type, 'DET') && (kk == 1))
        info(kk).num_trials = 0;
        continue
    end
    
    load(file_kk, 'SAT_','Errors_','Target_','SRT','saccLoc','FixAcqTime_','JuiceOn_')
    
    %Session information
    info(kk).num_trials = length(SAT_(:,1));
    info(kk).condition = transpose(uint8(SAT_(:,1))); %1==accurate, 3==fast
    
    %Target/stimulus information
    
    tgt_dline = transpose(SAT_(:,3));
    tgt_dline(tgt_dline > 1000) = NaN;
    
    info(kk).tgt_octant = transpose(uint8(Target_(:,2) + 1));
    info(kk).tgt_eccen = transpose(Target_(:,12));
    info(kk).tgt_dline = tgt_dline;
    
    %Response information
    
    info(kk).err_nosacc = false(1,num_trials(kk));   info(kk).err_nosacc(Errors_(:,2) == 1) = true;
    info(kk).err_hold = false(1,num_trials(kk));   info(kk).err_hold(Errors_(:,4) == 1) = true;
    info(kk).err_dir = false(1,num_trials(kk));    info(kk).err_dir(Errors_(:,5) == 1) = true;
    info(kk).err_time = false(1,num_trials(kk));   info(kk).err_time((Errors_(:,6) == 1) | (Errors_(:,7) == 1)) = true;
    
    info(kk).octant = uint8(saccLoc+1)';
    info(kk).resptime = SRT(:,1)'; %TEMPO estimate of RT
    
    if exist('JuiceOn_', 'var')
        load(file_kk, 'JuiceOn_')
        info(kk).rewtime = JuiceOn_';
    else
        fprintf('Warning -- "JuiceOn_" does not exist -- %s\n', info(kk).session)
        info(kk).rewtime = NaN(1,num_trials(kk));
    end
    
    if exist('FixAcqTime_', 'var')
        load(file_kk, 'FixAcqTime_')
        info(kk).fixtime = FixAcqTime_';
    else %variable FixAcqTime_ does not exist
        fprintf('Warning -- "FixAcqTime_" does not exist -- %s\n', info(kk).session)
        info(kk).fixtime = NaN(1,num_trials(kk));
    end
    
end%for:sessions

end%function:load_task_info
