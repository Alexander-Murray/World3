function [T1, TC, T0, TETA, GEV, RC] = model_solution(para)

%=========================================================================
%                     Paramaters
%=========================================================================

h       = para(1);
xip     = para(2);
psipi   = para(3);
psiy    = para(4);
psidy   = para(5);
psir_1  = para(6);
psir_2  = para(7);
abar    = para(8);
pibar   = para(9);
rbar    = para(10);
rhob    = para(11);
rhoz    = para(12);
rhor    = para(13);
sigmab  = para(14);
sigmaz  = para(15);
sigmai  = para(16);
sigmas =  para(17);
alphaBN = para(18);
M_b     = para(19);
M_z     = para(20);
M_i     = para(21);
rho_pi  = para(22);
sigma_pi= para(23);
M_p     = para(24);


% fixed parameters
eta     = 1;
epsilon = 9;

%/** additional parameters **/
ass  = 1+abar/100;
piss = 1+pibar/100;
rss  = 1+rbar/100;

beta = piss*ass/rss;


%/** equation indices **/
eq_euler = 1;  %/** IS equation **/
eq_nkpc  = 2;  %/** NKPC with trend inflation **/
eq_psi   = 3;  %/** Additional term for NKPC **/
eq_vp    = 4;  %/** Price dispersion **/
eq_mp    = 5;  %/** Monetary policy rule **/
eq_yf    = 6;  %/** Flexible price output **/
eq_gap   = 7;  %/** Output gap **/
eq_eb    = 8;  %/** Demand shock process **/
eq_ez    = 9;  %/** Technology shock process **/
eq_ei    = 10;  %/** Monetary policy shock process **/
eq_Ey    = 11; %/** E[y] **/
eq_Epi   = 12; %/** E[pi] **/
eq_Epsi  = 13; %/** E[psi] **/
eq_ylag  = 14; %/** y_{t-1}=y_{t-1} **/
eq_omg   = 15;
eq_ilag  = 16;
eq_pitar = 17;

%/** variable indices **/
v_y     = 1;
v_pi    = 2;
v_psi   = 3;
v_vp    = 4;
v_i     = 5;
v_yf    = 6;  %/** Flexible price output **/
v_gap   = 7;  %/** Output gap **/
v_eb    = 8;
v_ez    = 9;
v_ei    = 10;
v_Ey    = 11;
v_Epi   = 12;
v_Epsi  = 13;
v_ylag  = 14;
v_omg   = 15;
v_ilag  = 16;
v_pitar = 17;

%/** shock indices **/
e_b     = 1;
e_z     = 2;
e_i     = 3;
e_s     = 4;
e_p     = 5;

%/** expectation error indices **/
n_y     = 1;
n_pi    = 2;
n_psi   = 3;

%/** summary **/
neq  = 17;
neps = 5;
neta = 3;

%/** initialize matrices **/
GAM0 = zeros(neq,neq);
GAM1 = zeros(neq,neq);
C    = zeros(neq,1);
PSI  = zeros(neq,neps);
PPI  = zeros(neq,neta);


%=========================================================================
%                EQUILIBRIUM CONDITIONS: CANONICAL SYSTEM
%=========================================================================

%/**********************************************************
%**  1. IS Equation
%**********************************************************/
GAM0(eq_euler,v_y)    = ass+h;
GAM0(eq_euler,v_Ey)   = -ass;
GAM0(eq_euler,v_i)    = ass-h;
GAM0(eq_euler,v_Epi)  = -(ass-h);
GAM0(eq_euler,v_ez)   = (h-ass*rhoz);
GAM0(eq_euler,v_eb)   = -(ass-h)*(1-rhob);
GAM1(eq_euler,v_y)    = h;

%/**********************************************************
%**  2. New Keynesian Phillips Curve with Trend Inflation
%**********************************************************/
GAM0(eq_nkpc,v_pi)  = 1;
GAM0(eq_nkpc,v_Epi) = -beta*(1+epsilon*(1-xip*piss^(epsilon-1))*(piss-1)); 
GAM0(eq_nkpc,v_y)   = -(((1-xip*piss^(epsilon-1))*(1-beta*xip*piss^(epsilon)))/(xip*piss^(epsilon-1)))*(1+eta)-(((1-beta*xip*piss^(epsilon-1))*(1-xip*piss^(epsilon-1)))/(xip*piss^(epsilon-1)))*(h/(ass-h)); 
GAM0(eq_nkpc,v_vp)  = -(((1-xip*piss^(epsilon-1))*(1-beta*xip*piss^(epsilon)))/(xip*piss^(epsilon-1)))*(eta);
GAM0(eq_nkpc,v_ez)  = -(((1-xip*piss^(epsilon-1))*(1-beta*xip*piss^(epsilon-1)))/(xip*piss^(epsilon-1)))*((h)/(ass-h));
GAM0(eq_nkpc,v_Epsi)= -beta*(1-xip*piss^(epsilon-1))*(piss-1); 
GAM0(eq_nkpc,v_eb)  = -beta*(1-piss)*(1-xip*piss^(epsilon-1));
GAM1(eq_nkpc,v_y)   = -(((1-xip*piss^(epsilon-1))*(1-beta*xip*piss^(epsilon-1)))/(xip*piss^(epsilon-1)))*((h)/(ass-h));


%/**********************************************************
%**      3. Additional term for NKPC
%**********************************************************/
GAM0(eq_psi,v_psi)   = 1;
GAM0(eq_psi,v_eb)    = -(1-beta*xip*piss^(epsilon));
GAM0(eq_psi,v_y)     = -(1-beta*xip*piss^(epsilon))*(1+eta); 
GAM0(eq_psi,v_vp)    = -(1-beta*xip*piss^(epsilon))*eta;
GAM0(eq_psi,v_Epsi)  = -beta*xip*piss^(epsilon);
GAM0(eq_psi,v_Epi)   = -beta*xip*piss^(epsilon)*epsilon;

%/**********************************************************
%**      4. Price dispersion
%**********************************************************/
GAM0(eq_vp,v_vp)  = 1;
GAM0(eq_vp,v_pi)  = -((epsilon*xip*(piss)^(epsilon-1))*(piss-1))/(1-xip*(piss)^(epsilon-1));
GAM1(eq_vp,v_vp)  = (piss)^(epsilon)*xip; 

%/**********************************************************
%**      5. Monetary policy rule with time-varying target
%**********************************************************/
GAM0(eq_mp,v_i)     =  1;
GAM0(eq_mp,v_pi)    = -(1-psir_1-psir_2)*psipi;
GAM0(eq_mp,v_pitar) = (1-psir_1-psir_2)*psipi;
GAM0(eq_mp,v_gap)   = -(1-psir_1-psir_2)*psiy;
GAM0(eq_mp,v_y)     = -(1-psir_1-psir_2)*psidy;
GAM0(eq_mp,v_ez)    = -(1-psir_1-psir_2)*psidy;
GAM0(eq_mp,v_ei)    = -1;
GAM1(eq_mp,v_y)     = -(1-psir_1-psir_2)*psidy;
GAM1(eq_mp,v_i)     = psir_1;
GAM1(eq_mp,v_ilag)  = psir_2;


%/**********************************************************
%**      6. Flexible price equilibrium output
%**********************************************************/
GAM0(eq_yf,v_yf)    =  1;
GAM0(eq_yf,v_ez)    = h/(ass*(1+eta)-eta*h);
GAM1(eq_yf,v_yf)    = h/(ass*(1+eta)-eta*h);

%/**********************************************************
%**      7. Output gap
%**********************************************************/
GAM0(eq_gap,v_gap)    =  1;
GAM0(eq_gap,v_y)      =  -1;
GAM0(eq_gap,v_yf)     =  1;


%/**********************************************************
%**      8-10. Shock process
%**********************************************************/
%/** eb **/
GAM0(eq_eb,v_eb) = 1;
GAM1(eq_eb,v_eb) = rhob;
PSI(eq_eb,e_b)   = 1;
%/** ez **/
GAM0(eq_ez,v_ez) = 1;
GAM1(eq_ez,v_ez) = rhoz;
PSI(eq_ez,e_z)   = 1;
%/** ei **/
GAM0(eq_ei,v_ei) = 1;
GAM1(eq_ei,v_ei) = rhor;
PSI(eq_ei,e_i)   = 1;

%/** ei **/
GAM0(eq_pitar,v_pitar) = 1;
GAM1(eq_pitar,v_pitar) = rho_pi;
PSI(eq_pitar,e_p)      = 1;

%/**********************************************************
%**      11-13. Expectation error
%**********************************************************/
%/** E(y) **/
GAM0(eq_Ey,v_y)  = 1;
GAM1(eq_Ey,v_Ey) = 1;
PPI(eq_Ey,n_y)   = 1;
%/** E(pi) **/
GAM0(eq_Epi,v_pi)  = 1;
GAM1(eq_Epi,v_Epi) = 1;
PPI(eq_Epi,n_pi)   = 1;
%/** E(psi) **/
GAM0(eq_Epsi,v_psi)  = 1;
GAM1(eq_Epsi,v_Epsi) = 1;
PPI(eq_Epsi,n_psi)   = 1;

%/**********************************************************
%**     14.  Auxiliary equation for y_{t-1}
%**********************************************************/
%/** y_{t-1} **/
GAM0(eq_ylag,v_ylag)  = 1;
GAM1(eq_ylag,v_y)     = 1;

%/**********************************************************
%**     15.  Bianchi and Nicolo equation
%**********************************************************/
%/ omega = (1/alphaBN)omega(-1) 
GAM0(eq_omg,v_omg)  = 1;
GAM1(eq_omg,v_omg)  = (1/alphaBN);
PSI(eq_omg,e_s)     = 1;
PPI(eq_omg,n_pi)    = -1;

%/**********************************************************
%**     16.  Lag of nominal rate
%**********************************************************/
GAM0(eq_ilag, v_ilag) = 1;
GAM1(eq_ilag, v_i)    = 1;

[T1,TC,T0,TY,M,TZ,TETA,GEV] = gensys(GAM0,GAM1,C,PSI,PPI,1+1E-8);
end