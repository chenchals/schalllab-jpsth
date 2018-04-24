% CREATEBURSTSDB Runs poissBurst on sigle units for all sessions.  The cell
%   information/parameters for each single unit is defined in each row in
%   the CellInfoDB.mat file. 
% Notes: DO NOT USE DET struct for any analysis
%   Target aliged spikes (for Da valid for MG and SAT, no DET)
%         Time win: [-2500 3500]
%   To align on RT:(valid for SAT only)
%          spikeTimes - movesStruct.
    allDaData ='/mnt/teba/Users/Thomas/0-chenchal/Info/Darwin.mat'; % not useful
    analysisDir = '/mnt/teba/Users/Thomas/0-chenchal/BurstAnalysis/burstAlignedDBDarwin';
    
    %% Processing Logic
    if ~exist(analysisDir,'dir')
        mkdir(analysisDir);
    end
    
    temp = load(allDaData);
    % Load cell information
    CellInfoDB = temp.ninfoDa;% DET,MG,SAT
    % Load Spike Time data 
    spikeData = temp.spikesDa;%DET,MG,SAT
    % for Da use only MG and SAT
    trialTypes = { 'MG', 'SAT'}; 
    
    for tt = 1:numel(trialTypes)
        trialType = trialTypes{tt};
        
        
        nCells = 10;% replace later
        % for each cell -> ensure spike times is a celll array of {nTrials x 1 }
        for c = 1:nCells
            spkTimes = spikeData.(trialType)(c);% is a row of trials
            nTrials = spkTimes{:};
            
        end
        
        
    end % TrialTypes
