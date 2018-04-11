classdef BurstUtils
    %BURSTUTILS Non-stateful burst utilities
    %   All methods are static. Computation state/results are not stored.
    %   All method calls will have to use classname prefix
    %
    
    methods (Static, Access=public)
        function outputArg = psbh(bobT, eobT, timeWin, fx)
            %PSBH Peri Stimulus Burst Histogram
            %   Compute PSBH, PSBH-SD, PSBH-VAR for given bob, eob times.
            %   bobT : Cell array of doubles (begining of Burst Time).  The
            %      cell array must be {nTrials x 1}. Each element in the cell
            %      array is a row vector (nTimeStamps x 1) of timestamps
            %   eobT : Cell array of doubles (begining of Burst Time).  The
            %      cell array must be {nTrials x 1}. Each element in the cell
            %      array is a row vector (nTimeStamps x 1) of timestamps
            %   timeWin: [minTime maxTime] for PSBH
            %   fx:  Built-in function-handle to be used for PSBH. Valid
            %        args are: @nanmean, @nanstd, @nanvar
            
            % for each trial convert bobT_i to eobT_i
            
            outputArg.burstRasters = cellfun(@(x,y) BurstUtils.burstToRaster(x, y, timeWin),...
                bobT, eobT, 'UniformOutput', false);
            % binWidth = 1 ms
            outputArg.psbh = fx(outputArg.burstRasters)*1000;
            outputArg.rasterBins = min(timeWin):max(timeWin);
            
        end
        
        
        function outputArg = burstAnalysis(cellSpikeTimes,timeWin, varargin)
            %BURSTANALYSIS
            outputArg = cellfun(@(x) ...
                poissBurst(x, timeWin(1), timeWin(2),varargin{:}),...
                cellSpikeTimes,'UniformOutput',false);
        end
    end
    
    %% Methods not meant to be called directly %%
    methods (Static, Access=private)
                function outputArg = burstToRaster(bobt, eobt, timeWin)
            % is there a vectorization possibility?
            srcT = min(bobt):max(eobt);
            srcRaster = zeros(1, numel(srcT));
            for i = 1:numel(bobt)
                srcRaster(find(srcT==bobt(i)):find(srcT==eobt(i))) = 1;
            end
            destT = min(timeWin):max(timeWin);
            outputArg = zeros(1,numel(destT));
            % find begin index..
            if min(bobt) < min(timeWin)
                srcBegin = find(srcT==min(timeWin));
                destBegin = 1;
            else
                srcBegin = 1;
                destBegin = find(destT==min(bobt));
            end
            % find end index..
            if max(eobt) > max(timeWin)
                srcEnd = find(srcT==max(timeWin));
                destEnd = numel(destT);
            else
                srcEnd = numel(srcT);
                destEnd = find(destT==max(eobt));
            end            
            outputArg(destBegin:destEnd) = srcRaster(srcBegin:srcEnd);
        end

        
    end
    
end

