function [cor_in, cor_out] = Corr_Behav(M1,M2,B)
% calculate correlation during the specified behavior and outside of
% the specified behavior
% M1, M2, data struct of 2 animals
% B, 1 x 2 cell of strings, {M1_behav, M2_behav}. Defines what time window
% to count, each string is a series of behavios parsed by ',', or 'all' if
% you want to count all
% 'all' if you want to look all.
B1 = B{1};
B2 = B{2};
B1 = B1(~isspace(B1));
B2 = B2(~isspace(B2));

B1 = strsplit(B{1},',');
B2 = strsplit(B{2},',');



DM1 = zscore(M1.DataMatrix);
Behav1 = 0 * M1.Behavior.LogicalVecs{1}; % pooled vec of all behaviors
DM2 = zscore(M2.DataMatrix);
Behav2 = 0 * M2.Behavior.LogicalVecs{1}; % pooled vec of all behaviors

% exclude 'pooled'
all_behav = unique([M1.Behavior.EventNames(:); M2.Behavior.EventNames(:)]);

all_behav = setdiff(all_behav, 'pooled'); % adapt to shan's data

for i = 1:length(all_behav)
    if ~isempty(find(strcmp(M1.Behavior.EventNames, all_behav{i})))
        Behav1 = Behav1+i*M1.Behavior.LogicalVecs{find(strcmp(M1.Behavior.EventNames, all_behav{i}))};
    end
    if ~isempty(find(strcmp(M2.Behavior.EventNames, all_behav{i})))
        Behav2 = Behav2+i*M2.Behavior.LogicalVecs{find(strcmp(M2.Behavior.EventNames, all_behav{i}))};
    end
end

Bvec1 = 0 * M1.Behavior.LogicalVecs{1};
Bvec2 = 0 * M2.Behavior.LogicalVecs{1};


for i = 1:length(B1)
    bb = B1{i};
    if strcmp(bb, 'all')
        Bvec1 = Bvec1 + (Behav1 > 0);
    elseif strcmp(bb, 'none')
        Bvec1 = Bvec1 + (Behav1 == 0);
    else
        Bvec1 = Bvec1 + (Behav1 == find(strcmp(all_behav, bb)));
    end
end

for i = 1:length(B2)
    bb = B2{i};
    if strcmp(bb, 'all')
        Bvec2 = Bvec2 + (Behav2 > 0);
    elseif strcmp(bb, 'none')
        Bvec2 = Bvec2 + (Behav2 == 0);
    else
        Bvec2 = Bvec2 + (Behav2 == find(strcmp(all_behav, bb)));
    end
end
    



% find the time vector both animals are doing the specified behavior
Tvec = Bvec1 .* Bvec2;



% truncate datamatrix
tm = 1:min([size(DM1,1), size(DM2,1), length(Tvec)]);
Tvec = Tvec(tm);


DM1_in = DM1(Tvec>0,:);
DM2_in = DM2(Tvec>0,:);
DM1_out = DM1(Tvec==0,:);
DM2_out = DM2(Tvec==0,:);

cor_in = corr2(mean(DM1_in,2), mean(DM2_in,2));
cor_out = corr2(mean(DM1_out,2), mean(DM2_out,2));

f = figure;
a = axes('NextPlot','add');
fr = 30;
DM1 = DM1(tm,:);
DM2 = DM2(tm,:);
space = 2;
plot(a, tm/fr,mean(DM1, 2));
plot(a, tm/fr,mean(DM2, 2) - space);

% patch time window


onsets = find(diff([0,Tvec]) == 1);
offsets = find(diff(Tvec) == -1);

if length(onsets) > length(offsets)
    onsets = onsets(1:end-1);
elseif length(offsets) > length(onsets)
    offsets = offsets(2:end);
end




for n = 1:length(onsets)
    patch([onsets(n) onsets(n) offsets(n) offsets(n)]/fr,[-space-1, 1, 1, -space-1],[0,1,0],'EdgeColor',[0,1,0], 'FaceAlpha', 0.2,'EdgeAlpha',0.2);
    
end
           

text(tm(end)/fr+20, 0, 'Mouse1 behavior');
text(tm(end)/fr+20, -space, 'Mouse2 behavior');
    





end

