function [ recentFile, searchResults ] = searchFile( searchDir, fullFilepath )
%FINDFILE Locate file in searchDir that is not in the specified
%fullFilepath 
%   Detailed explanation goes here
   [file2find.dir,file2find.file,file2find.ext] = fileparts(fullFilepath);
   
   searchFile = [file2find.file file2find.ext];
   filefind = @(d,f) ['find ' d ' -type f -name ' f];
   fprintf('Searching directory [%s/**] for file [%s]...\n', searchDir, searchFile); 
   [status,searchResults] = system(filefind(searchDir, searchFile));
   if status > 0 || isempty(searchResults) % file not found
      fprintf('*****File not found****\n\n');
      searchResults = [];
      recentFile = '';
      return
   end
   searchResults = strsplit(searchResults,'\n');
   searchResults = searchResults(~strcmpi(searchResults,''));
   searchResults = cell2mat(cellfun(@dir,searchResults,'UniformOutput', false));
   [~,si] = sort(vertcat(searchResults.datenum),'descend');
   searchResults = searchResults(si);  
   recentFile = fullfile(searchResults(1).folder,searchResults(1).name);
   fprintf('*****Found [%d] files. Recent file at [%s]****\n\n', numel(searchResults), recentFile);
  
end

