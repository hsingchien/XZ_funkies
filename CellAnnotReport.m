function annot_list = CellAnnotReport(estruct,clist)
% report cell roc annotation

annot_list = {};
sbjbtype = {'sbj_push', 'sbj_approach', 'sbj_retreat'};
oppbtype = {'opp_push','opp_approach','opp_retreat'};
j = 1;
for i = transpose(clist)
    sbj = estruct.sigCell.sbj.Pos;
    opp = estruct.sigCell.opp.Pos;
    sbj_a = sbj(i, 1:3);
    opp_a = opp(i, 1:3);
    
    annot_list{j} = {sbjbtype{sbj_a>0}, oppbtype{opp_a>0}};
    j = j + 1;
    
end


end

