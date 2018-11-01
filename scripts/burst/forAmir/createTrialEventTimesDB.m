% CREATETRIALEVENTTIMESDB Runs TrialEventTimesCalculator on all sessions
% listed in the CellInfoDB.mat file. 
%   An output variable contains all eventTimes of interese in absolute time
%   is created and augmented for all sessions.  This varibale is struct
%   similar to ttx varible in TrialTypeDB.mat. The 
% Output struct that is saved to TrialEventTimesDB.mat is:
% TrialEventTimesDB = 
%   struct with fields:
% 
%     TrialStart: {1×29 cell} => Absolute TrialStart times for 29 sessions
%         Target: {1×29 cell} => Absolute Target times for 29 sessions
%     StopSignal: {1×29 cell} => Absolute StopSignal times for 29 sessions
%      SaccStart: {1×29 cell} => Absolute SaccStart times for 29 sessions
%        SaccEnd: {1×29 cell} => Absolute SaccEnd times for 29 sessions
%           Tone: {1×29 cell} => Absolute Tone times for 29 sessions
%         Reward: {1×29 cell} => Absolute Reward times for 29 sessions
%     SecondSacc: {1×29 cell} => Absolute SecondSacc times for 29 sessions
%  
% TrialEventTimesDB.TrialStart =
%   1×29 cell array: Each cell is TrialStart times for that session.
%                    Each session is a [nTrialsForSession x 1] double 
%  This repeats for all other fields.
%
% See also TRIALEVENTTIMESCALCULATOR

    dataDir ='/Volumes/schalllab/Users/Amir/Analysis/Mat_DataFiles';
    cellInfoDbFile = '/Volumes/schalllab/Users/Amir/0-chenchal/BurstAnalysis/burstDB/CellInfoDB.mat';
    analysisDir = '/Volumes/schalllab/Users/Amir/0-chenchal/BurstAnalysis/burstDB';
    trialEventTimesDbFile = fullfile(analysisDir,'TrialEventTimesDB.mat');
    % Load cell inforamation database table
    temp = load(cellInfoDbFile);
    CellInfoDB = temp.CellInfoDB;
    clearvars temp cellInfoDbFile
    % events and vars listed in the order needed by
    % TrialEventTimesCalculator fx
    eventNames = {'TrialStart_'
        'Target_'
        'StopSignal_'
        'Sacc_of_interest'
        'SaccEnd'
        'Tone_'
        'Reward_'
        'SecondSacc'
        'SaccBegin'
        'SaccAmplitude'
        'Infos_'};
    % Used to label the trailEvent matrix for each session
    outFields = {'TrialStart'
        'Target'
        'StopSignal'
        'SaccStart'
        'SaccEnd'
        'Tone'
        'Reward'
        'SecondSacc'
        };
         
 [dataFiles,dfileInd] = unique(CellInfoDB.dataFile,'stable');
 dfullfiles = strcat(dataDir, filesep, dataFiles);
 TrialEventTimesDB = struct();
 for i = 1:numel(dfullfiles) 
     fprintf('Processing file %s\n',dfullfiles{i});
     valEvents = load(dfullfiles{i},eventNames{:});
     valEvents = struct2cell(valEvents);
     temp = TrialEventTimesCalculator(valEvents{:});
     for f = 1:numel(outFields)
         TrialEventTimesDB.(outFields{f}){i} = temp(:,f);
     end
 end
 fprintf('Saving TrialEventTimesDB to file %s\n',trialEventTimesDbFile);
 save(trialEventTimesDbFile,'TrialEventTimesDB','dataFiles')
 