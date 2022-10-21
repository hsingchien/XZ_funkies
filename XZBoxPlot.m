function  f = XZBoxPlot(inputdata, color_group, plotorder, xlegend, color_palette, a2, dotline)
% inputdata, cell, each entry is a group of data nx1
% color_group specify the color group idx for each column
% plotorder order of boxes, should be the 1xncolumns vector
% xlengend, 1xncolumns cell containing x label strings
% color_palette 1xcolor_groups, can leave empty
% a2 target ax

% make sure all entries in InputData are nx1
inputdata_copy = {};
for i = 1:length(inputdata)
    if ~isempty(inputdata{i})
        inputdata_copy = [inputdata_copy, num2cell(inputdata{i},1)];
    else
        inputdata_copy = [inputdata_copy, [nan]];
    end
end
% reorder inputdata_copy according to plotorder
if exist('plotorder','var') & ~isempty(plotorder)
    [~,idx] = sort(plotorder);
else
    plotorder = 1:numel(inputdata_copy);
    idx = 1:length(inputdata_copy);
end
if ~exist('dotline','var')
    dotline = 'none';
end


color_group_ori = color_group;
inputdata_copy = inputdata_copy(idx);
if ~isempty(color_group)
    color_group = color_group(idx);
else
    color_group = 1:length(inputdata_copy);
    color_group_ori = color_group;
end

if exist('maxdistcolor') & ~exist('color_palette','var')
    color_palette = maxdistcolor(length(unique(color_group)), @sRGB_to_CIELab);
elseif ~exist('maxdistcolor')
    error('add maxdistcolor to the path');
end


allData = cat(1, inputdata_copy{:});
color_group_copy = [];
allGroup = {};
for i = 1:length(inputdata_copy)
    allGroup{i} = zeros(length(inputdata_copy{i}),1) + i;
    color_group_copy = [color_group_copy; color_group(i)*ones(size(allGroup{i},1),1)];
end
allGroup = cat(1, allGroup{:});

if exist('xlegend','var') & ~isempty(xlegend)
    xlegend_ordered = xlegend(idx);
    xlegend_ordered = categorical(xlegend_ordered,xlegend(idx),xlegend(idx),'Ordinal',true);
    allGroup = xlegend_ordered(allGroup);

end
f1 = figure('Visible','off');
a = axes('Parent', f1, 'NextPlot','add','YLimMode','auto');

boxplot(a,allData, allGroup,'ColorGroup',color_group_copy,'Colors',color_palette, 'BoxStyle','outline','Notch','off','OutlierSize',3,'Symbol','o','Widths',0.5);
% set aesthetic styles
boxhandle = findobj(a,'Tag','Box');
outlierhandle = findobj(a,'Tag','Outliers');
medianhandle = findobj(a,'Tag','Median');
LAV = findobj(a,'Tag','Lower Adjacent Value');
UAV = findobj(a,'Tag','Upper Adjacent Value');
LW = findobj(a,'Tag','Lower Whisker');
UW = findobj(a,'Tag','Upper Whisker');
if ~exist('a2','var') 
    f = figure; a2 = axes('Parent',f, 'NextPlot','add','YGrid','on','GridLineStyle',':');
elseif ~strcmp(get(a2,'type'),'axes')
    f = figure; a2 = axes('Parent',f, 'NextPlot','add','YGrid','on','GridLineStyle',':');
else
    a2.NextPlot = 'add'; a2.YGrid = 'on'; a2.GridLineStyle = ':';
end
    

for i = 1:length(outlierhandle)
    outlierhandle(i).MarkerFaceColor = outlierhandle(i).MarkerEdgeColor;
    LW(i).LineWidth = 1; UW(i).LineWidth = 1;
    LW(i).LineStyle = '-'; UW(i).LineStyle = '-';
    LW(i).Color = outlierhandle(i).MarkerEdgeColor; UW(i).Color = outlierhandle(i).MarkerEdgeColor;
    LAV(i).Color = outlierhandle(i).MarkerEdgeColor; UAV(i).Color = outlierhandle(i).MarkerEdgeColor;
    LAV(i).LineWidth = 1; UAV(i).LineWidth = 1;
    medianhandle(i).Color = [0,0,0]; medianhandle(i).LineWidth = 1;
    boxhandle(1).LineWidth = 1;
    % patch for boxes
    thisbox = boxhandle(i);
    xpos = [min(thisbox.XData),max(thisbox.XData),max(thisbox.XData),min(thisbox.XData)];
    ypos = [min(thisbox.YData), min(thisbox.YData), max(thisbox.YData), max(thisbox.YData)];
    patch(a2,xpos,ypos,thisbox.Color,'FaceAlpha',0.4,'EdgeAlpha',0);
    

end
copyobj(a.Children,a2);
% set axes properties
a2.XLim = a.XLim; a2.YLimitMethod = 'tickaligned'; a2.XLimitMethod = 'tickaligned';
a2.XTickMode = 'manual'; a2.XTick = a.XTick;
a2.XTickLabelMode = 'manual'; a2.XTickLabel = a.XTickLabel;  
a2.XTickLabelRotationMode = 'manual'; a2.XTickLabelRotation = a.XTickLabelRotation; 
a2.XAxis.FontSize = 13; a2.YAxis.FontSize = 13;
close(f1);

% add dot lines by colorgroup
if strcmp(dotline,'dot') | strcmp(dotline,'line')
    for i = unique(color_group_ori)
        xs = plotorder(find(color_group_ori==i));
        for j = xs % dots
            plot(a2, inputdata_copy{j}*0+j, inputdata_copy{j}, 'k.','MarkerSize',10);
        end
        if strcmp(dotline, 'line')
            for j = 1:numel(inputdata_copy{xs(1)})
                temp_data = [];
                for k = xs
                    temp_data = [temp_data;inputdata_copy{k}(j)];
                end
                plot(a2, xs, temp_data, 'k-');
            end
        end
    end
end


end