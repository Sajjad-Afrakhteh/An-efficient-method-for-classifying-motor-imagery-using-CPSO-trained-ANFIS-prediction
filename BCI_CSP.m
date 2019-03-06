function [Wt,xout]=BCI_CSP(class1_train,class2_train,varargin)

if nargin<2
    error('Not enough input arguments!');
elseif nargin==2
    m=3;
elseif nargin==3
    m=varargin{1};
else
    error('Too many input arguments!');
end

if nargout<1
    error('Not enough output arguments!');
elseif nargout>2
    error('Too many output arguments!');
end
c1=0;
c2=0;
CA=0;
CB=0;
%% for class1 
X1=class1_train;
X1=X1-ones(size(class1_train,1),1)*mean(X1);
X1=X1';
c1=X1*X1'/size(class1_train,2);
CA=CA+c1;
%% for class2 
X2=class2_train;
X2=X2-ones(size(class2_train,1),1)*mean(X2);
X2=X2';
c2=X2*X2'/size(class2_train,2);
CB=CB+c2;
[U,L]=eig(CA,CB);
[L,indx]=sort(diag(L),'descend');
U=U(:,indx);
Wt=U';
Wt=[Wt(1:m,:);Wt(end-m+1:end,:)];
X=[class1_train;class2_train];
xout=Wt*X';