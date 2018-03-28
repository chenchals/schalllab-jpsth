classdef SpikeFx
    %SPIKEFX Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods (Static)
        function oSpikeTimes = groupSpikeTimes(spikeTimesAllCells, cellGroups)
            %   spikeTimesAllCells: cell array of { nTrials x mUnits}
            %           Each cell is a double [1 x nSpikeTimes] of spike times for a tiral
            %           for a given unit
            %   cellGroups: A cell array of indexs into spikeTimesAllcells
            %          example: cellGrps = {[1 2 3] [4 5 6 7 8] [9 10 11
            %          12 13 14] [15:29]
            if numel(cellGroups)==size(spikeTimesAllCells,2)
                oSpikeTimes = spikeTimesAllCells;
                return;
            end
            % if no. if cell groups is < no. of cols in spikeTimesAllCells,
            % we have more than 1 unit on some channels
            nTrials = size(spikeTimesAllCells,1);
            oSpikeTimes = cell(nTrials,numel(cellGroups));
            for i = 1:numel(cellGroups)
                c = cellGroups{i};
                z = spikeTimesAllCells(:,c);
                oSpikeTimes(:,i) = arrayfun(@(t) sort(vertcat(z{t,:})),(1:nTrials)','UniformOutput',false);               
            end
        end
         
        function outArg = rasters(cellSpikeTimes,timeWin)
            %RASTERS Construct an instance of this class
            %   outArg is a logical array.  Bins are *delays* 1 ms apart,
            %   and rasters will contain *at most* 1 spike per bin 
            minTrialIsi = cell2mat(arrayfun(@(x) min(diff(x{1})),cellSpikeTimes,'UniformOutput',false));
            if sum(minTrialIsi<1) > 0 % No of trials where spikes occur closer than 1 millisecond
                warning('Some spikes occur within 1 millisec in [%d] trials. ...Multiple spikes occuring within 1 millisec are treated as 1.', ...
                    sum(minTrialIsi<1)); 
            end
            binEdges = min(timeWin)-0.5 : max(timeWin)+0.5;            
            outArg.rasters = cell2mat(cellfun(@(x) logical(histcounts(x,'BinEdges',binEdges)),...
                cellSpikeTimes,'UniformOutput',false));
            outArg.rasterBins = min(timeWin):max(timeWin);
        end
        
        function outputArg = psth(cellSpikeTimes,binWidth,timeWin,fx)
            %PSTH Compute PSTH, PSTH-SD, PSTH-VAR for given spike times.
            %   cellSpikeTimes : Cell array of doubles (aligned spikeTimes).  The
            %      cell array must be {nTrials x 1}. Each clement in the cell
            %      array is a column vector (nTimeStamps x 1) of timestamps
            %   binWidth: Bin width in ms for PSTH
            %   timeWin: [minTime maxTime] for PSTH
            %   fx:  Built-in function-handle to be used for PSTH. Valid
            %        args are: @nanmean, @nanstd, @nanvar   
            binEdges = min(timeWin)-binWidth/2:binWidth:max(timeWin)+binWidth/2;
            rast = cell2mat(cellfun(@(x) histcounts(x,'BinEdges',binEdges),...
                             cellSpikeTimes,'UniformOutput',false));
            outputArg.psth = fx(rast)*1000./binWidth;
            outputArg.psthBins = min(timeWin):binWidth:max(timeWin);            

        end
        
        function outputArg = burstAnalysis(cellSpikeTimes,timeWin, varargin)
            %BURSTANALYSIS
            outputArg = cellfun(@(x) ...
                            poissBurst(x, timeWin(1), timeWin(2),varargin{1}),...
                            cellSpikeTimes,'UniformOutput',false);
        end
            
        %%%%%%%%% Plotting %%%%%%%%%%
        function plotPsth(psthVec,psthBins,varargin)
            %  psthVec: A vector of [1 x nTimeBins ] of firing rates
            %  psthBins: A vector of [1 x nTimeBins ] of time in ms
            %  varargin:
            %      1: scalar for Y-axis firing rate scale 
            
            plot(psthBins, psthVec,'LineWidth',2);
            xlim([min(psthBins) max(psthBins)])
            if ~isempty(varargin)
                ylim([0 varargin{1}]);
            end
            line([0 0],get(gca,'Ylim'))
        end
        
        function plotRasters(rastersLogical, rasterBins)
            SpikeFx.doRastersAndBursts_(rastersLogical, rasterBins);            
        end
       
        function plotBursts(bobTimes, eobTimes, rasterBins)
            SpikeFx.doRastersAndBursts_([], rasterBins, bobTimes, eobTimes);            
        end
        
        function plotRastersAndBursts(rastersLogical, rasterBins, bobTimes, eobTimes)
            SpikeFx.doRastersAndBursts_(rastersLogical, rasterBins, bobTimes, eobTimes);            
        end
        
        function outputArg = jpsthXcorrHist(jpsth,lagBins)
            %JPSTHXCORRHIST Summary of this method goes here
            %   Detailed explanation goes here
            % Function handle for Cross correlation histogram
            %    for -lag:lag bins of JPSTH
            % fx_xcorrh = @(jpsth,lagBins)...
            %     [-abs(lagBins):abs(lagBins);arrayfun(@(x) mean(diag(jpsth,x)),...
            %     -abs(lagBins):abs(lagBins))]';
            outputArg = [-abs(lagBins):abs(lagBins);arrayfun(@(x) mean(diag(jpsth,x)),...
                -abs(lagBins):abs(lagBins))]';
        end
        
        function outputArg = jpsthCoincidenceHist(jpsth, lagBins)
            %JPSTHCOINCIDENCEHIST Summary of this method goes here
            %   Detailed explanation goes here
            % Function handle for psth
            %fx_coinh = @getCoincidence;
            outputArg = SpikeFx.getCoincidence_(jpsth,lagBins);
        end
        
        function outputArg = getPsthFuns()
            outputArg = { @SpikeFx.rasters % rasters fx
                @SpikeFx.psth % psth fx
                };
        end
        
        function outputArg = getJpsthFuns()
            outputArg = { @SpikeFx.jpsthXcorrHist % cross-corr hist fx
                @SpikeFx.jpsthCoincidenceHist % coincidence hist fx
                };
        end
        
        function outputArg = pspKernel()
            outputArg = SpikeFx.getPspKernel_();
        end
        
    end
    
    methods (Static, Access=private)
        function [ coinh, coinMat ] = getCoincidence_(jpsth,lagBins)
            %GETCOINCIDENCE Summary of this function goes here
            %   Detailed explanation goes here
            % Note 1: Bins [1,1] is top-left and [nBins,nBins] is bottom-right
            % such that the main diagonal top-left to bottom-right is synchronous
            % firing of both cells at 0-lag. The length of task time is
            % (nBins*binWidth).
            % Note 2: Along the diagnonal is the evolution of firing (spike) synchrony
            % during the task between pair of cells. Y-Cell is cell chosen for Y-Axis
            % and X-Cell is cell chosen for X-Axis.
            % Note 3: We can thus get evolution of firing synchrony for any lag(s), as:
            % diag(0): Y-Cell fires synchronous to X-Cell with lag of (0*binWidth)
            % diag(i): Y-Cell fires synchronous to X-Cell with lag of +(i*binWidth)
            % diag(-i): Y-Cell fires synchronous to X-Cell with lag of -(i*binWidth)
            nBins = size(jpsth,1);
            
            % Aertsen
            lags = -(abs(lagBins)):abs(lagBins);
            coinMat = zeros(nBins,numel(lags));
            for i = lags
                d = diag(jpsth,i)';
                if isempty(d)
                    coinMat = [];
                    return
                end
                coinMat(abs(i)+1:end,lags==i) = d;
            end
            coinh = [(1:nBins)' sum(coinMat,2)];
            
        end
        
        function [ kernel ] = getPspKernel_()
            %function [ kernel ] = pspKernel(growth, decay)
            %PSPKERNEL Summary of this function goes here
            %   Detailed explanation goes here
            growth_ms = 1;
            decay_ms = 20;
            factor = 8;
            bins = 0:round(decay_ms*factor);
            fx_exp = @(x) exp(-bins./x);
            kernel = [zeros(1,length(bins)-1) ...
                         (1-fx_exp(growth_ms)).*fx_exp(decay_ms)]';
            kernel = kernel./sum(kernel);

            %Note: convn works column wise for matrix:
            % resultTrialsInColumns  =  convn(TrialsInRowsMatrix' ,
            %    kernelColumnVector, 'same'); % not transpose in the end
            %
            % resultTrialsInRows  =  convn(TrialsInRowsMatrix' , kernelColumnVector,
            % 'same')'; % added transpose int he end
        end
        
        
        function doRastersAndBursts_(rastersLogical, rasterBins, varargin)
            % rastersLogical: Logical matrix [nTrials x mBins]. 
            %       For a given bin, no spike = 0, spike = 1, 
            %     rasterBins: Vector of [1 x mBins]. Raster bin times in ms
            %      
            fillRatio = 0.8; % How much of the plot to fill
            tickHeightFrac = 0.9;
            vertHeight_fx = @(nTrials) (fillRatio*max(get(gca,'YLim')))/nTrials;
            
            % Plot Rasters
            if ~isempty(rastersLogical)
                nTrials = size(rastersLogical, 1);
                % Verical offset for each trial
                vertHeight = vertHeight_fx(nTrials);
                % use 90 % for vertical height for tick
                tickHeight = tickHeightFrac*vertHeight;
                % Find the trial (yPoints) and timebin (xPoints) of each spike
                [trialNos,timebins] = find(rastersLogical);
                trialNos = trialNos';
                trialNos = trialNos.*vertHeight;
                timebins = timebins';
                x = [ rasterBins(timebins);rasterBins(timebins);NaN(size(timebins)) ];
                y = [ trialNos - tickHeight/2;trialNos + tickHeight/2;NaN(size(trialNos)) ];
                plot(x(:),y(:),'k','color',[0.2 0.2 0.2 0.5]);
                xlim([min(rasterBins) max(rasterBins)])
            end
            % Plot bursts
            % If varargs then plot bursts
            if length(varargin) >= 2
                bobT = varargin{1};
                eobT = varargin{2};
                nTrials = size(bobT,1);
                SpikeFx.doBursts_(bobT,eobT,rasterBins,vertHeight_fx(nTrials));
            end

        end
        
        function doBursts_(bobTimes, eobTimes, rasterBins, varargin)
            %  bobTimes: Cell array of {nTrials x 1}
            %  eobTimes: Cell array of {nTrials x 1}
            %  Note: Each cell has [1 x nBurst_times]
            %  varargin: 
            %        vertHeight for each trial
            vertHeight = 1;
            if length(varargin) > 0
                vertHeight = varargin{1};
            end
  
            x = [ cell2mat(vertcat(bobTimes)');
                        cell2mat(vertcat(eobTimes)');
                        NaN(size(cell2mat(vertcat(bobTimes)'))) ];
                    
            trialNos = arrayfun(@(t) ones(1,numel(bobTimes{t})).*t,1:size(bobTimes,1),'UniformOutput',false);
            trialNos = cell2mat(vertcat(trialNos));
            trialNos = (trialNos.*vertHeight)-0.4*vertHeight;
            y = [ trialNos;trialNos;NaN(size(trialNos)) ];
            plot(x(:),y(:),'k','color',[0.9 0.0 0.0 0.4]);
            alpha(0.5)
            xlim([min(rasterBins) max(rasterBins)])
        end
        

        
    end
    
end

