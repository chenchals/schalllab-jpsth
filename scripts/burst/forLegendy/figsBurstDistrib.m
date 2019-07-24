% load burst distribution
figureDir = 'burstDistributions';
burstDistribFile = 'burstDistributions/cellBurstDistributions.mat';
%figureDir = '/Volumes/schalllab/Users/Chenchal/Legendy/BurstFigures/burstDistributions';
%burstDistribFile = '/Volumes/schalllab/Users/Chenchal/Legendy/BurstFigures/burstDistributions/cellBurstDistributions.mat';
load(burstDistribFile);
axesH = createFigureTemplate();
nPlots = numel(axesH);
nextPlot = 1;
nCells = size(burstDistrib.distributionTbl,1);
for pp = 1:nCells
    uid = regexprep(burstDistrib.distributionTbl.Properties.RowNames{pp},'\.mat','');
    d = cell2mat(burstDistrib.distributionTbl{pp,:}')';
    nBursts = sum(d,1)';
    if nextPlot == 1
        fromCell = pp;
    end
    %cla(axesH(nextPlot));
    axes(axesH(nextPlot));
    bar(burstDistrib.si,d,'BarWidth',10);
    legs = strcat(burstDistrib.distributionTbl.Properties.VariableNames',...
        ' [',arrayfun(@num2str,nBursts,'UniformOutput',false),']');    
    legend(legs,'Interpreter','none')
    xlabel('Surprise Index (-log(Significance))')
    ylabel(strcat(uid,' [#bursts]'),'FontWeight','bold','Interpreter','None')

    drawnow
    if mod(pp,nPlots) == 0
        toCell = pp;
        fn = ['UID_' num2str(fromCell,'%04d_to_') num2str(toCell,'%04d')];
        saveFigAs(fullfile(figureDir,fn));
        nextPlot = 0;
        arrayfun(@cla,axesH);
    end
    if pp < nCells
       nextPlot = nextPlot + 1;
    else
       toCell = pp;
        fn = ['UID_' num2str(fromCell,'%04d_to_') num2str(toCell,'%04d')];
        saveFigAs(fullfile(figureDir,fn));
    end
end

function saveFigAs(fn)
    % currUnits = get(gcf,'Units');
    % currPosition = get(gcf,'Position');
    set(gcf,'Units','inches');
    screenposition = get(gcf,'Position');
    set(gcf,...
        'PaperPosition',[0 0 screenposition(3:4)],...
        'PaperSize',[screenposition(3:4)]);
    fprintf('Saving figure to: %s\n',fn); 
    print(fn,'-dpdf','-painters')
    drawnow
end

function [H_Plots] = createFigureTemplate()
    %create figure template
    delete(allchild(0))
    figureName='Burst Analyses';

    fontName = 'Arial';
    fontSize = 6;
    lineWidth = 0.05;
    screenWH=get(0,'ScreenSize');%pixels
    margin = 40;
    figureWidth = screenWH(3)-2*margin;
    figureHeight = screenWH(4)-2*margin;
    figurePos = [margin margin figureWidth figureHeight];

    set(0,'units','pixels')
    set(0,'defaulttextfontsize',fontSize,...
        'defaultaxesfontsize',fontSize,...
        'defaulttextfontname',fontName,...
        'defaultaxeslinewidth',lineWidth)

    %Main figure window
    H_Figure=figure('Position',figurePos,...
        'PaperOrientation', 'Landscape',...
        'NumberTitle','off',...
        'Menu','none',...
        'Units','normalized',...
        'Name',figureName,...
        'Color',[1 1 1],...
        'Tag','H_Figure');
    % OutlinePos=[0.005 0.005 0.99 0.99];
    % H_Outline=axes('parent',H_Figure,...
    %                'position',OutlinePos,...
    %                'box','on',...
    %                'xtick',[],...
    %                'ytick',[],...
    %                'xcolor',[0 0 0],...
    %                'ycolor',[0 0 0],...
    %                'Tag','H_Outline');

    xGutter = 0.02;
    yGutter = 0.04;
    nCols = 4;
    plotW = (1/nCols) - 1.5 * xGutter;
    nRows = 2;
    plotH = (1/nRows) - 1.5 * yGutter;
    plotX = ((0:nCols-1).*(1/nCols)) + xGutter;
    plotX = repmat(plotX,nRows,1);
    plotY = ((0:nRows-1).*(1/nRows)) + yGutter;
    plotY = repmat(plotY(:),1,nCols);

    H1 = arrayfun(@(x) axes('Parent',H_Figure,...
        'Position',[plotX(2,x) plotY(2,x) plotW plotH],...
        'Box','on',...
        'Tag',['H_' num2str(x)]),...
        (1:4),'UniformOutput',false);
    H2 = arrayfun(@(x) axes('Parent',H_Figure,...
        'Position',[plotX(1,x) plotY(1,x) plotW plotH],...
        'Box','on',...
        'Tag',['H_' num2str(x+4)]),...
        (1:4),'UniformOutput',false);
    H_Plots = [H1{:} H2{:}];

end