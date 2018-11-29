
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

% Plot scale relative
relW = 500; scaleW = 1/relW;
relH = 350; scaleH =1/relH;
jpsthPos{1} = [40 40 80 80];
jpsthPos{2} = [40 210 80 80];
jpsthPos{3} = [290 40 80 80];
jpsthPos{4} = [290 210 80 80];

% use JPSTH pos to add other plots
delete(allchild(0))
figureName='JPSTH Analyses';

fontName = 'Arial';
fontSize = 6;
lineWidth = 0.05;
screenWH=get(0,'ScreenSize');%pixels
margin = 40;
yaspect = screenWH(3)/screenWH(4);% for create a square plotbox
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
    'Tag','Figure');

set(H_Figure,'Units','Normalized');

% Plot JPSTHs
fx_getPos = @(p) [p(1)*scaleW p(2)*scaleH p(3)*scaleW p(4)*scaleH];
jpsthMinMax = cell2mat(cellfun(@(x) minmax(x.normalizedJpsth{1}(:)'),jpsths,'UniformOutput',false));
jpsthMinMax = minmax(jpsthMinMax(:)');
for ii = 1:4
    jpsthPos{ii} = fx_getPos(jpsthPos{ii});
    H_jpsth(ii) = axes(H_Figure,'Position',jpsthPos{ii},'Box','on');
    imagesc(flipud(jpsths{ii}.normalizedJpsth{1}));
    set(H_jpsth(ii),'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);
end

% plot Coincidences
coinsMinMax = cell2mat(cellfun(@(x) minmax(x.coincidenceHist{1}(:,2)'),jpsths,'UniformOutput',false));
coinsMinMax = minmax(coinsMinMax(:)');
coinsAbsMax = max(abs(coinsMinMax));
coinsYlim = [-coinsAbsMax coinsAbsMax];
coinsXlim = minmax(jpsths{1}.coincidenceHist{1}(:,1)');
for ii = 1:4
    pos = jpsthPos{ii} ;
    pos = [pos(1) + pos(3) pos(2) pos(3) pos(4)];
    H_coins(ii) = axes(H_Figure,'Position',pos,'Box','off');
    set(bar(jpsths{ii}.coincidenceHist{1}(:,1),jpsths{ii}.coincidenceHist{1}(:,2)),...
        'facecolor',[1.0 0.0 1.0],'edgecolor','none');
    set(H_coins(ii),'XLim',coinsXlim,'YLim',coinsYlim,'Box', 'off');
    set(H_coins(ii),'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);
     pbaspect([3 1 1])
     camzoom(sqrt(2));
     camorbit(-45,0)

end
    
    
    
    
    
    
    
    

%end