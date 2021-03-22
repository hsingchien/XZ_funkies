function [c0,c1,c2] = QuikCorr(ms1,ms2)
% input 2 ms, calculate corr
if ischar(ms1)
    ms1 = load(ms1);
    name = fields(ms1);
    name = name{1};
    ms1 = ms1.(name);
end
if ischar(ms2)
    ms2 = load(ms2);
    name = fields(ms2);
    name = name{1};
    ms2 = ms2.(name);
end
if ~isfield(ms1, 'cell_label')
    ms1.cell_label = ones([size(ms1.FiltTraces,2),1]);
end
if ~isfield(ms2, 'cell_label')
    ms2.cell_label = ones([size(ms2.FiltTraces,2),1]);
end

tr1 = ms1.RawTraces(:,ms1.cell_label>0);
tr2 = ms2.RawTraces(:,ms2.cell_label>0);
tr11 = ms1.FiltTraces(:,ms1.cell_label>0);
tr22 = ms2.FiltTraces(:,ms2.cell_label>0);
tr111 = ms1.FFTTraces(:,ms1.cell_label>0);
tr222 = ms2.FFTTraces(:,ms2.cell_label>0);


mlen = min(size(tr1,1), size(tr2,1));

tr1 = tr1(1:mlen, :);
tr2 = tr2(1:mlen, :);
tr11 = tr11(1:mlen,:);
tr22 = tr22(1:mlen,:);
tr111 = tr111(1:mlen,:);
tr222 = tr222(1:mlen,:);



% c0 = corr(mean(tr1,2),mean(tr2,2));
c0 = corr(mean(zscore(tr1),2), mean(zscore(tr2),2));
c1 = corr(mean(zscore(tr11),2), mean(zscore(tr22),2));
c2 = corr(mean(zscore(tr111),2), mean(zscore(tr222),2));
f = figure;
subplot(2,1,1),hold on, plot(mean(zscore(tr1),2),'g-'); plot(mean(zscore(tr11),2),'b-'); plot(mean(zscore(tr111),2),'r-'); title(ms1.dirName);
subplot(2,1,2),hold on, plot(mean(zscore(tr2),2),'g-'); plot(mean(zscore(tr22),2),'b-'); plot(mean(zscore(tr222),2),'r-'); title(ms2.dirName);

% savefig(f, [ms1.vName(1:6),'.fig']);   


end

