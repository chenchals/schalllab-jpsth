
% 4 jpsths figure
%| fastCorrect | accurateCorrect|
%|-------------|----------------|
%| inBoth(2,1) | inBoth(2,2)    |
%|-------------|----------------|
%| outBoth(1,1)| outBoth(1,2)   |
%|------------------------------|

% collect plots:

jpsths{1} = Z.TargetNotInXorY.FastCorrect('CueOn',:);
jpsths{2} = Z.TargetNotInXorY.AccurateCorrect('CueOn',:);
jpsths{3} =Z.TargetInXandY.FastCorrect('CueOn',:);
jpsths{4} = Z.TargetInXandY.AccurateCorrect('CueOn',:);
% axes w,h

% Plot on normalized axes
coinsXoffset = 1;
boxcarFilt = 5; 
% JPSTH position - compute other plot pos based on this position
jpsthPos{1} = [40 40 80 80];
jpsthPos{2} = [40 210 80 80];
jpsthPos{3} = [290 40 80 80];
jpsthPos{4} = [290 210 80 80];
% Coincidence Hist plots 
coinsPos = cellfun(@(x) [x(1)+coinsXoffset+x(3) x(2) x(3) x(4)],jpsthPos,'UniformOutput',false);
% XCell PSTH plots
psthHeight = 30;
xHist1Offset = 1;
% below jpsth
xPsthPos1 = cellfun(@(x) [x(1) x(2)-psthHeight-xHist1Offset x(3) psthHeight],jpsthPos,'UniformOutput',false);
% below coincidence hist
xPsthPos2 = cellfun(@(x) [x(1)+x(3)+coinsXoffset x(2)-psthHeight-xHist1Offset x(3) psthHeight],jpsthPos,'UniformOutput',false);

% use JPSTH pos to add other plots
delete(allchild(0))
figureName='JPSTH Analyses';

fontName = 'Arial';
fontSize = 8;
lineWidth = 0.1;
screenWH=get(0,'ScreenSize');%pixels
screenPixPerInch=get(0,'ScreenPixelsPerInch');%pixels
screenSize = [screenWH(3) screenWH(4)]./screenPixPerInch;
% figure in pixels
fW = 1600; 
fH = 1200;
figurePos = [20 20 fW fH];

set(0,'units','pixels')
set(0,'defaulttextfontsize',fontSize,...
    'defaultaxesfontsize',fontSize,...
    'defaulttextfontname',fontName,...
    'defaultaxeslinewidth',lineWidth)
%Main figure window
H_Figure=figure('Position',figurePos,...
    'PaperOrientation', 'Landscape',...
    'NumberTitle','off',...
    'Units','pixels',...
    'Menu','none',...
    'Name',figureName,...
    'Color',[1 1 1],...
    'Tag','Figure');

set(H_Figure,'Units','normalized');
figPos = get(H_Figure,'Position');

sW = 1000/fW;
sH = 1000/fH;
fx_getPos = @(p) [p(1)*sW p(2)*sH p(3)*sW p(4)*sH].*1/400;
grayCol = [0.6 0.6 0.6];

% JPSTHs
jpsthMinMax = cell2mat(cellfun(@(x) minmax(x.normalizedJpsth{1}(:)'),jpsths,'UniformOutput',false));
jpsthMinMax = minmax(jpsthMinMax(:)');
jpsthMinMax = round(jpsthMinMax.*10)./10;

% Coincidences
coinsMinMax = cell2mat(cellfun(@(x) minmax(x.coincidenceHist{1}(:,2))',jpsths,'UniformOutput',false));
coinsMinMax = minmax(coinsMinMax(:)');
coinsAbsMax = max(abs(coinsMinMax));
coinsYlim = [-coinsAbsMax coinsAbsMax].*1/sqrt(2);
coinsXlim = minmax(jpsths{1}.coincidenceHist{1}(:,1)');

% XCorrelations
crossMinMax = cell2mat(cellfun(@(x) minmax(x.xCorrHist{1}(:,2)'),jpsths,'UniformOutput',false));
crossMinMax = minmax(crossMinMax(:)');
crossAbsMax = max(abs(crossMinMax));
crossYlim = [-crossAbsMax crossAbsMax];
crossXlim = minmax(jpsths{1}.xCorrHist{1}(:,1)');

% XCell PSTH
xCellFrMax = cell2mat(cellfun(@(x) max(x.xPsth{1}),jpsths,'UniformOutput',false)');
% YCell PSTH
yCellFrMax = cell2mat(cellfun(@(x) max(x.yPsth{1}),jpsths,'UniformOutput',false)');
% All PSTH xlims
psthXlim = minmax(jpsths{1}.xPsthBins{1});

for ii = 1:4
    % jpsth
    pos = fx_getPos(jpsthPos{ii});
    H_jpsth(ii) = axes(H_Figure,'Position',pos,'Box','on');
    imagesc(flipud(jpsths{ii}.normalizedJpsth{1}),jpsthMinMax);
    set(H_jpsth(ii),'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);
    %axis square
    % coins
    pos = fx_getPos(jpsthPos{ii});
    H_coins(ii) = axes(H_Figure,'Position',pos,'Box','off');
    set(bar(jpsths{ii}.coincidenceHist{1}(:,1),smooth(jpsths{ii}.coincidenceHist{1}(:,2)),boxcarFilt),...
        'Facecolor',grayCol,'edgecolor','none');
    line(coinsXlim,[0 0],'color','k')
    set(H_coins(ii),'XLim',coinsXlim,'YLim',coinsYlim,'Box', 'off');
    %axis square
    axis off
    camzoom(sqrt(2));
    camorbit(-45,0);
    set(H_coins(ii),'Position', fx_getPos(coinsPos{ii}));
    % xcorr
    % xpsth1
    pos = fx_getPos(xPsthPos1{ii});
    H_xpsth1(ii) = axes(H_Figure,'Position',pos,'Box','on');

    set(bar(jpsths{ii}.xPsthBins{1},smooth(jpsths{ii}.xPsth{1}),boxcarFilt),...
        'Facecolor',grayCol,'edgecolor','none');
    set(H_xpsth1(ii),'YDir','Reverse');   
    % xpsth2
    pos = fx_getPos(xPsthPos2{ii});
    H_xpsth2(ii) = axes(H_Figure,'Position',pos,'Box','on');
    %axis square
    set(bar(jpsths{ii}.xPsthBins{1},smooth(jpsths{ii}.xPsth{1}),boxcarFilt),...
        'Facecolor',grayCol,'edgecolor','none');
    set(H_xpsth2(ii),'YDir','Reverse');
    
    drawnow

end















% for ii = 1:4
%     pos = fx_getPos(jpsthPos{ii});
%     H_jpsth(ii) = axes(H_Figure,'Position',pos,'Box','on');
%     imagesc(flipud(jpsths{ii}.normalizedJpsth{1}),jpsthMinMax);
%     set(H_jpsth(ii),'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);
%     axis square
% end
% 
% 
% for ii = 1:4
%     pos = fx_getPos(coinsPos{ii});
%     H_coins(ii) = axes(H_Figure,'Position',pos,'Box','off');
%     set(bar(jpsths{ii}.coincidenceHist{1}(:,1),smooth(jpsths{ii}.coincidenceHist{1}(:,2)),boxcarFilt),...
%         'Facecolor',[0.7 0.7 0.7],'edgecolor','none');
%     line(coinsXlim,[0 0],'color','k')
%     set(H_coins(ii),'XLim',coinsXlim,'YLim',coinsYlim,'Box', 'off');
%    axis off
%     camzoom(sqrt(2));
%    camorbit(-45,0)
% end
%     
    
    
    
    

%end