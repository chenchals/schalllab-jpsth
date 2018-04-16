classdef BurstUtils
    %BURSTUTILS Non-stateful burst utilities
    %   All methods are static. Computation state/results are not stored.
    %   All method calls will have to use classname prefix
    %
    
    methods (Static, Access=public)
        function outputArg = psbh(bobT, eobT, timeWin)
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
            
            %             outputArg.burstRasters = cellfun(@(x,y) burstTimes2Raster(x, y, timeWin),...
            %                 bobT, eobT, 'UniformOutput', false);
            
            outputArg.burstRasters = arrayfun(@(i) burstTimes2Raster(bobT{i}, eobT{i}, timeWin),...
                (1:size(bobT,1))', 'UniformOutput', false);
            
            % binWidth = 1 ms
            fx = @nanmean;
            outputArg.psbh = fx(cell2mat(outputArg.burstRasters));
            outputArg.rasterBins = min(timeWin):max(timeWin);
        end
        
        
        function outputArg = detectBursts(cellSpikeTimes,timeWin, varargin)
            %DETECTBURSTS
            if isempty(timeWin) % use minmax of spike times for every trial
                timeWins = cellfun(@(x) [min(x) max(x)],cellSpikeTimes,'UniformOutput',false);
                % if there are empty timeWins, set them to [0 0]
                for ii=1:size(timeWins,1)
                    if isempty(timeWins{ii})
                        timeWins{ii,:}=[0 0];
                    end
                end
                timeWins = cell2mat(timeWins);
            elseif numel(timeWin) == 2
                timeWins = repmat(timeWin(:)',size(cellSpikeTimes,1),1);
            elseif size(cellSpikeTimes,1) == size(timeWin,1)
                timeWins = timeWin;
            elseif size(cellSpikeTimes,1) ~= size(timeWin,1)
                error(['The variable timeWin must be (a) empty or ',...
                    '(b) a vector of 2 values startT and stopT or ',...
                    '(c) a nTrials by 2 matrix']);
            end
            
            if isnumeric(timeWins)
                timeWins = mat2cell(timeWins,ones(size(timeWins,1),1),2);
            end
            
            outputArg = cellfun(@(x,y) ...
                poissBurst(x, y(1), y(2),varargin{:}),...
                cellSpikeTimes,timeWins,'UniformOutput',false);
            %fx_t = @(fn) cellfun(@(x) x.(fn),allBursts,'UniformOutput',false);
        end
        
        function saveOutput(oFile, resCellArray,varargin)
            % SAVEOUTPUT Saves output of burst analysis for a single unit
            % varargin:
            %     name-value pairs of args that are saved to file
            %var_fx = @(fn,y) cell2mat(cellfun(@(x) x.(fn),y,'UniformOutput',false))';
            var_fx = @(fn,y) cellfun(@(x) x.(fn), y,'UniformOutput',false);
            nTrials = size(resCellArray,1);
            analysisDate = datetime;
            save(oFile, 'analysisDate');
            if ~isempty(varargin)
                for i = 1:2:length(varargin)
                    o.(varargin{i}) = varargin{i+1};
                end
                save(oFile, '-append', '-struct', 'o');
            end
            
            fnames = fieldnames(resCellArray{1});
            for f = 1:numel(fnames)
                fn = fnames{f};
                switch fn
                    case {'fieldDefinitions', 'opts'}
                        t.(fn) = resCellArray{1}.(fn);
                    otherwise
                        temp = var_fx(fn,resCellArray);
                        tempvals = [temp{:}];
                        if numel(tempvals) == nTrials
                            t.(fn) = tempvals(:);% make a col. vector
                        else
                            %t.(fn) = [temp{:}];
                            t.(fn) = temp;
                        end
                end
                save(oFile,'-append','-struct', 't');
                clearvars t temp tempvals
            end
        end
         
    end
    
end
