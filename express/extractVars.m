%% Vars used to load data for Express saccades
% Load the file names and locations
drive = '/Volumes/SchallLab';% or X: or T:

[~,txt,~] = xlsread('/Volumes/SchallLab/Users/Amir/0-chenchal/Expess Saccade Literature/Data/Express_Saccades3.xlsx','Fechner');
monkF = table();
monkF.location = cellfun(@(x) regexprep(x,'''',''),txt(2:end,1),'UniformOutput',false); % first column
monkF.filename = cellfun(@(x) regexprep(x,'''',''),txt(2:end,2),'UniformOutput',false); % second column

[~,txt,~] = xlsread('/Volumes/SchallLab/Users/Amir/0-chenchal/Expess Saccade Literature/Data/Express_Saccades3.xlsx','Hogi');
monkH = table();
tmp = cellfun(@(x) regexprep(x,'''',''),txt(2:end,1),'UniformOutput',false); % first column
monkH.location = cellfun(@(x)  regexprep(x,'Hogi','Hoagie'), tmp,'UniformOutput', false);
monkH.filename = cellfun(@(x) regexprep(x,'''',''),txt(2:end,2),'UniformOutput',false); % second column

%% The following variables need to be present int he extracted file(s) for Fechner/Hogi
vars = vars2load();

%% Compute RT
for j = 1:2
    if j==1
        currMonk = monkH;
    else
        currMonk = monkF;
    end
    monkDat(size(currMonk,1),1) = struct();
    % for each row in the table:
    parfor i = 1:size(currMonk,1)
        loc = currMonk.location{i};
        loc = regexprep(regexprep(loc,'^[A-Z]\:', drive),'\',filesep);
        f = fullfile(loc,currMonk.filename{i});
        fprintf('Loading file : %s\n',f);
        if exist(f,'file')
            dataVars = load(f,'-mat',vars{:});
            monkDat(i).file = f;
            monkDat(i).fileExists = true;
            targTime  = dataVars.Target_(:,1);
            saccTime = dataVars.Sacc_of_interest(:,1);
            monkDat(i).rt = saccTime - targTime;           
            for v = 1:numel(vars)
                varName = vars{v};
                monkDat(i).(varName) = loadVariable(dataVars,varName);
            end
        else
            monkDat(i).file = f;
            monkDat(i).fileExists = false;
            monkDat(i).rt =[];
            for v = 1:numel(vars)
                varName = vars{v};
                monkDat(i).(varName) = [];
            end
        end
    end
    
    if j==1
        HogiExpress = monkDat;
        clearvars monkDat
    else
        FechnerExpress = monkDat;
        clearvars monkDat
    end
end

%% Load variable for output
function [ out ] = loadVariable(varStruct,varName)
    if ~isfield(varStruct, varName)
        out = [];
        return
    end
    out = varStruct.(varName);
    if contains(varName,'GO') || contains(varName, 'NOGO') % no '0' trial no
        out = out(:);
        out = out(out>0);
    end
end

%%
function [ out ] = vars2load()
 out = {   
%     'Header_'
%     'Abort_'
    'Correct_'
%     'Decide_'
    'Eot_'
%     'ExtraJuice_'
    'FixSpotOn_'
    'FixSpotOff_'
    'FixWindow_'
    'Fixate_'
    'Infos_'
    'Target_'
    'Reward_'
    'Saccade_'
    'Stimulus_'
    'StopSignal_'
%     'TargetWindow_'
    'TrialStart_'
    'TrialType_'
%     'Unit_'
    'Wrong_'
%     'MouthBegin_'
%     'MouthEnd_'
%     'Stim_'
%     'AD01'
%    'EyeX_'
%    'EyeY_'
    'EmStart_'
%     'DSP01i'
%     'DSP01a'
%     'DSP01b'
    'SaccBegin'
    'SaccEnd'
    'SaccDir'
    'SaccAmp'
    'GOValid'
    'GOCorrect'
    'GOWrong'
%     'ZAPGOCorrect'
    'NOGOValid'
    'NOGOCorrect'
    'NOGOWrong'
%     'ZAPNOGOCorrect'
%     'ZAPNOGOWrong'
%     'ZAPNOGOLate'
%     'ZAPNOGOEarly'
%     'ZAPGOLate'
    'NOGOEarly'
    'NOGOShort'
    'Excluded_GOCorrect'
    'Excluded_NOGOWrong'
    'Sacc_of_interest'
    'AllTrues'
    'SecondSacc'
    'SecReinforcer'
    'Inh'
    'Params'
    'SSRT'
    };

end


