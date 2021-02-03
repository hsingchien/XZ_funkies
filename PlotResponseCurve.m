function Cdic = PlotResponseCurve(M, B, cell_ID, t_window)
% plot response curve of a specified behavior type
% Inputs: M, struct that contains gcamp signals and behavior annotation
% B: string, specify what behavior you want to plot. make sure input a
% valid one
% cell_ID, vector or string 'all'. specify the cells you want to plot,
% 'all' will plot all
% t_window, time window wrapping the behavior onset, +- t_window will be
% plotted. 
% return a containers.map (matlab's dictionary), see help containers for
% info
if nargin < 3
    cell_ID = 1:50;
    t_window = 3;
elseif nargin < 4
    t_window = 3;
end

if isempty(cell_ID)
    cell_ID = 1:50;
end
if isempty(t_window)
    t_window = 3;
end

fr = 30;
DM = zscore(M.DataMatrix);
b_events = M.Behavior.EventNames;
B_index = find(strcmp(b_events, B));
B_onset = M.Behavior.OnsetTimes{B_index};
Cdic = containers.Map('KeyType','double','ValueType','any');
for i = 1:length(cell_ID)
   stack_l = [];
   cur_c = cell_ID(i);
   
   for j = 1:length(B_onset)
      cur_event = B_onset(j);
      start = max(1, cur_event - fr * t_window);
      stop = min(size(DM,1), cur_event + fr * t_window);
      this_event = DM(start:stop,cur_c);
      % pad with 0s
      if (cur_event-fr*t_window < 1)
          this_event = [zeros(2*fr*t_window+1-length(this_event),1); this_event];
      elseif (cur_event+fr*t_window > size(DM,1))
          this_event = [this_event; zeros(2*fr*t_window+1-length(this_event),1)];
      end
      stack_l = [stack_l, this_event];
   end
   Cdic(cur_c) = stack_l;    
end

% plot

spacing = 1;
all_mean_trace = [];
for i = 1:length(cell_ID)
    this_c_trace = Cdic(cell_ID(i));
    all_mean_trace = [all_mean_trace, mean(this_c_trace, 2) + spacing*(length(cell_ID)-i)];
end
t_ax = linspace(-t_window, t_window, 2*fr*t_window+1);

f= figure;
a = axes('NextPlot','add');
plot(t_ax, all_mean_trace, '-', 'Parent', a);
line([0,0], a.YLim);





end

