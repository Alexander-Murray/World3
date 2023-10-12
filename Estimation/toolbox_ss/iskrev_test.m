function [result] = iskrev_test(param_estim,observables,filename,T)
%[result] = iskrev_test(param_estim,observables,filename,T)
%
%rank of the derivative with respect to a vector of selected structural parameters of the autocovariance matrix of a DSGE model of the form: 
%x_{t+1} = hx x_t + ETASHOCK \epsilon_{t+1}
%y_t = gx x_t. 
%Inputs:
%param_estim: vector containing numerical values for all structural parameters of the DSGE model (not just those whose identifiability is being checked).
%observables :vector containing the indices of elements of y_t with observable counterparts
%filename : string variable containing the name of the model being analyzed.
%T :  order of the covariogram of the observables used to check for identifiability. T=1 means that only the contemporaneous covariance of observables is used for identification. T=2 adds the first-order autocovariance, and so on.
%Calls: gx_hx inputs
%(c) Stephanie Schmitt-Grohe and Martin Uribe, May 2012.
% We would like to  thank  Willi Mutschler, willi.mutschler@uni-muenster.de,  a Ph.D. student  from the University of Münster for pointing out a typo in an earlier version of this code. April 19, 2013. 



%Evaluate all required derivatives at steady-state values
 [fx, fy, fxp, fyp, varshock,  ETA, f, Dfyp_Dparam_estim, Dfy_Dparam_estim, Dfxp_Dparam_estim, Dfx_Dparam_estim, Deta_etaT_Dparam_estim] = gx_hx_inputs(param_estim,filename); 

%Obtain numerical values for law of motion of DSGE model up to first order
[gx,hx] = gx_hx(fy,fx,fyp,fxp);

nparam = size(Dfx_Dparam_estim,2);
nx=size(hx,1);
ny=size(gx,1);
n=nx+ny; 
hxT=transpose(hx);
gxT=transpose(gx);
SigmaX= mom(eye(nx),hx,varshock); 

%Construct dhx dgx
%use: fyp gx hx + fy gx + fxphx + fx = 0
% using sparse matrix
% See ``Implementing Iskrev's Identificability Test,'' by Stephanie Schmitt-Grohe and Martin Uribe, June 21, 2011

AA=kron((hxT),sparse(fyp))+kron(speye(nx),sparse(fy));

BB=kron(speye(nx),sparse(fyp*gx))+kron(speye(nx),sparse(fxp));

CC=-kron((hxT*gxT),speye(n))*sparse(Dfyp_Dparam_estim)-kron((hxT),speye(n))...
    *sparse(Dfxp_Dparam_estim)-kron(sparse(gxT),speye(n))*sparse(Dfy_Dparam_estim)-sparse(Dfx_Dparam_estim);

Dhxgx_Dparam_estim=[BB AA]\CC;

Dhx_Dparam_estim = Dhxgx_Dparam_estim(1:nx^2, :);
Dgx_Dparam_estim = Dhxgx_Dparam_estim(nx^2+1:end,:);
clear Dhxgx_Dparam_estim
%Construct dhxT dgxT
%nparam= length(param_estim);
DhxT_Dparam_estim=zeros(nx^2,nparam);
DgxT_Dparam_estim=zeros(nx*ny,nparam);

I = (1:nx^2)';
  DhxT_Dparam_estim= Dhx_Dparam_estim(fix((I-1)/nx)+1+rem(I-1,nx)*nx,:);  


I = (1:nx*ny)';
  DgxT_Dparam_estim= Dgx_Dparam_estim(fix((I-1)/nx)+1+rem(I-1,nx)*ny,:);

clear I


% Construct DSigmaX_Dparam_estim from SigmaX = hx*SigmaX * hx^T+ETA*ETA' 
% using sparse matrix
DSigmaX=(speye(nx^2)-sparse(kron(hx,hx)))\...
    (kron(sparse(hx*SigmaX),speye(nx))*sparse(Dhx_Dparam_estim)...
    +kron(speye(nx),sparse(hx*SigmaX))*sparse(DhxT_Dparam_estim)+sparse(Deta_etaT_Dparam_estim)); 

% compute dE(yty1T)
nobservables = length(observables);
C = zeros(nobservables,ny);
C(sub2ind(size(C),1:nobservables,observables)) = 1;


% precomputation
Cgx=C*gx;
CgxSigmaX=Cgx*SigmaX;
CgxSigmaXCgx=kron(CgxSigmaX,Cgx);
% t=1
DEy1y1T(1:nobservables^2,:)=kron(C,CgxSigmaX)*DgxT_Dparam_estim+kron(Cgx,Cgx)*DSigmaX...
    +kron(CgxSigmaX,C)*Dgx_Dparam_estim;
index= find(tril(ones(nobservables,nobservables)));
DEy1y1T=DEy1y1T(index,:);
% t=2:T
DEyty1T=zeros((T-1)*nobservables^2,nparam);
hxt=hx;
Dhxt_Dparam_estim=Dhx_Dparam_estim;

for t=2:T    
DEyty1T(nobservables^2*(t-2)+1:nobservables^2*(t-1),:)=kron(C,Cgx*hxt*SigmaX)*DgxT_Dparam_estim+kron(Cgx,Cgx*hxt)*DSigmaX...
    +CgxSigmaXCgx*Dhxt_Dparam_estim+kron(CgxSigmaX*hxt',C)*Dgx_Dparam_estim;
Dhxt_Dparam_estim=sparse(kron(speye(nx),hxt))*sparse(Dhx_Dparam_estim)+...
    (kron(hx',speye(nx)))*(Dhxt_Dparam_estim); % slow 
hxt=hxt*hx;
end

DEyty1T=[DEy1y1T;DEyty1T];

% compute rank
result=rank(DEyty1T);