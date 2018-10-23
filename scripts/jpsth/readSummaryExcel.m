function [darwinCellInfos, eulerCellInfos] = readSummaryExcel()

    rootAnalysisDir = '/Volumes/schalllab';
    rootDataDir = '/Volumes/schalllab/data';

    summaryFileDir = fullfile(rootAnalysisDir,'Users/Chenchal/JPSTH/');
    darwinSummaryFile = fullfile(summaryFileDir,'Darwin_SAT_colorRecode.xlsx');
    eulerSummaryFile = fullfile(summaryFileDir,'Euler_SAT_colorRecode.xlsx');

    % Directory of translated Data files: .mat files
    darwinMatDir = fullfile(rootDataDir,'Darwin/SAT/Matlab');
    eulerMatDir = fullfile(rootDataDir,'Euler/SAT/Matlab');

    % Directory of raw Data files: .plx files
    darwinPlxDir = fullfile(rootDataDir,'Darwin/SAT/Plexon/Sorted');
    eulerPlxDir = fullfile(rootDataDir,'Euler/SAT/Plexon/Sorted');

    % Darwin files
    darwin.matfiles = struct2table(dir(fullfile(darwinMatDir,'D*.mat')));
    darwin.plxfiles = struct2table(dir(fullfile(darwinPlxDir,'D*.plx')));
    % Euler files
    euler.matfiles = struct2table(dir(fullfile(eulerMatDir,'E*.mat')));
    euler.plxfiles = struct2table(dir(fullfile(eulerPlxDir,'E*.plx')));

    eulerCellInfos = parseRawExcel(eulerSummaryFile, euler.matfiles);
    darwinCellInfos = parseRawExcel(darwinSummaryFile, darwin.matfiles);


end

function [cellInfos] = parseRawExcel(excelSummaryFile, matfiles)
    [~,~,rawCell] = xlsread(excelSummaryFile);
    taskFileContains = {'DET','MG','SEARCH','ZAP'};
    % find numbers
    containsNumbers = cellfun(@isnumeric,rawCell);
    %# convert to string
    rawCell(containsNumbers) = cellfun(@num2str,rawCell(containsNumbers),'UniformOutput',false);
    % Single unit quality metric
    % Not used...
    temp = rawCell(1:4,1); % top 4 rows
    qualityMetric = struct();
    for ii = 1:size(temp,1)
        raw = temp{ii};
        raw_ = split(regexprep(raw,'\s*=\s*','='),'=');
        qualityMetric(ii).raw = char(raw);
        qualityMetric(ii).val = str2double(raw_{1});
        qualityMetric(ii).comment = char(raw_{2});
        if isnan(qualityMetric(ii).val)
            % convert '< .5', was always 0.25
            qualityMetric(ii).val = 0.25;
        end
    end
    clearvars ii temp raw raw_;
    lastColumn = 23;
    colNames = rawCell(6,1:lastColumn);
    temp = rawCell(7:end,1:lastColumn);
    allNanRows = cell2mat(arrayfun(@(x) all(isnan([temp{x,:}])),(1:size(temp))','UniformOutput',false));
    temp(allNanRows,:)=[];
    sessionNames = regexp([temp{:,1}],'[A-Z]\d+','match')';
    expr = char(join(sessionNames,'|'));
    sessionNameRows = find(cell2mat(arrayfun(@(x) max([regexp(char(temp{x,1}),expr,'start'),0]) == 1,...
        (1:size(temp,1))','UniformOutput',false)));
    nSessions = numel(sessionNameRows);
    nRows = size(temp,1);
    cellInfos = [];
    for ii = 1:nSessions
        if ii < nSessions
            sessionRows = sessionNameRows(ii):sessionNameRows(ii+1)-1;
        else
            sessionRows = sessionNameRows(ii):nRows;
        end
        % Process session Information
        tempSession = cell2table(temp(sessionRows(1),1:2),'VariableNames',{'SessionName', 'SessionNotes'});
        tempTaskTrials = cell2table(temp(sessionRows(2:4),1:2),'VariableNames',{'TaskName', 'NTrials'});
        tempTaskTrials = cell2table(tempTaskTrials{:,2}','VariableNames',strcat('nTrials_',tempTaskTrials{:,1})');
    tempFiles = matfiles.name(~cellfun('isempty',regexp(matfiles.name,tempSession.SessionName,'match')));
    tempFolders = matfiles.folder(~cellfun('isempty',regexp(matfiles.name,tempSession.SessionName,'match')));

        tempTaskFiles = table();
        for t=1:numel(taskFileContains)
            task = taskFileContains{t};
            if contains(lower(task),'zap')
                idx = contains(lower(tempFiles),'zap');
            else
                idx = contains(tempFiles,task) & ~contains(lower(tempFiles),'zap');
            end
            if ~sum(idx)
                tempTaskFiles.([task '_matfile']){1} = [];
            else
                tempTaskFiles.([task '_matfile']){1} = tempFiles(idx);                
                tempFiles(idx) = [];
            end          
        end
        if isempty(tempFolders)
            tempTaskFiles.('Dir_matfile'){1} = [];
        else
           tempTaskFiles.('Dir_matfile'){1} = tempFolders(1);
        end

        % process Unit information
        tempUnitTable = cell2table(temp(sessionRows(2:end),3:end),'VariableNames',colNames(3:end));
        tempUnitTable(strcmpi(tempUnitTable.NeuronNumber,'NaN'),:) = [];
        tempUnitTable.Unit = regexprep(tempUnitTable.Unit,'^(\d[a-z])','0$1');
        tempUnitTable.UnitName = strcat('DSP',tempUnitTable.Unit);
        for c = 1:size(tempUnitTable,1)
            cellInfos = [cellInfos; [tempSession tempTaskFiles  tempTaskTrials tempUnitTable(c,:)]]; %#ok<AGROW>
        end
    end
end




