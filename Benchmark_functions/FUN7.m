% F7

function o = FUN7(x)
dim=size(x,2);
o=sum([1:dim].*(x.^4))+rand;
end
