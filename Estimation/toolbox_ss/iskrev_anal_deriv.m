function []=iskrev_anal_deriv(filename,f,statevar_cu,controlvar_cu,fyp,fy,fxp,fx,ETASHOCK,param_estim)
%[]=iskrev_anal_deriv(filename,f,statevar_cu,controlvar_cu,fyp,fy,fxp,fx,ETASHOCK,param_estim)
%prints to a file the first part of whose name is specified in filename symbolic derivatives of the function f used to perform the Iskrev test of identifiability. For more details, see the readme file associated with this applicaiton. 
%
%The vector of estimated parameters = param_estim
%important: this should be the f after we have repalced x_t, x_{t+1}, y_t, and y_{t+1} by their respective steady states, x, x, y, and y. 
%(c) Stephanie Schmitt-Grohe and Martin Uribe. May 2012. 

%concatenate the state and control vectors
xy = [statevar_cu(:); controlvar_cu(:)];

% construct Dxy_Dparam_estim
Df_Dparam_estim = jacobian(f,param_estim);  

Df_Dxy = jacobian(f, xy);

% this part is only numerically evaluated 
% Dxy_Dparam_estim = - Df_Dxy\Df_Dparam_estim; 

% construct dfyp dfy dfxp dfx by terms
% Dfyp_Dparam_estim = jacobian(fyp(:), param_estim) + jacobian(fyp(:), xy) * Dxy_Dparam_estim; 
% 
% Dfy_Dparam_estim = jacobian(fy(:), param_estim) + jacobian(fy(:), xy) * Dxy_Dparam_estim; 
% 
% Dfxp_Dparam_estim = jacobian(fxp(:), param_estim) + jacobian(fxp(:), xy) * Dxy_Dparam_estim; 
% 
% Dfx_Dparam_estim = jacobian(fx(:), param_estim) + jacobian(fx(:), xy) * Dxy_Dparam_estim;

Dfyp_Dparam_estim1 = jacobian(fyp(:), param_estim);
Dfyp_Dparam_estim2 = jacobian(fyp(:), xy);
Dfy_Dparam_estim1 = jacobian(fy(:), param_estim);
Dfy_Dparam_estim2 = jacobian(fy(:), xy);
Dfxp_Dparam_estim1 = jacobian(fxp(:), param_estim);
Dfxp_Dparam_estim2 = jacobian(fxp(:), xy);
Dfx_Dparam_estim1 = jacobian(fx(:), param_estim);
Dfx_Dparam_estim2 = jacobian(fx(:), xy);

% construct detaetaT 
ETAMATRIX2 = ETASHOCK*transpose(ETASHOCK);
Deta_etaT_Dparam_estim = jacobian(ETAMATRIX2, param_estim) ;
% using different formula
% Deta_Dparam_estim= jacobian(ETASHOCK, param_estim);
% DetaT_Dparam_estim= jacobian(transpose(ETASHOCK),param_estim);
% Deta_etaT_Dparam_estim = kron(eye(size(fx,2)),ETASHOCK)*DetaT_Dparam_estim+...
%                           kron(ETASHOCK,eye(size(fx,2)))*Deta_Dparam_estim;

% print solution
% create m-file
fid=fopen([filename,'_iskrev_anal_deriv.m'],'w');

% print jacobian
izero=(Df_Dparam_estim~=0);
izeroi=find(izero);
S=['Df_Dparam_estim=zeros(',num2str(numel(izero)),',' num2str(1) ');\n'];
fprintf(fid,S);
for i=1:length(izeroi);
 S2 = char(Df_Dparam_estim(izeroi(i)));
 S = [' Df_Dparam_estim(' num2str(izeroi(i)) ',' num2str(1) ')= ' S2(1:end) ';  \n'];   
 fprintf(fid,S);
end
S = ['Df_Dparam_estim=reshape(Df_Dparam_estim,[', num2str(size(izero)),']);\n'];  
fprintf(fid,S);

izero=(Df_Dxy~=0);
izeroi=find(izero);
S=['Df_Dxy=zeros(',num2str(numel(izero)),',' num2str(1) ');\n'];
fprintf(fid,S);
for i=1:length(izeroi);
 S2 = char(Df_Dxy(izeroi(i)));
 S = [' Df_Dxy(' num2str(izeroi(i)) ',' num2str(1) ')= ' S2(1:end) ';  \n'];   
 fprintf(fid,S);
end
S = ['Df_Dxy=reshape(Df_Dxy,[', num2str(size(izero)),']);\n'];  
fprintf(fid,S);

S = [' Dxy_Dparam_estim = - Df_Dxy\\Df_Dparam_estim; \n'];
fprintf(fid,S);

%%%

izero=(Dfyp_Dparam_estim1~=0);
izeroi=find(izero);
S=['Dfyp_Dparam_estim1=zeros(',num2str(numel(izero)),',' num2str(1) ');\n'];
fprintf(fid,S);
for i=1:length(izeroi);
 S2 = char(Dfyp_Dparam_estim1(izeroi(i)));
 S = [' Dfyp_Dparam_estim1(' num2str(izeroi(i)) ',' num2str(1) ')= ' S2(1:end) ';  \n'];   
 fprintf(fid,S);
end
S = ['Dfyp_Dparam_estim1=reshape(Dfyp_Dparam_estim1,[', num2str(size(izero)),']);\n'];  
fprintf(fid,S);

izero=(Dfyp_Dparam_estim2~=0);
izeroi=find(izero);
S=['Dfyp_Dparam_estim2=zeros(',num2str(numel(izero)),',' num2str(1) ');\n'];
fprintf(fid,S);
for i=1:length(izeroi);
 S2 = char(Dfyp_Dparam_estim2(izeroi(i)));
 S = [' Dfyp_Dparam_estim2(' num2str(izeroi(i)) ',' num2str(1) ')= ' S2(1:end) ';  \n'];   
 fprintf(fid,S);
end
S = ['Dfyp_Dparam_estim2=reshape(Dfyp_Dparam_estim2,[', num2str(size(izero)),']);\n'];  
fprintf(fid,S);

S = [' Dfyp_Dparam_estim = Dfyp_Dparam_estim1  + Dfyp_Dparam_estim2  * Dxy_Dparam_estim; \n'];
fprintf(fid,S);
S = [' clear Dfyp_Dparam_estim1 Dfyp_Dparam_estim2; \n'];
fprintf(fid,S);
%%%
izero=(Dfy_Dparam_estim1~=0);
izeroi=find(izero);
S=['Dfy_Dparam_estim1=zeros(',num2str(numel(izero)),',' num2str(1) ');\n'];
fprintf(fid,S);
for i=1:length(izeroi);
 S2 = char(Dfy_Dparam_estim1(izeroi(i)));
 S = [' Dfy_Dparam_estim1(' num2str(izeroi(i)) ',' num2str(1) ')= ' S2(1:end) ';  \n'];   
 fprintf(fid,S);
end
S = ['Dfy_Dparam_estim1=reshape(Dfy_Dparam_estim1,[', num2str(size(izero)),']);\n'];  
fprintf(fid,S);

izero=(Dfy_Dparam_estim2~=0);
izeroi=find(izero);
S=['Dfy_Dparam_estim2=zeros(',num2str(numel(izero)),',' num2str(1) ');\n'];
fprintf(fid,S);
for i=1:length(izeroi);
 S2 = char(Dfy_Dparam_estim2(izeroi(i)));
 S = [' Dfy_Dparam_estim2(' num2str(izeroi(i)) ',' num2str(1) ')= ' S2(1:end) ';  \n'];   
 fprintf(fid,S);
end
S = ['Dfy_Dparam_estim2=reshape(Dfy_Dparam_estim2,[', num2str(size(izero)),']);\n'];  
fprintf(fid,S);

S = [' Dfy_Dparam_estim =  Dfy_Dparam_estim1 + Dfy_Dparam_estim2  * Dxy_Dparam_estim; \n'];
fprintf(fid,S);
S = [' clear Dfy_Dparam_estim1 Dfy_Dparam_estim2; \n'];
fprintf(fid,S);
%%%
izero=(Dfxp_Dparam_estim1~=0);
izeroi=find(izero);
S=['Dfxp_Dparam_estim1=zeros(',num2str(numel(izero)),',' num2str(1) ');\n'];
fprintf(fid,S);
for i=1:length(izeroi);
 S2 = char(Dfxp_Dparam_estim1(izeroi(i)));
 S = [' Dfxp_Dparam_estim1(' num2str(izeroi(i)) ',' num2str(1) ')= ' S2(1:end) ';  \n'];   
 fprintf(fid,S);
end
S = ['Dfxp_Dparam_estim1=reshape(Dfxp_Dparam_estim1,[', num2str(size(izero)),']);\n'];  
fprintf(fid,S);

izero=(Dfxp_Dparam_estim2~=0);
izeroi=find(izero);
S=['Dfxp_Dparam_estim2=zeros(',num2str(numel(izero)),',' num2str(1) ');\n'];
fprintf(fid,S);
for i=1:length(izeroi);
 S2 = char(Dfxp_Dparam_estim2(izeroi(i)));
 S = [' Dfxp_Dparam_estim2(' num2str(izeroi(i)) ',' num2str(1) ')= ' S2(1:end) ';  \n'];   
 fprintf(fid,S);
end
S = ['Dfxp_Dparam_estim2=reshape(Dfxp_Dparam_estim2,[', num2str(size(izero)),']);\n'];  
fprintf(fid,S);

S = [' Dfxp_Dparam_estim =  Dfxp_Dparam_estim1 +  Dfxp_Dparam_estim2 * Dxy_Dparam_estim; \n'];
fprintf(fid,S);
S = [' clear Dfxp_Dparam_estim1 Dfxp_Dparam_estim2; \n'];
fprintf(fid,S);
%%%
izero=(Dfx_Dparam_estim1~=0);
izeroi=find(izero);
S=['Dfx_Dparam_estim1=zeros(',num2str(numel(izero)),',' num2str(1) ');\n'];
fprintf(fid,S);
for i=1:length(izeroi);
 S2 = char(Dfx_Dparam_estim1(izeroi(i)));
 S = [' Dfx_Dparam_estim1(' num2str(izeroi(i)) ',' num2str(1) ')= ' S2(1:end) ';  \n'];   
 fprintf(fid,S);
end
S = ['Dfx_Dparam_estim1=reshape(Dfx_Dparam_estim1,[', num2str(size(izero)),']);\n'];  
fprintf(fid,S); 
 
izero=(Dfx_Dparam_estim2~=0);
izeroi=find(izero);
S=['Dfx_Dparam_estim2=zeros(',num2str(numel(izero)),',' num2str(1) ');\n'];
fprintf(fid,S);
for i=1:length(izeroi);
 S2 = char(Dfx_Dparam_estim2(izeroi(i)));
 S = [' Dfx_Dparam_estim2(' num2str(izeroi(i)) ',' num2str(1) ')= ' S2(1:end) ';  \n'];   
 fprintf(fid,S);
end
S = ['Dfx_Dparam_estim2=reshape(Dfx_Dparam_estim2,[', num2str(size(izero)),']);\n'];  
fprintf(fid,S); 

S = [' Dfx_Dparam_estim = Dfx_Dparam_estim1 + Dfx_Dparam_estim2  * Dxy_Dparam_estim; \n'];
fprintf(fid,S);
S = [' clear Dfx_Dparam_estim1 Dfx_Dparam_estim2; \n'];
fprintf(fid,S);
%%%
izero=(Deta_etaT_Dparam_estim~=0);
izeroi=find(izero);
S=['Deta_etaT_Dparam_estim=zeros(',num2str(numel(izero)),',' num2str(1) ');\n'];
fprintf(fid,S);
for i=1:length(izeroi);
 S2 = char(Deta_etaT_Dparam_estim(izeroi(i)));
 S = [' Deta_etaT_Dparam_estim(' num2str(izeroi(i)) ',' num2str(1) ')= ' S2(1:end) ';  \n'];   
 fprintf(fid,S);
end
S = ['Deta_etaT_Dparam_estim=reshape(Deta_etaT_Dparam_estim,[', num2str(size(izero)),']);\n'];  
fprintf(fid,S); 
 
 