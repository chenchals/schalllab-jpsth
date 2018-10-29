function [outputArg1,outputArg2] = SATDefinitions(inputArg1,inputArg2)
%SATDEFINITIONS Summary of this function goes here
%   Detailed explanation goes here

%% Target_ variable as Table:
Target_Table = table();

% From teba/Users/Rich/Mat_Code/Import/EventTranslator.m Lines:123-186
%  Comment for each column Index is used as column names for that column
% 
colNames = [];
colDesc = [];
% Column #1
colDesc = [colDesc; 'Target align time'];
colNames =  [colNames;'TargetAlignTime'];      
% Column #2
colDesc = [colDesc; 'Target location (255 = catch trial)'];
colNames =  [colNames;'TargetLocation_255_IsCatchTrial'];      
% Column #3
colDesc = [colDesc; 'TARGET COLOR'];
colNames =  [colNames;'TargetColor'];  
% Column #4
colDesc = [colDesc; 'Min Target Color (CLUT value; higher values = BRIGHTER [more white])'];
colNames =  [colNames;'MinTargetColorCLUT_HighIsBright'];  
% Column #5
colDesc = [colDesc; 'Set Size'];
colNames =  [colNames;'SetSize'];  
% Column #6
colDesc = [colDesc; 'SET SIZE CONDITION (0 = 2; 1 = 4; 2 = 8; 3 = random)'];
colNames =  [colNames;'SetSizeCondition'];  
% Column #7
%         % Easy hard  Target type
%         %must index to LAST '3007' to find correct value.  I do not
%         %understand this coding scheme...
%         if ~isempty(find(TrialStrobeValues(1:relevant) == 3007,1))
%             %Target_(newindex,7) = TrialStrobeValues(find(TrialStrobeValues(1:relevant) == 3007,1,'last') - 1);
%             %Target_(newindex,8) = TrialStrobeValues(find(TrialStrobeValues(1:relevant) == 3007,1,'last') + 1);
%         end
% 
colDesc = [colDesc; 'Easy hard  Target type; must index to LAST ''3007'' to find correct value.  I(RH) do notunderstand this coding scheme...'];
colNames =  [colNames;'EasyHardTargetType']; 
% Column #8
colDesc = [colDesc; 'Task Type  (0 = fixation; 1 = detection; 2 = search/MG??'];
colNames =  [colNames;'TaskType']; 

        %Hold Time (use to determine search or memory guided)
        if ~isempty(find(TrialStrobeValues(1:relevant) == 3021,1))
            Target_(newindex,10) = TrialStrobeValues(find(TrialStrobeValues(1:relevant) == 3021,1) + 1);
        end
        %
        %Homogeneous (0)/Non-homogeneous (1)
        if ~isempty(find(TrialStrobeValues(1:relevant) == 3032,1))
            Target_(newindex,11) = TrialStrobeValues(find(TrialStrobeValues(1:relevant) == 3032,1) + 1);
        end

        %Eccentricity
        if ~isempty(find(TrialStrobeValues(1:relevant) == 3001,1))
            Target_(newindex,12) = TrialStrobeValues(find(TrialStrobeValues(1:relevant) == 3001,1) + 1);
        end

end


%% Error_ variable as Table
% Error_Table = table();
% From teba/Users/Rich/Mat_Code/Import/EventTranslator.m Lines:87-95
%  Comment for each column Index is used as column names for that column
        %find Error Codes
        %Types of Errors
        %Column:
        %1 = CatchError
        %2 = HoldError
        %3 = Latency Error
        %4 = Target Hold Error
        %5 = Saccade Direction Error
        %

