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
                % if there are any empty timeWins, ie the trial had NaN or
                % zero spikes then, set those timeWins to [0 0]
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
        
        function outputArg = loadBursts(cellNos,fileList,blacklistedUIDs)
            outputArg = struct();
            for i = 1:numel(cellNos)
                cellNo = cellNos(i);
                cellUID =  num2str(cellNo,'UID_%04d');
                if ~sum(contains(blacklistedUIDs,cellUID))
                    fileIndex = find(~cellfun(@isempty,regexp(fileList,cellUID,'match')));
                    burstFile = fileList{fileIndex}; %#ok<FNDSB>
                    outputArg{i,1} = load(burstFile);
                end
            end
        end
        
        function outputArg = alignForTrials(burstTimes, varargin)
            defaultArgs = {'alignTimes', [], @isnumeric,...
                'timeWin', [], @(x) isnumeric(x) && numel(x)==2 && diff(x)>0,...
                'trials', [] @isnumeric};
            argParser = BurstUtils.createArgParser(defaultArgs);
            if ~isempty(varargin)
                argParser.parse(varargin{:});
            end
            args = argParser.Results;
            % do alignTimes first
            if numel(args.alignTimes)==1
                outputArg = cellfun(@(b) b-args.alignTimes, burstTimes,'UniformOutput', false);
            elseif numel(args.alignTimes) == size(burstTimes,1)
                alignTimes = arrayfun(@(x) {x}, args.alignTimes);
                outputArg = cellfun(@(b,t) b-t, burstTimes, alignTimes, 'UniformOutput', false);
            else
                error('Number of times in alignTimes must be 1 or equal to no of trials in burstTimes');
            end
            % Select trials, intentionally selecting AFTER alignment
            if numel(args.trials) > 0
                outputArg = outputArg(args.trials);
            end
            % output only windowed bursts
            if ~isempty(args.timeWin)
                outputArg = cellfun(@(x) x(x>=args.timeWin(1) && x<=args.timeWin(2)),...
                                    outputArg, 'UniformOutput', false);
            end
            
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
    
    methods (Static, Access=private)
        
        function argParser = createArgParser(varargin)
           argParser = inputParser();
           args = varargin{1};
           if numel(args) == 0 || mod(numel(args),3)==1
               error(['When creating argParser the no. of argumets must be greater than zero '...
                   'and must be EVEN corresponding to key-value pairs, where value is the default value']);
           end
           for  i = 1:3:numel(args)
               argParser.addParameter(args{i},args{i+1},args{i+2});
           end
           argParser.parse();
        end
        
    end
    
end

