

% create a profile of data variables
datafile = 'expressSaccadesMissingFilesIncluded.mat';
var2load = 'HogiExpress';

data = load(datafile,var2load);

data = data.(var2load);

for i=1:numel(data)
    data(i).fileUID=num2str(i,'UID_%04d');
end

% % eval([var2load '=data;'])
% % save(datafile,'-append', var2load)
