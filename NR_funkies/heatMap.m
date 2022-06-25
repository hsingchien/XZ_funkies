
function [h,ax] = heatMap(inpMat,NameValueArgs)

arguments
    
    inpMat
    NameValueArgs.title = []
    NameValueArgs.xLabel = []
    NameValueArgs.yLabel = []
    NameValueArgs.xTickLabels = strsplit(num2str([1:size(inpMat,2)]))
    NameValueArgs.yTickLabels = strsplit(num2str([1:size(inpMat,1)]))
    NameValueArgs.fontSize = 12
    NameValueArgs.colorLimits = []
    NameValueArgs.cellLabelFormat = []
    NameValueArgs.xTickAngle = []
    NameValueArgs.sparse = false
    NameValueArgs.colormap = []
    NameValueArgs.colorbar = 'on'
    NameValueArgs.grid = 'on'
    NameValueArgs.nanColor = [0.6,0.6,0.6]
    
end

warning('off','MATLAB:structOnObject');

if NameValueArgs.sparse == true
    inpMat(inpMat == 0) = nan;
end

if ~isempty(NameValueArgs.colormap)
    h = heatmap(inpMat,'Colormap',NameValueArgs.colormap); %
else
    h = heatmap(inpMat); %
end

if ~isempty(NameValueArgs.nanColor)
    h.MissingDataColor = NameValueArgs.nanColor;
end

if NameValueArgs.sparse == true
    h.MissingDataColor = h.Colormap(1,:);
end

if ~isempty(NameValueArgs.title)
    h.Title = NameValueArgs.title;
end

if ~isempty(NameValueArgs.yLabel)
	h.YLabel = NameValueArgs.yLabel;
end

if ~isempty(NameValueArgs.xLabel)
	h.XLabel = NameValueArgs.xLabel;
end

h.XDisplayLabels = NameValueArgs.xTickLabels;

h.YDisplayLabels = NameValueArgs.yTickLabels;

if ~isempty(NameValueArgs.colorLimits)
    h.ColorLimits = NameValueArgs.colorLimits;
end

if ~isempty(NameValueArgs.cellLabelFormat)
    h.CellLabelFormat = NameValueArgs.cellLabelFormat;
end

if ~isempty(NameValueArgs.xTickAngle)
    hs = struct(h); hs.NodeChildren(3).XTickLabelRotation = NameValueArgs.xTickAngle;
end

h.FontSize = NameValueArgs.fontSize;
h.ColorbarVisible = NameValueArgs.colorbar;
h.GridVisible = NameValueArgs.grid;

set(gcf,'color','w');
ax = get(gca);

end


