function [c1,c2] = QuikCorr(ms1,ms2)
% input 2 ms, calculate corr
if isstr(ms1)
    ms1 = load(ms1);
    ms1 = ms1.ms;
end
if isstr(ms2)
    ms2 = load(ms2);
    ms2 = ms2.ms;
end

tr1 = ms1.RawTraces(:,ms1.cell_label>0);
tr2 = ms2.RawTraces(:,ms2.cell_label>0);

mlen = min(size(tr1,1), size(tr2,1));

tr1 = tr1(1:mlen, :);
tr2 = tr2(1:mlen, :);


c1 = corr(mean(zscore(tr1),2), mean(zscore(tr2),2));
tr1(tr1<0) = 0;
tr2(tr2<0) = 0;
c2 = corr(mean(zscore(tr1),2), mean(zscore(tr2),2));
    


end

