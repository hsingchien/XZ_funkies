function [onset_t,offset_t,k] = FindConsecutiveOnsetOffset(inputvec, k, it, t)
% find onset offset idx of elements
% inputvec, nx1
% k, vector containing element of query
% it, interval threshold default 1
% t, duration threshold default 1

if nargin < 4
    it = 1;
    t = 1;
elseif nargin <3
    t = 1;
end

if isempty(it)
    it = 1;
end

if ~exist('k','var')
    k = sort(unique(inputvec));
end

inputvec = reshape(inputvec, 1, []);

onset_t = {};
offset_t = {};
for j = 1:length(k)
    idxj = find(inputvec==k(j));
    difidx = diff(idxj);
    onset = [idxj(1),idxj(find(difidx > 1)+1)];
    offset = [idxj(find(difidx > 1)), idxj(end)];
%     % filter out disqualified instances
%     % test interval first (merge small intervals)
%     intervals = onset(2:end) - offset(1:end-1); % intervals
%     while(min(intervals) < it)
%         to_merge_idx = find(intervals < it); % merge to_merge_idx with to_merge_idx + 1
%         % merge
%         onset = [onset,onset(to_merge_idx)];
%         offset = [offset, offset(to_merge_idx+1)];
%         onset(to_merge_idx+1) = []; onset = sort(onset);
%         offset(to_merge_idx) = []; offset = sort(offset);
%         intervals = onset(2:end) - offset(1:end-1);
%     end





    onset_t{j} = onset;
    offset_t{j} = offset;
end





end