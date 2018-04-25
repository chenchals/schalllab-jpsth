% CREATESELECTALIGNEDBURSTSDB Selects a subset of aligned bursts for time
% window. The time window may vary for each alignment.
% For each file [UID_0000_session_000_aligned.mat] saved
% after running aliging bursts to different events (createBurstsAlignedDB.m).
% The align times are got from the TrialEventTimes.mat created by createTrialEventTimes.m. . 
%
% See also CREATEBURSTSDB, CREATETRIALEVENTTIMES, TRIALEVENTTIMESCALCULATOR

    baseDir = '/mnt/teba';

    dataDir = fullfile(baseDir,'Users/Amir/Analysis/Mat_DataFiles');
    burstAlignedDbDir = fullfile(baseDir,'Users/Amir/0-chenchal/BurstAnalysis2/burstAlignedDB');
    cellInfoDbFile = fullfile(baseDir,'Users/Amir/0-chenchal/BurstAnalysis2/burstAlignedDB/CellInfoDB.mat');
    trialEventTimesDbFile = fullfile(baseDir,'Users/Amir/0-chenchal/BurstAnalysis2/burstAlignedDB/TrialEventTimesDB.mat');
    analysisDir = fullfile(baseDir,'Users/Amir/0-chenchal/BurstAnalysis2/burstAlignedTimeWindowDB');
    
    % Aligning event time windows to use
    alignEventTimeWin.Reward = [-800 500];
    alignEventTimeWin.Tone = [-800 800];
    alignEventTimeWin.SaccEnd = [-700 800];
    alignEventTimeWin.SaccStart = [-700 800];
    alignEventTimeWin.Target = [-500 800];
    alignEventTimeWin.SecondSacc = [-1000 1000];
    alignEventTimeWin.StopSignal = [-700 1200];
    alignEventTimeWin.TrialStart = [0 2000];
        
    %% Processing Logic %%
    if ~exist(analysisDir,'dir')
        mkdir(analysisDir);
    end
    % Copy CellInfoDB and TrialEventTimesDB file to the analysis Dir for
    % future reference
    copyfile(cellInfoDbFile, fullfile(analysisDir,'.'));
    copyfile(trialEventTimesDbFile, fullfile(analysisDir,'.'));
    
    % Get a list of all initial burst files that have have a mask of UID_xxxx_session_yyy.mat
    burstFiles = dir(fullfile(burstAlignedDbDir,'UID*_aligned.mat'));
    burstFullfiles = strcat(burstFiles(1).folder,filesep,{burstFiles.name}');
    [~,burstFiles,~] = cellfun(@fileparts,burstFullfiles,'UniformOutput',false);
    
   
    %parpool(20);
    % had to update code for cell 569 all bobT are NaN except 1
    % so bobT will be numeric and not a cell array, so convert to cell
    % array by calling num2cell in BurstUtils.alignForTrials
    parfor ii = 1:numel(burstFullfiles)
        tic
        burstF = burstFullfiles{ii};
        analysisFile = fullfile(analysisDir,[burstFiles{ii} '_timeWin.mat']);
        fprintf('Aligning bursts for file %s\n',burstF);
        % Load burst file
        burstData = load(burstF);        
        allFns = fieldnames(burstData);
        bobFns= allFns(contains(allFns,'bobT_'));
        eobFns= allFns(contains(allFns,'eobT_'));
        spkTWinFns= allFns(contains(allFns,'spkTWin_'));
        
        aeFields = fieldnames(alignEventTimeWin);
        
        for ae = 1:numel(aeFields)
            aeName = aeFields{ae};
            oFn = [aeName '_aligned_timeWin'];
            bobFn = bobFns{contains(bobFns, aeName)};
            eobFn = eobFns{contains(eobFns, aeName)};
            spkTWinFn = spkTWinFns{contains(spkTWinFns, aeName)};
            twin = alignEventTimeWin.(aeName);
            
            temp = BurstUtils.selectBurstsInTimeWin(...
                       burstData.(bobFn), burstData.(eobFn), twin);
             o.(oFn).bobT = temp.bobs;
             o.(oFn).eobT = temp.eobs;
             o.(oFn).spkTWin = cellfun(@(x) x(x>=twin(1) & x<=twin(2)),...
                       burstData.(spkTWinFn),'UniformOutput',false);
             o.(oFn).isBursting = BurstUtils.convert2logical(temp.bobs,temp.eobs,twin);      
             % prune other fields from cellBurst data
             bothIndices = temp.bothBobAndEobInds;
             for j = 1:numel(bothIndices)
                 jj = bothIndices{j};
                 if ~any(jj)
                     o.(oFn).dobT{j,1} = [];
                     o.(oFn).nsdb{j,1} = [];
                     o.(oFn).nsdibi{j,1} = [];
                     o.(oFn).frdb{j,1} = [];
                     o.(oFn).frdibi{j,1} = [];
                 else
                     o.(oFn).dobT{j,1} = burstData.dobT{j}(jj);
                     o.(oFn).nsdb{j,1} = burstData.nsdb{j}(jj);
                     o.(oFn).frdb{j,1} = burstData.frdb{j}(jj);
                     if numel(jj) <=1
                        o.(oFn).nsdibi{j,1} = [];
                        o.(oFn).frdibi{j,1} = [];
                     else
                        o.(oFn).nsdibi{j,1} = burstData.nsdibi{j}(jj(1:end-1));
                        o.(oFn).frdibi{j,1} = burstData.frdibi{j}(jj(1:end-1));
                     end
                     
                 end
             end
        end
        % convert aligned fields of struct to table
        fns = fieldnames(o);
        for kk = 1:numel(fns)
            o.(fns{kk}) = struct2table(o.(fns{kk}));
        end
        % add other fields
        o.fieldDefinitions = burstData.fieldDefinitions;
        o.alignEventTimeWin = alignEventTimeWin;
        o.burstOpts = burstData.opts;
        o.cellInfo = burstData.cellInfo;

        o = orderfields(o);
        saveFile(analysisFile, o);

        fprintf('wrote file %s\n\n',analysisFile);
        %clearvars o fns 
        toc
    end

    
    function saveFile(fname, outStruct)
       save(fname, '-struct', 'outStruct');
    end
