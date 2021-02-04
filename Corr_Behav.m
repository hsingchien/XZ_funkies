function [cor_in, cor_out] = Corr_Behav(M1,M2,B,mismatch)
% calculate correlation during the specified behavior and outside of
% the specified behavior
% M1, M2, data struct of 2 animals
% B, string or a cell of strings, containing behaviors you want to look,
% 'all' if you want to look all.
% mismatch, bool, default false. allow mismatch behaviors. e.g. M1 behav#1, M2 behav#2 is
% considered(true)/excluded(false)

if nargin < 3
    B = 'all';
    mismatch = false;
elseif nargin < 4
    mismatch = false;
end

if isempty(B)
    B = 'all';
end


DM1 = zscore(M1.DataMatrix);
Behav1 = 0 * M1.Behavior.LogicalVecs{1};
DM2 = zscore(M2.DataMatrix);
Behav2 = 0 * M2.Behavior.LogicalVecs{1};

% exclude 'pooled'
non_pool_idx = find(~strcmp(M1.Behavior.EventNames, 'pooled')); % adapt to shan's data

for i = 1:length(non_pool_idx)
    Behav1 = Behav1+i*M1.Behavior.LogicalVecs{non_pool_idx(i)};
    Behav2 = Behav2+i*M2.Behavior.LogicalVecs{non_pool_idx(i)};
end

Bvec = [];

if ~strcmp(B, 'all')
    for i = 1:length(B)
        Bvec = [Bvec, find(strcmp(M1.Behavior.EventNames, B{i}))];
    end
else
    
    Bvec = 1:length(non_pool_idx); % adapt to Shan's dataset.
end

% find the time vector both animals are doing the same behavior
Tvec = [];
if ~mismatch
    for i = 1:length(Bvec)
        M1_tvec = (Behav1 == Bvec(i));
        M2_tvec = (Behav2 == Bvec(i));
        Tvec = [Tvec; M1_tvec .* M2_tvec];
    end
else
    M1_tvec = ismember(Behav1, Bvec);
    M2_tvec = ismember(Behav2, Bvec);
    Tvec = M1_tvec.*M2_tvec;
end

Tvec = max(Tvec, [], 1);

% truncate datamatri
min_l = min([size(DM1,1), size(DM2,1), length(Tvec)]);
Tvec = Tvec(1:min_l);


DM1_in = DM1(Tvec>0,:);
DM2_in = DM2(Tvec>0,:);
DM1_out = DM1(Tvec==0,:);
DM2_out = DM2(Tvec==0,:);

cor_in = corr2(mean(DM1_in,2), mean(DM2_in,2));
cor_out = corr2(mean(DM1_out,2), mean(DM2_out,2));


end

