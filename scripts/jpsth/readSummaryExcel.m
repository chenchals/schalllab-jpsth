summaryFileDir = '/mnt/teba/Users/Chenchal/JPSTH/';
darwinSummaryFile = fullfile(summaryFileDir,'Darwin_SAT_colorRecode.xlsx');
eulerSummaryFile = fullfile(summaryFileDir,'Euler_SAT_colorRecode.xlsx');

[~,~,rawD] = xlsread(darwinSummaryFile);

[~,~,rawE] = xlsread(eulerSummaryFile);

% Single unit quality metric
temp = rawD(1:4,1); % top 4 rows
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




