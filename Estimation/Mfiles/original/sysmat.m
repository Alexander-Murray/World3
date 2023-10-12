function [A,B,H,R,Se,Phi, PD] = sysmat(T1,T0,para)

% This function computes the matrices of the state space representation.
% Input = para : Vector of Structural Parameters
%         T1 T0: 
% Output= Matrices of state space model. See kalman.m

h       = para(1);
xip     = para(2);
psipi   = para(3);
psiy    = para(4);
psidy   = para(5);
psir_1  = para(6);
psir_2 =  para(7);
abar    = para(8);
pibar   = para(9);
rbar    = para(10);
rhob    = para(11);
rhoz    = para(12);
rhor    = para(13);
sigmab  = para(14);
sigmaz  = para(15);
sigmai  = para(16);
sigmas  = para(17);
alphaBN = para(18);
M_b     = para(19);
M_z     = para(20);
M_i     = para(21);
rho_pi  = para(22);
sigmap  = para(23);
M_p     = para(24);

% /** observation indices **/
eq_ygr  = 1;
eq_pinf = 2;
eq_rn   = 3;

% /** number of observation variables **/
ny = 3;

% /** model variable indices **/
v_y    = 1;
v_pi   = 2;
v_i    = 5;
v_ez   = 9;
v_ylag = 14;
v_pitar = 17;

% /** shock indices **/
e_b = 1;
e_z = 2;
e_i = 3;
e_s = 4;
e_p = 5;

%=========================================================================
%                          TRANSITION EQUATION
%  
%           s(t) = Phi*s(t-1) + R*e(t)
%           e(t) ~ iid N(0,Se)
% 
%=========================================================================
nstate = size(T1,1); 
nep = size(T0,2);
Phi = T1;
R   = T0;

QQ = zeros(nep, nep);
QQ(e_b,e_b) = (sigmab)^2;
QQ(e_z,e_z) = (sigmaz)^2;
QQ(e_i,e_i) = (sigmai)^2;
QQ(e_s,e_s) = (sigmas)^2;
QQ(e_p,e_p) = (sigmap)^2;

QQ(e_s,e_b) = M_b*sigmas*sigmab;
QQ(e_b,e_s) = QQ(e_s,e_b);

QQ(e_s,e_z) = M_z*sigmas*sigmaz;
QQ(e_z,e_s) = QQ(e_s,e_z);

QQ(e_s,e_i) = M_i*sigmas*sigmai;
QQ(e_i,e_s) = QQ(e_s,e_i);

QQ(e_s,e_p) = M_p*sigmas*sigmap;
QQ(e_p,e_s) = QQ(e_s,e_p);

QQ = (QQ+QQ')/2;
Se = QQ;
PD = 1;

d = eig(QQ);
issemiposdef = all(d>=0) ;
if issemiposdef==0
    PD = 0;
end

%=========================================================================
%                          MEASUREMENT EQUATION
%  
%           y(t) = a + b*s(t) + u(t) 
%           u(t) ~ N(0,HH)
% 
%=========================================================================

A = zeros(ny,1);
A(eq_ygr,1) = abar;
A(eq_pinf,1) = pibar;
A(eq_rn,1) = rbar;

B = zeros(ny,nstate);
B(eq_ygr,v_y) =  1;
B(eq_ygr,v_ylag) =  -1; 
B(eq_ygr,v_ez) = 1;
B(eq_pinf,v_pi) =  1;
B(eq_rn,v_i) = 1;

H = zeros(ny,ny);  
% with measurement errors (from dsge1_me.yaml)
%H(eq_y, y_t) = (0.20*0.579923)^2;
%H(eq_pi, pi_t) = (0.20*1.470832)^2;
%H(eq_ffr, R_t) = (0.20*2.237937)^2;
end

