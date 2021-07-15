function [idx1,idx2,tdifference] = TStampAlign(refstamp,mapstamp)
% refstamp, mapstamp, time stamp vector. This func aligns the two time
% stamp vectors using refstamp as reference. 
% outputs: aligned index of both time stamps and time difference (ms)
% method: assume time stamp is strictly linear (constant sampling rate),
% calculate slope 1 and slope 2, and use this value to map.





[~,r,b] = regression(1:length(mapstamp), reshape(mapstamp,1,[]));

mapidx = round((refstamp - b)/r);

mapidx(mapidx > length(mapstamp)) = []; 
mapidx(mapidx < 1) = 1;

idx1 = 1:length(refstamp);
idx2 = mapidx;
mlen = min(length(idx1), length(idx2));
tdifference = refstamp(1:mlen) - mapstamp(idx2);



end

