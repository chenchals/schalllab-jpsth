% load burst distribution
burstDistribFile = '/Volumes/schalllab/Users/Chenchal/Legendy/BurstFigures/cellBurstDistributions.mat';
load(burstDistribFile);

for pp = 1:size(burstDistrib.distributionTbl,1)
    d = cell2mat(burstDistrib.distributionTbl{pp,:}')';
    nBursts = sum(d,1)';
     bar(burstDistrib.si,d,'BarWidth',10);
    legs = strcat(burstDistrib.distributionTbl.Properties.VariableNames',...
        ' [',arrayfun(@num2str,nBursts,'UniformOutput',false),']');    
    legend(legs,'Interpreter','none')
    xlabel('Surprise Index (-log(Significance))')
    ylabel('Number of bursts')
    title(burstDistrib.distributionTbl.Properties.RowNames{pp},'Interpreter','none');
    pause
end
