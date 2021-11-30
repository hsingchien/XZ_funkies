function AddBehavBlocks(tax,B,Btimestamp,blist, clist)
% add behavior blocks in the axes
% tax, target axes
% B, behavior structure
% Btimestamp, behavior timestamp
% blist, cell, containing the behaviors to patch
% clist, color scheme for behaviors, corresponding to blist
xrange = tax.XLim;
yrange = tax.YLim;
ylow = yrange(1);
yhigh = yrange(2);
if strcmp('all',blist)
    blist = B.EventNames;
end
for b = 1:length(blist)
    bname = blist{b};
   % find the index of behavior
   bindx = find(strcmp(B.EventNames, bname));
   % onset time and offset time
   bonset = B.OnsetTimes{bindx};
   boffset = B.OffsetTimes{bindx};
   bonsettime = Btimestamp(bonset);
   boffsettime = Btimestamp(boffset);
   for k = 1:length(bonsettime)
      this_onset = bonsettime(k);
      this_offset = boffsettime(k);
      P = patch(tax,[this_onset this_onset this_offset this_offset],[ylow, yhigh, yhigh, ylow],clist(b,:),'EdgeColor',clist(b,:), 'FaceAlpha', 0.5);       
   end
    
    
end





end

