function [outputArg1,outputArg2] = PSTH(neurons,time_points,window,ax)
% PSTH for given time points and window
if nargin < 4
    f = figure; ax = axes('Parent',f,'NextPlot','add');
end
all_trace = [];
for i = 1:numel(time_points)
    temp_trace = neurons((time_points(i)-window):time_points(i)+window,:);
%     plot(ax,(0-window):(0+window), temp_trace, 'Color', [0.9,0.9,0.9]);
    all_trace = [all_trace, temp_trace];
end
% patch confidence interval
x = (0-window):(0+window);
y = transpose(mean(all_trace,2));
stdy = std(all_trace',0,1)/sqrt(size(all_trace,2));
fill(ax, [x, x(end:-1:1)]/3, [y+2*stdy,y(end:-1:1)-flip(2*stdy)],[0.9,0.9,0.9],'FaceColor',[0.9,0.9,0.9],'EdgeColor','none');
line(ax, [0,0], ax.YLim, 'Color','blue');
plot(ax, x/3, y, 'Color', 'red');


end