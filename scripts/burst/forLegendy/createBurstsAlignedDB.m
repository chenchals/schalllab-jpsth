% CREATEBURSTSALIGNEDDB For each file [UID_0000_session_000.mat] saved
% after running burst detector (createBurstsDB.m), align the burst times
% for all trials for a given session.  The align times are got from the
% TrialEventTimes.mat created by createTrialEventTimes.m. Load this mat
% file for getting event times for each session in absolute time. 
%
% See also CREATEBURSTSDB, CREATETRIALEVENTTIMES, TRIALEVENTTIMESCALCULATOR

    baseDir = '/mnt/teba/Users/Chenchal/Legendy/Bursts_Signif_1E_minus_05';

    dataDir = fullfile('/mnt/teba','Users/Amir/Analysis/Mat_DataFiles');
    burstDbDir = fullfile(baseDir,'burstDB');
    cellInfoDbFile = fullfile(burstDbDir,'CellInfoDB.mat');
    trialEventTimesDbFile = fullfile(burstDbDir,'TrialEventTimesDB.mat');
    analysisDir = fullfile(baseDir,'burstAlignedDB');
    
    %% Processing Logic %%
    if ~exist(analysisDir,'dir')
        mkdir(analysisDir);
    end
    % Copy CellInfoDB and TrialEventTimesDB file to the analysis Dir for
    % future reference
    copyfile(cellInfoDbFile, fullfile(analysisDir,'.'));
    copyfile(trialEventTimesDbFile, fullfile(analysisDir,'.'));
    
    % Get a list of all initial burst files that have have a mask of UID_xxxx_session_yyy.mat
    burstFiles = dir(fullfile(burstDbDir,'UID*.mat'));
    burstFullfiles = strcat(burstFiles(1).folder,filesep,{burstFiles.name}');
    [~,burstFiles,~] = cellfun(@fileparts,burstFullfiles,'UniformOutput',false);
    
    % Load TrialEventTimesDB 
    temp = load(trialEventTimesDbFile);
    alignTimesDb = temp.TrialEventTimesDB;
    alignEvents = fieldnames(alignTimesDb);
    alignTimesDbFilenames = temp.dataFiles; 
    clearvars temp
    
    %parpool(20);
    % had to update code for cell 569 all bobT are NaN except 1
    % so bobT will be numeric and not a cell array, so convert to cell
    % array by calling num2cell in BurstUtils.alignForTrials
    parfor i = 1:numel(burstFullfiles)
        aBursts = struct();
        burstF = burstFullfiles{i};
        analysisFile = fullfile(analysisDir,[burstFiles{i} '_aligned.mat']);
        fprintf('Aligning bursts for file %s\n',burstF);
        % Load burst file
        cellBursts = load(burstF);        
        cellInfo = cellBursts.cellInfo;
        datafile = cellInfo.dataFile{1};
        sessionIndex = find(strcmp(alignTimesDbFilenames,datafile));
        o = struct();
        for e = 1:numel(alignEvents)
            eventName = alignEvents{e};
            alignTimes = alignTimesDb.(eventName){sessionIndex};
            aBursts.(['bobT_' eventName '_aligned']) = BurstUtils.alignForTrials(...
                cellBursts.bobT,'alignTimes',alignTimes);
            aBursts.(['eobT_' eventName '_aligned']) = BurstUtils.alignForTrials(...
                cellBursts.eobT,'alignTimes',alignTimes);
            
            aBursts.(['spkTWin_' eventName '_aligned']) = BurstUtils.alignForTrials(...
                cellBursts.spkTWin,'alignTimes',alignTimes);
            
            alignedTimeWins = cellfun(@(x,y) x-y, cellBursts.timeWin,...
                              num2cell(alignTimes), 'UniformOutput', false);
            
            aBursts.(['isBursting_' eventName '_aligned']) = BurstUtils.convert2logical(...
                aBursts.(['bobT_' eventName '_aligned']),...
                aBursts.(['eobT_' eventName '_aligned']),...
                alignedTimeWins);
            
        end
        % add other fields like number of dob (duration of burst etc)
        fn = fieldnames(cellBursts);       
        for f = 1:numel(fn)
            aBursts.(fn{f})=cellBursts.(fn{f}); 
        end
        if isfield(aBursts, 'analysisDate')
            aBursts.analysisDate(1,end+1) = datetime;
        else
            aBursts.analysisDate = datetime;
        end

        aBursts = orderfields(aBursts);
        saveFile(analysisFile, aBursts);

        fprintf('wrote file %s\n\n',analysisFile);
    end
    
    function saveFile(fname, outStruct)
       save(fname, '-struct', 'outStruct');
    end
