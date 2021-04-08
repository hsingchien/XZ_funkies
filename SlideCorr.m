function [corr_vec, t_vec] = SlideCorr(M1, M2, wid, step, clist)
% input struct of M1, M2, output a plot of slide window correlation and vec
% M1, M2, data struct; wid, window length, default 60 (~ 2 seconds);
% step define step size, default 15; clist, 1x2 cell containing the vector
% of cell ID you want to plot. default {'all', 'all'}.
if nargin < 3
    wid = 60;
    step = 15;
    clist = {'all','all'};
elseif nargin < 4
    step = 15;
    clist = {'all','all'};
elseif nargin < 5
    clist = {'all','all'};
end

if isempty(wid)
    wid = 60;
end
if isempty(step)
    step = 15;
end
if ~isfield(M1, 'DataMatrix')
    M1.DataMatrix = M1.RawTraces;
    M2.DataMatrix = M2.RawTraces;
end
fr = 30; % frame rate
DM1 = zscore(M1.DataMatrix);
DM2 = zscore(M2.DataMatrix);

if ~strcmp(clist{1}, 'all')
   DM1 = DM1(:, clist{1});
end

if ~strcmp(clist{2}, 'all')
    DM2 = DM2(:,clist{2});
end


mleng = min(size(DM1,1), size(DM2,1));
DM1 = DM1(1:mleng, :);
DM2 = DM2(1:mleng, :);
mDM1 = mean(DM1, 2);
mDM2 = mean(DM2, 2);

corr_vec = [];
t_vec = [];
i = 1;
while i + wid <= length(mDM1)
    corr_vec = [corr_vec, corr2(mDM1(i:i+wid), mDM2(i:i+wid))];
    t_vec = [t_vec, i + round(wid/2)];
    i = i+step;
end

fig = figure;
ax = axes('NextPlot','add');
plot(t_vec/fr, corr_vec);
line([0, mleng/fr], [0,0], 'Color','red','LineStyle',':');

allTypes = unique([M1.Behavior.EventNames;M2.Behavior.EventNames]);
allTypes = setdiff(allTypes, 'pooled');
% patch behavior
if exist('maxdistcolor')
    cls = maxdistcolor(length(allTypes), @sRGB_to_CIELab);
else
    error('add maxdistcolor to the path');
end

behav_in_this_m = setdiff(M1.Behavior.EventNames, 'pooled');

for l = 1:length(behav_in_this_m)
    
    onsets=M1.behaviorStruct.(behav_in_this_m{l}).start;
    offsets=M1.behaviorStruct.(behav_in_this_m{l}).end;
    cid = find(strcmp(allTypes, behav_in_this_m{l}));
    for n = 1:length(onsets)
        P(l)= patch([onsets(n) onsets(n) offsets(n) offsets(n)]/fr,[1,2, 2, 1],cls(cid,:),'EdgeColor',cls(cid,:), 'FaceAlpha', 0.5);
    end       
end
text(mleng/fr+20, 1.5, 'Mouse1 behavior');
% patch([1 1 tm tm],[0 50 50 0],[0.1 0.4 0.1],'FaceAlpha',0.06)
% hold on
behav_in_this_m = setdiff(M2.Behavior.EventNames,'pooled');
for l = 1:length(behav_in_this_m)
    onsets=M2.behaviorStruct.(behav_in_this_m{l}).start;
    offsets=M2.behaviorStruct.(behav_in_this_m{l}).end;
    cid = find(strcmp(allTypes, behav_in_this_m{l}));
    for n = 1:length(onsets)
        P(l)= patch([onsets(n) onsets(n) offsets(n) offsets(n)]/fr,[2, 3, 3, 2],cls(cid,:),'EdgeColor',cls(cid,:), 'FaceAlpha', 0.5);
    end       
end
text(mleng/fr+20, 2.5, 'Mouse2 behavior');




% patch for behavior legend
block = round(mleng/fr/length(behav_in_this_m));
for i = 1:length(allTypes)
   ll = (i-1) * block;
   patch([ll, ll, ll+block, ll+block], [4, 5, 5, 4], cls(i,:),'EdgeColor',cls(i,:), 'FaceAlpha', 0.5);
   text(ll, 4.5,allTypes{i},'FontSize', 8);
    
end




end

