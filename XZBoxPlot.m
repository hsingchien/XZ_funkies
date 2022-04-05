function  f = XZBoxPlot(InputData, ColorGroup)
% InputData, cell, each entry is a group of data nx1
% ColorGroup if you want to specify specific group order
if nargin < 2
    ColorGroup = [];
end

% make sure all entries in InputData are nx1
InputData_copy = {};
for i = 1:length(InputData)
    InputData_copy = [InputData_copy, num2cell(InputData{i},1)];
end
InputData = InputData_copy;

allData = cat(1, InputData{:});
allGroup = InputData;
for i = 1:length(allGroup)
    allGroup{i} = 0 * allGroup{i} + i;
end
allGroup = cat(1, allGroup{:});

f = figure;
a = axes('Parent', f);

boxplot(a,allData, allGroup)


end