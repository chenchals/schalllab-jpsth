% Load the file names and locations
[~,txt,~] = xlsread('/Volumes/SchallLab/Users/Amir/0-chenchal/Expess Saccade Literature/Data/Express_Saccades3.xlsx','Fechner');
monkF = table();
monkF.location = cellfun(@(x) regexprep(x,'''',''),txt(2:end,1),'UniformOutput',false); % first column
monkF.filename = cellfun(@(x) regexprep(x,'''',''),txt(2:end,2),'UniformOutput',false); % second column
[~,txt,~] = xlsread('/Volumes/SchallLab/Users/Amir/0-chenchal/Expess Saccade Literature/Data/Express_Saccades3.xlsx','Hogi');
monkH = table();
tmp = cellfun(@(x) regexprep(x,'''',''),txt(2:end,1),'UniformOutput',false); % first column
monkH.location = cellfun(@(x)  regexprep(x,'Hogi','Hoagie'), tmp,'UniformOutput', false);
monkH.filename = cellfun(@(x) regexprep(x,'''',''),txt(2:end,2),'UniformOutput',false); % second column

drive = '/Volumes/SchallLab';% or X: or T:

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
            dataFile = load(f,'-mat');
            monkDat(i).file = f;
            monkDat(i).fileExists = true;
            targTime  = dataFile.Target_(:,1);
            saccTime = dataFile.Sacc_of_interest(:,1);
            monkDat(i).rt = saccTime - targTime;
            tmp = dataFile.GOCorrect(:);
            monkDat(i).GOCorrect = tmp(tmp>0);
            tmp = dataFile.NOGOWrong(:);
            monkDat(i).NOGOWrong = tmp(tmp>0);
        else
            monkDat(i).file = f;
            monkDat(i).fileExists = false;
            monkDat(i).rt =[];
            monkDat(i).GOCorrect =[];
            monkDat(i).NOGOWrong =[];
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

H_GOCorrectRts = vertcat(cell2mat(arrayfun(@(x) x.rt(x.GOCorrect), HogiExpress, 'UniformOutput', false)));
H_NOGOWrongRts = vertcat(cell2mat(arrayfun(@(x) x.rt(x.NOGOWrong), HogiExpress, 'UniformOutput', false)));
H_GO_NOGORts = [H_GOCorrectRts;H_NOGOWrongRts];

edges = -50:4:600;
[H_G,bins] = hist(H_GOCorrectRts,edges);
[H_NG] = hist(H_NOGOWrongRts,edges);
[H_G_NG] = hist(H_GO_NOGORts,edges);

F_GOCorrectRts = vertcat(cell2mat(arrayfun(@(x) x.rt(x.GOCorrect), FechnerExpress, 'UniformOutput', false)));
F_NOGOWrongRts = vertcat(cell2mat(arrayfun(@(x) x.rt(x.NOGOWrong), FechnerExpress, 'UniformOutput', false)));
F_GO_NOGORts = [F_GOCorrectRts;F_NOGOWrongRts];

[F_G,bins] = hist(F_GOCorrectRts,edges);
[F_NG] = hist(F_NOGOWrongRts,edges);
[F_G_NG] = hist(F_GO_NOGORts,edges);
figure
subplot(1,2,1)
plot(bins,[F_G;F_NG;F_G_NG])
legend({'GO' 'NOGO' 'GO+NOGO'})
title('Fechner')
xlabel('Saccade latency (ms)')
ylabel('Count')

subplot(1,2,2)
plot(bins,[H_G;H_NG;H_G_NG])
legend({'GO' 'NOGO' 'GO+NOGO'})
title('Hogi')
xlabel('Saccade latency (ms)')
ylabel('Count')

