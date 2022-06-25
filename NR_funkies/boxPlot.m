
function [xCoors,ax,labels,colors] = boxPlot(inputData,inputLabels,NameValueArgs)

arguments
    
    inputData double
    inputLabels double
    NameValueArgs.perGrp (1,1) {mustBeNumeric} = 1
    NameValueArgs.oneLabGrp = false
    NameValueArgs.labels (1,:) {mustBeA(NameValueArgs.labels,'cell'),mustBeText} = {}
    NameValueArgs.colors (1,:) {mustBeA(NameValueArgs.colors,'cell')} = {}

end

%%%% check for vector or matrix input data
labels = NameValueArgs.labels;
colors = NameValueArgs.colors;

if isempty(inputLabels)
    
    inputLabels = repmat(inputData,1,1);    % replicate inputData mat to get the size of each observation
    
    for colIdx=1:size(inputLabels,2)
        inputLabels(:,colIdx) = colIdx;     % reassign proper label based on column index.
    end
    
    inputLabels = reshape(inputLabels,[],1);% reshape inputLabels into a single column vector.
    inputData = reshape(inputData,[],1);    % reshape inputData into a single column vector.

end

if isempty(labels)
    labels = cellstr(string(1:numel(unique(inputLabels))));
end
if isempty(colors)
   colors = repmat({[0.65,0.65,0.65]},[1,numel(unique(inputLabels))]); 
end
    

nCats = numel(unique(inputLabels)); % get number of categories to plot based on labels in input
catLabels = sort(unique(inputLabels),'ascend')';

%%%% assign name-value arguments

if isempty(inputLabels)
    
    
else



end
nGroups = numel(unique(inputLabels))/NameValueArgs.perGrp;

% check labels against oneLabGrp
if NameValueArgs.oneLabGrp == true && numel(labels) > nGroups
    error('Too many labels for number of groups, did you mean to specify oneLabGrp = true?');
elseif NameValueArgs.oneLabGrp == true && numel(labels) < nGroups
    error('Too few labels for number of groups, did you mean to specify oneLabGrp = true?');
end

%%%% set colors based on input
% if you want the same color and label for all members of each group, give labels/colors for each group with empty between them
% e.g. {'grp1','','grp2'},{[1,0,0],[],[0,0,1]} will make group 1 all red and group 2 all blue
if NameValueArgs.perGrp ~= 1 && (numel(labels) == nGroups + (nGroups-1) || numel(labels) == nGroups*2) && (numel(colors) == nGroups + (nGroups-1) || numel(colors) == nGroups*2) && ...
        any(ismember(labels,{''})) && any(cellfun(@isempty,colors)) && NameValueArgs.oneLabGrp == false
    
    repLabels = [];
    repColors = [];
    for lab = find(~ismember(labels,{''}))
        repLabels = horzcat(repLabels,repmat(labels(lab),[1,NameValueArgs.perGrp]));
        repColors = horzcat(repColors,repmat(colors(lab),[1,NameValueArgs.perGrp]));
    end
    labels = repLabels;
    colors = repColors;
   
% full labels, repeat colors as above
elseif NameValueArgs.perGrp ~= 1 && numel(labels) == nCats && (numel(colors) == nGroups + (nGroups-1) || numel(colors) == nGroups*2) && ...
        any(cellfun(@isempty,colors)) && NameValueArgs.oneLabGrp == false
    
    repColors = [];
    for lab = find(cellfun(@isempty,colors) == 0)
        repColors = horzcat(repColors,repmat(colors(lab),[1,NameValueArgs.perGrp]));
    end
    colors = repColors;
    
% same set of labels for each group, one color for each group
elseif NameValueArgs.perGrp ~= 1 && numel(labels) == NameValueArgs.perGrp && (numel(colors) == nGroups + (nGroups-1) || numel(colors) == nGroups*2) && ~any(ismember(labels,{''})) && any(cellfun(@isempty,colors)) && ...
        NameValueArgs.oneLabGrp == false

    repLabels = [];
    repColors = [];
    
    repNum = nGroups;
    repLabels = horzcat(repLabels,repmat(labels,[1,repNum]));
    for lab = find(cellfun(@isempty,colors) == 0)
        repColors = horzcat(repColors,repmat(colors(lab),[1,NameValueArgs.perGrp]));
    end
    labels = repLabels;
    colors = repColors;
    
% same set of labels for each group, colors for each category
elseif NameValueArgs.perGrp ~= 1 && numel(labels) == NameValueArgs.perGrp && numel(colors) == nCats && ~any(ismember(labels,{''})) && ~any(cellfun(@isempty,colors)) && ...
        NameValueArgs.oneLabGrp == false

    repLabels = [];
    
    repNum = nGroups;
    repLabels = horzcat(repLabels,repmat(labels,[1,repNum]));
    labels = repLabels;
    
% same label for each group, colors for each category
elseif NameValueArgs.perGrp ~= 1 && (numel(labels) == nGroups + (nGroups-1) || numel(labels) == nGroups*2) && numel(colors) == nCats && any(ismember(labels,{''})) && ~any(cellfun(@isempty,colors)) && ...
        NameValueArgs.oneLabGrp == false

    repLabels = [];
    for lab = find(~ismember(labels,{''}))
        repLabels = horzcat(repLabels,repmat(labels(lab),[1,NameValueArgs.perGrp]));
    end
    labels = repLabels;

% if you want the same color for all members of each group and one label per group, give one label for each group and colors for each group with empty between them
% e.g. {'grp1','grp2'},{[1,0,0],[],[0,0,1]} will make group 1 all red and group 2 all blue
elseif NameValueArgs.perGrp ~= 1 && numel(labels) == nGroups && (numel(colors) == nGroups + (nGroups-1) || numel(colors) == nGroups*2) && ...
        ~any(ismember(labels,{''})) && any(cellfun(@isempty,colors)) && NameValueArgs.oneLabGrp == true

    repColors = [];
    for lab = find(cellfun(@isempty,colors) == 0)
        repColors = horzcat(repColors,repmat(colors(lab),[1,NameValueArgs.perGrp]));
    end
    colors = repColors;
    
% if you want the same set of labels and colors and for each group, give labels/colors for all groups with no empty string between them
% e.g. {'grp1','grp2'},{[1,0,0],[0,0,1]} will make group 1 red and blue, and group 2 red and blue
elseif NameValueArgs.perGrp ~= 1 && numel(labels) == NameValueArgs.perGrp && numel(colors) == NameValueArgs.perGrp && ~any(ismember(labels,{''})) && ~any(cellfun(@isempty,colors)) && ...
        NameValueArgs.oneLabGrp == false
    
    repLabels = [];
    repColors = [];
    
    repNum = nGroups;
    repLabels = horzcat(repLabels,repmat(labels,[1,repNum]));
    repColors = horzcat(repColors,repmat(colors,[1,repNum]));

    labels = repLabels;
    colors = repColors;
    
% if you want the same set of colors for each group, but one label for each group, give one label for each group with colors for each category
% e.g. {'grp1','grp2'},{[1,0,0],[0,0,1]} will make group 1 red and blue, and group 2 red and blue
elseif NameValueArgs.perGrp ~= 1 && numel(labels) == nGroups && numel(colors) == NameValueArgs.perGrp && ~any(ismember(labels,{''})) && ~any(cellfun(@isempty,colors)) && ...
        NameValueArgs.oneLabGrp == true

    repColors = [];
    
    repNum = nGroups;
    repColors = horzcat(repColors,repmat(colors,[1,repNum]));

    colors = repColors;
    
elseif NameValueArgs.perGrp ~= 1 && numel(labels) == nCats && numel(colors) == NameValueArgs.perGrp && ~any(ismember(labels,{''})) && ~any(cellfun(@isempty,colors)) && ...
        NameValueArgs.oneLabGrp == false

    repColors = [];
    
    repNum = nGroups;
    repColors = horzcat(repColors,repmat(colors,[1,repNum]));

    colors = repColors;
    
elseif NameValueArgs.perGrp ~= 1 && numel(labels) == nGroups && numel(colors) == NameValueArgs.perGrp && ~any(ismember(labels,{''})) && ~any(cellfun(@isempty,colors)) && ...
        NameValueArgs.oneLabGrp == false
    
    error('Insufficient number of labels, did you mean to specify oneLabGrp = true?');
    
elseif NameValueArgs.perGrp ~= 1 && numel(labels) == nGroups && (numel(colors) == nGroups + (nGroups-1) || numel(colors) == nGroups*2) && ...
    ~any(ismember(labels,{''})) && any(cellfun(@isempty,colors)) && NameValueArgs.oneLabGrp == false

    error('Insufficient number of labels, did you mean to specify oneLabGrp = true?');
    
elseif NameValueArgs.perGrp ~= 1 && (numel(labels) == nGroups + (nGroups-1) || numel(labels) == nGroups*2) && (numel(colors) == nGroups + (nGroups-1) || numel(colors) == nGroups*2) && ...
        any(ismember(labels,{''})) && any(cellfun(@isempty,colors)) && NameValueArgs.oneLabGrp == true

    error('Labels contain empty string, did you mean to specify oneLabGrp = true?');
    
end

% throw error if data can't be grouped properly
if rem(nGroups,1) ~= 0
    error('Number of input categories is not divisible by number of groups.');
end

if nGroups == 1

    % get x-coordinates for plotting
    xCoors = [0.70:0.65:0.7+(0.65*nCats)-0.65];
    nGroups = 1;
   
else
        
    % throw error if data can't be grouped properly
    if rem(nCats,nGroups) ~= 0
        error('Number of input categories is not divisible by number of groups.');
    end

    % generate x coordinates to plot n groups
    xCoors = [];
    initCoors = [0.70:0.55:0.70+(0.55*(nCats/nGroups)-0.55)];
    for grp = 1:nGroups
        if isempty(xCoors)
            xCoors = initCoors;
        else
            xCoors = horzcat(xCoors,initCoors+(xCoors(end)+0.4));
        end
    end
        
end

if numel(labels) < nCats && rem(numel(labels),nGroups) ~= 0
    error('Labels cannot be properly distributed to groups.');
elseif numel(labels) == nCats
    groupLabels = 0;
else
    groupLabels = 1;
end

%%%% intialize matrices for storing max/min to set axes
maxMat = zeros(nCats,3); % uQuar, uWhisk, outliersU
minMat = zeros(nCats,3); % lQuar, lWhisk, outliersL

%%%% plot data
for cat = catLabels

    catNum = find(catLabels == cat);
    
    clear lQuar uQuar med lWhisk uWhisk outliersU outliersL

    %%%% get data for current category
    currData = inputData(inputLabels==cat,1);
    
    if nnz(~isnan(currData)) > 4
        
        % get median of categories
        med = median(currData,1,'omitnan');
        % get 75 percentile of categories
        uQuar = prctile(currData,75,1);
        % get 25 percentile of categories
        lQuar = prctile(currData,25,1);
        % get 97.5 percentile of categories
        maxWhisk = uQuar + 1.5*(uQuar-lQuar);
        uWhisk = max(currData(currData < maxWhisk & currData >= uQuar));
        % get 2.5 percentile of categories
        minWhisk = lQuar - 1.5*(uQuar-lQuar);
        lWhisk = min(currData(currData > minWhisk & currData <= lQuar));

        if isempty(lWhisk)
            lWhisk = minWhisk;
        end

        if isempty(uWhisk)
            uWhisk = maxWhisk;
        end

        % plot box with bounds at quartiles
        rectangle('Position',[xCoors(catNum)-0.25 lQuar 0.5 (uQuar-lQuar)],'FaceColor',colors{catNum},'EdgeColor','k','LineWidth',1,'Tag','box')
        % plot left half median line
        line([xCoors(catNum)-0.25 xCoors(catNum)],[med med],'Color','k','LineWidth',2)
        % plot right half median line
        line([xCoors(catNum) xCoors(catNum)+0.25],[med med],'Color','k','LineWidth',2)
        % plot lower whisker
        line([xCoors(catNum) xCoors(catNum)],[lQuar lWhisk],'Color','k','LineWidth',0.75)
        % plot upper whisker
        line([xCoors(catNum) xCoors(catNum)],[uQuar uWhisk],'Color','k','LineWidth',0.75,'Tag','uwhisk')
        % plot lower whisker bar
        line([xCoors(catNum)-0.1 xCoors(catNum)+0.1],[lWhisk lWhisk],'Color','k','LineWidth',0.5)
        % plot upper whisker bar
        line([xCoors(catNum)-0.1 xCoors(catNum)+0.1],[uWhisk uWhisk],'Color','k','LineWidth',0.5)
        hold on
        %%%% plot outliers
        if any(currData > uWhisk)
            scatter(xCoors(catNum),currData(currData > uWhisk),40,'filled','MarkerFaceColor',colors{catNum},'MarkerEdgeColor',colors{catNum});
            hold on
            outliersU = currData(currData > uWhisk);
        else
            outliersU = nan;
        end
        if any(currData < lWhisk)
            scatter(xCoors(catNum),currData(currData < lWhisk),40,'filled','MarkerFaceColor',colors{catNum},'MarkerEdgeColor',colors{catNum});
            hold on
            outliersL = currData(currData < lWhisk);
        else
            outliersL = nan;
        end

        %%%% store min/max from each category for setting limits
        maxMat(catNum,:) = [uQuar,uWhisk,max(outliersU)];
        minMat(catNum,:) = [lQuar,lWhisk,min(outliersL)];
        
    elseif nnz(~isnan(currData)) == 0
        
        %%%% store min/max from each category for setting limits
        maxMat(catNum,:) = [repmat(max(currData),[1,3])];
        minMat(catNum,:) = [repmat(min(currData),[1,3])];
    
    elseif nnz(~isnan(currData)) <= 4
    
        % get median of categories
        med = median(currData,1,'omitnan');

        % plot left half median line
        line([xCoors(catNum)-0.25 xCoors(catNum)],[med med],'Color','k','LineWidth',2)
        % plot right half median line
        line([xCoors(catNum) xCoors(catNum)+0.25],[med med],'Color','k','LineWidth',2)
        hold on
        scatter(xCoors(catNum),currData,40,'filled','MarkerFaceColor',colors{catNum},'MarkerEdgeColor',colors{catNum});
        hold on

        %%%% store min/max from each category for setting limits
        maxMat(catNum,:) = [repmat(max(currData),[1,3])];
        minMat(catNum,:) = [repmat(min(currData),[1,3])];
        
    end
    
end

xlim([0.2 xCoors(end)+0.5]);

xLabPos = [];
switch groupLabels

    case 1
        
        for group = 1:(nCats/nGroups):nCats

            xLabPos = horzcat(xLabPos,median(xCoors(group:group+(nCats/nGroups)-1)));

        end

        set(gca, 'xtick', xLabPos);
        set(gca, 'xticklabel', labels);
        
    otherwise
        
        set(gca, 'xtick', xCoors);
        set(gca, 'xticklabel', labels);
        
end

set(gca,'FontSize',15);
set(gca, 'XColor', 'k', 'YColor', 'k');
set(gca, 'TickDir', 'out', 'TickLength', [0.01, 0.01]);
set(gca,'box','off');
set(gcf,'color','w');
set(gca,'LineWidth',1);
ax = get(gca);

if ~all(isnan(maxMat),'all')

    % set y limits
    yUpper = max(maxMat,[],'all');
    yLower = min(minMat,[],'all');
    yExt = (yUpper-yLower)*0.2;
    ylim([yLower-yExt yUpper+yExt]);

end

end
