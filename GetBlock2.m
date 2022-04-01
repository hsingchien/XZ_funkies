function [dat] = GetBlock2(dat, varargin)
%[dat] = getblock(dat, varargin) select subarray and retain all others
%                                unchanged
%dat2 = getblock(dat, [1,2], [3,5]) is equivalent to
%       dat2 = dat(1:2, 3:5, :, :, :) etc.
%Peter Burns 4 June 2013

arg1(1:ndims(dat)) = {':,'};
v = cell2mat(varargin);
nv = length(v)/2;
v = reshape(v,2,nv)';
for ii=1:nv
    arg1{ii} = [num2str(v(ii,1)),':',num2str(v(ii,2)),','];
end
arg2 = cell2mat(arg1);
arg2 = ['dat(',arg2(1:end-1),')'];
dat = eval(arg2);

end