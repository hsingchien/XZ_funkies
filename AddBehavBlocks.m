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
% ylow = 15;
% yhigh = 18;
if strcmp('all',blist)
    blist = B.EventNames;
end
blist(find(strcmp(blist,'other'))) = [];

for b = 1:length(blist)
    bname = blist{b};
   % find the index of behavior
   bindx = find(strcmp(B.EventNames, bname));
   % onset time and offset time
   bonset = B.OnsetTimes{bindx}; % bstructure index start from 0
   boffset = B.OffsetTimes{bindx}; % bstructure index start from 0
   bonsettime = Btimestamp(bonset+1);
   boffsettime = Btimestamp(boffset+1);
   for k = 1:length(bonsettime)
      this_onset = bonsettime(k);
      this_offset = boffsettime(k);
      P = patch(tax,[this_onset this_onset this_offset this_offset],[ylow, yhigh, yhigh, ylow],clist(b,:),'EdgeColor',[1,1,1], 'FaceAlpha', 0.3);       
   end
    
    
end

block = round(range(xrange)/length(clist));
for i = 1:length(blist)
    ll = (i-1) * block; 
    patch([ll, ll, ll+block, ll+block], [yhigh+1, yhigh+3, yhigh+3, yhigh+1], clist(i,:),'EdgeColor',clist(i,:), 'FaceAlpha', 0.3);
    text(ll, yhigh+2, blist{i},'FontSize', 10);
end





end

