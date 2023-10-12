function [A,B,H,R,Se,Phi, PD] = sysmat(T1,T0,para)

% This function computes the matrices of the state space representation.
% Input = para : Vector of Structural Parameters
%         T1 T0: 
% Output= Matrices of state space model. See kalman.m

immigration_rate = para(1); 
pop_growth_rate = para(2);
base_ind_productivity = para(3);
base_agr_productivity = para(4);
base_healthcare_efficiency = para(5);
ind_growth_per_pop = para(6);
res_per_ind = para(7);
tech_decay_rate = para(8);
ind_decay_rate = para(9);
agr_decay_rate = para(10);
food_decay_rate = para(11);
ind_pollution_factor = para(12);
agr_pollution_factor = para(13);
pop_starve_rate = para(14);
constant_tech_need = para(15);
agr_prod_from_tech = para(16);
ind_prod_from_tech = para(17);
hc_eff_from_tech = para(18);
res_scarcity_factor = para(19);
ind_output_PP_factor = para(20);
sigma_pop = para(21);
sigma_agr_need = para(22);
sigma_ind_need = para(23);
sigma_serve_need = para(24);
sigma_ind_output = para(25);
sigma_agr_output = para(26);
sigma_infl = para(27);
sigma_res = para(28);
sigma_food = para(29);
sigma_tech = para(30);
sigma_agr_eff = para(31);
sigma_ind = para(32);
sigma_agr = para(33);
pop_init = para(34);
tech_init = para(35);
tech_infra_init = para(36);
ind_init = para(37);
agr_init = para(38);
food_init = para(39);
env_init = para(40);
res_init = para(41);

% /** observation indices **/
eq_pop  = 1;
eq_pop_alloc_to_agr = 2;
eq_pop_alloc_to_ind  = 3;
eq_pop_alloc_to_tech  = 4;
eq_ind_output = 5;
eq_infl = 6;
eq_unemployment = 7;
eq_res = 8;
eq_food = 9;
eq_agr_output = 10;
eq_agr_prod = 11;
eq_ind_prod = 12;

% /** number of observation variables **/
ny = 12;

% /** model variable indices **/
v_pop_alloc_to_ind=1;
v_pop_alloc_to_agr=2;
v_pop_alloc_to_tech=3;
v_ind_output=4;
v_agr_output=5;
v_ind_growth_need=6;
v_agr_growth_need=7;
v_services_need=8;
v_tech_growth_need=9;
v_ind_to_ind_growth=10;
v_ind_to_services=11;
v_ind_to_agr_growth=12;
v_ind_to_tech_growth=13;
v_agr_efficiency=14;
v_env_loss_from_ind=15;
v_env_loss_from_agr=16;
v_natural_env_growth=17;
v_starvation=18;
v_unemployment=19;
v_tech_infrastructure=20;
v_tech=21;
v_pop=22;
v_ind=23;
v_agr=24;
v_food=25;
v_res=26;
v_env=27;
v_infl=28;
v_agr_prod=29;
v_ind_prod=30;

% /** shock indices **/
e_pop = 1;
e_agr_need = 2;
e_ind_need = 3;
e_serve_need = 4;
e_ind_output = 5;
e_agr_output = 6;
e_infl = 7;
e_res = 8;
e_food = 9;
e_tech = 10;
e_agr_eff = 11;
e_ind = 12;
e_agr = 13;


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
QQ(e_pop,e_pop) = (sigma_pop)^2;
QQ(e_agr_need,e_agr_need) = (sigma_agr_need)^2;
QQ(e_ind_need,e_ind_need) = (sigma_ind_need)^2;
QQ(e_serve_need,e_serve_need) = (sigma_serve_need)^2;
QQ(e_ind_output,e_ind_output) = (sigma_ind_output)^2;
QQ(e_agr_output,e_agr_output) = (sigma_agr_output)^2;
QQ(e_infl,e_infl) = (sigma_infl)^2;
QQ(e_res,e_res) = (sigma_res)^2;
QQ(e_food,e_food) = (sigma_food)^2;
QQ(e_tech,e_tech) = (sigma_tech)^2;
QQ(e_agr_eff,e_agr_eff) = (sigma_agr_eff)^2;
QQ(e_ind,e_ind) = (sigma_ind)^2;
QQ(e_agr,e_agr) = (sigma_agr)^2;

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

B = zeros(ny,nstate);
B(eq_pop,v_pop) =  2000;
B(eq_pop_alloc_to_agr,v_pop_alloc_to_agr) =  1000; 
B(eq_pop_alloc_to_ind,v_pop_alloc_to_ind) = 1000;
B(eq_pop_alloc_to_tech,v_pop_alloc_to_tech) =  1000;
B(eq_ind_output,v_ind_output) = 1/100;
B(eq_infl,v_infl) = 1;
B(eq_unemployment,v_unemployment) = 1000;
B(eq_res,v_res) = 1;
B(eq_food,v_food) = 10^6;
B(eq_agr_output,v_agr_output) = 10^6;
B(eq_agr_prod,v_agr_prod) = 1;
B(eq_ind_prod,v_ind_prod) = 1;

H = zeros(ny,ny);  
% with measurement errors (from dsge1_me.yaml)
%H(eq_y, y_t) = (0.20*0.579923)^2;
%H(eq_pi, pi_t) = (0.20*1.470832)^2;
%H(eq_ffr, R_t) = (0.20*2.237937)^2;
end

