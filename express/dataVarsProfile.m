
% create a profile of data variables
datafile = 'expressSaccades.mat';

%% Fechner...
fprintf('Processing Fechner files...\n');
fechner = 'FechnerExpress';
data = load(datafile,fechner);
data = data.(fechner);
fechnerFileUID = vertcat(data.fileUID);
fechnerFileCount = numel(data);
fechnerFiles = arrayfun(@(x) getDatafile(data(x)),(1:fechnerFileCount)','UniformOutput',false);
fechnerFileVars = cellfun(@(x) sortrows(getVarnames(x)), fechnerFiles,'UniformOutput',false);
fechnerUniqWordCounts = getUniqWordCount(vertcat(fechnerFileVars{:}));
clearvars data
commonFechner = fechnerUniqWordCounts(cell2mat(fechnerUniqWordCounts(:,2))==fechnerFileCount,1);

%% Hoagie ...
fprintf('Processing Hogi files...\n');
hogi = 'HogiExpress';
data = load(datafile,hogi);
data = data.(hogi);
hogiFileUID = vertcat(data.fileUID);
hogiFileCount = numel(data);
hogiFiles = arrayfun(@(x) getDatafile(data(x)),(1:hogiFileCount)','UniformOutput',false);
hogiFileVars = cellfun(@(x) sortrows(getVarnames(x)), hogiFiles,'UniformOutput',false);
hogiUniqWordCounts = getUniqWordCount(vertcat(hogiFileVars{:}));
clearvars data
commonHogi = hogiUniqWordCounts(cell2mat(hogiUniqWordCounts(:,2))==hogiFileCount,1);

%% Combined ...
allFilesCount = fechnerFileCount + hogiFileCount;
combinedWords = [vertcat(fechnerFileVars{:});vertcat(hogiFileVars{:})];
combinedWordCounts = getUniqWordCount([vertcat(fechnerFileVars{:});vertcat(hogiFileVars{:})]);
commonCombined = combinedWordCounts(cell2mat(combinedWordCounts(:,2))==allFilesCount,1);


%% process for each file for Fechner
FechnerExpressDataVariables(fechnerFileCount,1) = struct();
for i = 1:fechnerFileCount
    %disp(i)
    FechnerExpressDataVariables(i).fileUID = fechnerFileUID(i,:);
    FechnerExpressDataVariables(i).file = fechnerFiles{i};
    FechnerExpressDataVariables(i).commonVarsFechner = commonFechner;
    FechnerExpressDataVariables(i).commonVarsFechnerHogi = commonCombined;
    FechnerExpressDataVariables(i).otherVars = setdiff(fechnerFileVars{i},commonFechner);
end

%% process for each file for Hogi
HogiExpressDataVariables(hogiFileCount,1) = struct();
for i = 166:hogiFileCount
    %disp(i)
    HogiExpressDataVariables(i).fileUID = hogiFileUID(i,:);
    HogiExpressDataVariables(i).file = hogiFiles{i};
    HogiExpressDataVariables(i).commonVarsHogi = commonHogi;
    HogiExpressDataVariables(i).commonVarsFechnerHogi = commonCombined;
    HogiExpressDataVariables(i).otherVars = setdiff(hogiFileVars{i},commonHogi);
end

save('expressSaccadesVariableProfile.mat','FechnerExpressDataVariables','HogiExpressDataVariables');

%% sub-functions

function [out] = getUniqWordCount(inCellStr)
    % see: https://www.mathworks.com/matlabcentral/answers/230619-count-word-frequency-please-help
    % build array of unique words and get counts.
    [words_u, ~, idxU] = unique( inCellStr ) ;
    counts = accumarray( idxU, 1 ) ;
    % - Sort entries by count.
    [~, idxS] = sort( counts, 'descend' ) ;
    words_us = words_u(idxS) ;
    counts_s = counts(idxS) ;
    % - Build cell array of unique words and counts.
    out = [words_us, num2cell( counts_s )] ;
end

function [out] = getVarnames(filename)
    out = who('-file',filename);
    out(~cellfun(@isempty, regexpi(out,'^(Unit|AD|DSP|Spike)','match')))='';
end

function [out] = getDatafile(inVar)
   if inVar.fileExists
       out = inVar.file;
   else
       out = inVar.relocFile;
   end
end