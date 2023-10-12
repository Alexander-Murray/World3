function [T1, TC, T0, TETA, GEV, RC] = model_solution(para)

%=========================================================================
%                     Paramaters
%=========================================================================

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
starvation_rate = para(14);
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


%/** equation indices **/
eq_pop_alloc_to_ind=1;
eq_pop_alloc_to_agr=2;
eq_pop_alloc_to_tech=3;
eq_tech=4;
eq_unemployment=5;
eq_ind_productivity=6;
eq_ind_output=7;
eq_agr_productivity=8;
eq_agr_output=9;
eq_ind_growth_need=10;
eq_agr_growth_need=11;
eq_services_need=12;
eq_tech_growth_need=13;
eq_ind_to_ind_growth=14;
eq_ind_to_services=15;
eq_ind_to_agr_growth=16;
eq_ind_to_tech_growth=17;
eq_tech_infrastructure=18;
eq_infl=19;
eq_agr_efficiency=20;
eq_env_loss_from_ind=21;
eq_env_loss_from_agr=22;
eq_natural_env_growth=23;
eq_starvation=24;
eq_pop=25;
eq_ind=26;
eq_agr=27;
eq_food=28;
eq_res=29;
eq_env=30;
eq_tech_lag = 31;
eq_tech_infrastructure_lag = 32;
eq_pop_lag = 33;
eq_food_lag = 34;
eq_ind_lag = 35;
eq_agr_lag = 36;
eq_env_lag = 37;
eq_res_lag = 38;

%/** variable indices **/
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
v_agr_productivity=29;
v_ind_productivity=30;
v_tech_lag = 31;
v_tech_infrastructure_lag = 32;
v_pop_lag = 33;
v_food_lag = 34;
v_ind_lag = 35;
v_agr_lag = 36;
v_env_lag = 37;
v_res_lag = 38;

%/** shock indices **/
e_pop = 1;
e_agr_growth_need = 2;
e_ind_growth_need = 3;
e_services_need = 4;
e_ind_output = 5;
e_agr_output = 6;
e_infl = 7;
e_res = 8;
e_food = 9;
e_tech = 10;
e_agr_efficiency = 11;
e_ind = 12;
e_agr = 13;

%/** expectation error indices **/


%/** summary **/
neq  = 38;
neps = 13;
neta = 0;

%/** initialize matrices **/
GAM0 = zeros(neq,neq);
GAM1 = zeros(neq,neq);
C    = zeros(neq,1);
PSI  = zeros(neq,neps);
PPI  = zeros(neq,neta);


%=========================================================================
%                SYSTEM OF EQUATIONS
%=========================================================================

%/**********************************************************
%**  1.
%**********************************************************/
GAM0(eq_pop_alloc_to_ind,v_pop_alloc_to_ind)    = 1;
GAM1(eq_pop_alloc_to_ind,v_pop)   = -ind_init/(ind_init+agr_init+tech_infra_init);
GAM1(eq_pop_alloc_to_ind,v_ind)  = -pop_init/(ind_init+agr_init+tech_infra_init) - pop_init*ind_init/(ind_init+agr_init+tech_infra_init)^2;
GAM1(eq_pop_alloc_to_ind,v_agr)  = -(1/(ind_init+agr_init+tech_infra_init) - pop_init*ind_init/(ind_init+agr_init+tech_infra_init)^2);
GAM1(eq_pop_alloc_to_ind,v_tech_infrastructure)   = -(1/(ind_init+agr_init+tech_infra_init) - pop_init*ind_init/(ind_init+agr_init+tech_infra_init)^2);

%/**********************************************************
%**  2. 
%**********************************************************/
GAM0(eq_pop_alloc_to_agr,v_pop_alloc_to_agr)    = 1;
GAM1(eq_pop_alloc_to_agr,v_pop)   = -agr_init/(ind_init+agr_init+tech_infra_init);
GAM1(eq_pop_alloc_to_agr,v_ind)  = -(1/(ind_init+agr_init+tech_infra_init) - pop_init*agr_init/(ind_init+agr_init+tech_infra_init)^2);
GAM1(eq_pop_alloc_to_agr,v_agr)  = -pop_init/(ind_init+agr_init+tech_infra_init) - pop_init*agr_init/(ind_init+agr_init+tech_infra_init)^2;
GAM1(eq_pop_alloc_to_agr,v_tech_infrastructure)   = -(1/(ind_init+agr_init+tech_infra_init) - pop_init*agr_init/(ind_init+agr_init+tech_infra_init)^2);


%/**********************************************************
%**      3. 
%**********************************************************/
GAM0(eq_pop_alloc_to_tech,v_pop_alloc_to_tech)    = 1;
GAM1(eq_pop_alloc_to_tech,v_pop)   = -tech_infra_init/(ind_init+agr_init+tech_infra_init);
GAM1(eq_pop_alloc_to_tech,v_ind)  = -(1/(ind_init+agr_init+tech_infra_init) - pop_init*tech_infra_init/(ind_init+agr_init+tech_infra_init)^2);
GAM1(eq_pop_alloc_to_tech,v_agr)  = -(1/(ind_init+agr_init+tech_infra_init) - pop_init*tech_infra_init/(ind_init+agr_init+tech_infra_init)^2);
GAM1(eq_pop_alloc_to_tech,v_tech_infrastructure)   = -pop_init/(ind_init+agr_init+tech_infra_init) - pop_init*tech_infra_init/(ind_init+agr_init+tech_infra_init)^2;

%/**********************************************************
%**      4. 
%**********************************************************/
GAM0(eq_tech,v_tech)  = 1;
PSI(eq_tech,e_tech)  = -1;
GAM1(eq_tech,v_tech_lag)  = -1; 
GAM1(eq_tech,v_pop_alloc_to_tech)  = -1; 

%/**********************************************************
%**      5. 
%**********************************************************/
GAM0(eq_unemployment,v_unemployment)     =  1;
GAM1(eq_unemployment,v_pop)    = -1;
GAM1(eq_unemployment,v_pop_alloc_to_ind) = 1;
GAM1(eq_unemployment,v_pop_alloc_to_agr) = 1;
GAM1(eq_unemployment,v_pop_alloc_to_tech) = 1;


%/**********************************************************
%**      6. 
%**********************************************************/
GAM0(eq_ind_productivity,v_ind_productivity)    =  1;
GAM1(eq_ind_productivity,v_tech)    = -ind_prod_from_tech;
C(eq_ind_productivity) = -base_ind_productivity;

%/**********************************************************
%**      7. 
%**********************************************************/
GAM0(eq_ind_output,v_ind_output)    =  1;
PSI(eq_agr_output,e_ind_output)      =  -1;
GAM1(eq_ind_output,v_pop_alloc_to_ind)     =  -base_ind_productivity  - ind_prod_from_tech*tech_init;
GAM1(eq_ind_output,v_ind_productivity)     =  -pop_init*ind_init/(ind_init+agr_init+tech_infra_init);

%/**********************************************************
%**      8
%**********************************************************/
GAM0(eq_agr_productivity,v_agr_productivity)    =  1;
GAM1(eq_agr_productivity,v_tech)    = -agr_prod_from_tech;
C(eq_agr_productivity) = -base_agr_productivity;

%/**********************************************************
%**      9
%**********************************************************/
GAM0(eq_agr_output,v_agr_output)    =  1;
PSI(eq_agr_output,e_agr_output)      =  -1;
GAM1(eq_agr_output,v_pop_alloc_to_agr)     =  -base_agr_productivity - agr_prod_from_tech*tech_init;
GAM1(eq_agr_output,v_agr_productivity)     =  -pop_init*agr_init/(ind_init+agr_init+tech_infra_init);

%/**********************************************************
%**      10
%**********************************************************/
GAM0(eq_ind_growth_need,v_ind_growth_need)    =  1;
PSI(eq_ind_growth_need,e_ind_growth_need)    =  -1;
GAM1(eq_ind_growth_need,v_res)    =  -1/res_init;

%/**********************************************************
%**      11
%**********************************************************/
GAM0(eq_agr_growth_need,v_agr_growth_need)    =  1;
PSI(eq_agr_growth_need,e_agr_growth_need)    =  -1;
GAM1(eq_agr_growth_need,v_food)    =  -1/food_init;

%/**********************************************************
%**      12
%**********************************************************/
GAM0(eq_services_need,v_services_need)    =  1;
PSI(eq_services_need,e_services_need)    =  -1;
GAM1(eq_services_need,v_pop)    =  -1/100;

%/**********************************************************
%**      13
%**********************************************************/
GAM0(eq_tech_growth_need,v_tech_growth_need)    =  1;
C(eq_tech_growth_need)    =  -constant_tech_need;

%/**********************************************************
%**      14
%**********************************************************/
GAM0(eq_ind_to_ind_growth,v_ind_to_ind_growth)    =  1;
GAM1(eq_ind_to_ind_growth,v_ind_output)    = -1/3;
GAM1(eq_ind_to_ind_growth,v_ind_growth_need)    = -ind_init;
GAM1(eq_ind_to_ind_growth,v_pop)    = -ind_growth_per_pop;

%/**********************************************************
%**      15
%**********************************************************/
GAM0(eq_ind_to_services,v_ind_to_services)    =  1;
GAM1(eq_ind_to_services,v_ind_output)    = -1/3;
GAM1(eq_ind_to_services,v_services_need)    = -base_ind_productivity*pop_init*ind_init/(ind_init+agr_init+tech_infra_init);

%/**********************************************************
%**      16
%**********************************************************/
GAM0(eq_ind_to_agr_growth,v_ind_to_agr_growth)    =  1;
GAM1(eq_ind_to_agr_growth,v_ind_output)    = -1/3;
GAM1(eq_ind_to_agr_growth,v_agr_growth_need)    = -base_ind_productivity*pop_init*ind_init/(ind_init+agr_init+tech_infra_init);

%/**********************************************************
%**      17
%**********************************************************/
GAM0(eq_ind_to_tech_growth,v_ind_to_tech_growth)    =  1;
GAM1(eq_ind_to_tech_growth,v_ind_output)    = -1/3;
GAM1(eq_ind_to_tech_growth,v_tech_growth_need)    = -base_ind_productivity*pop_init*ind_init/(ind_init+agr_init+tech_infra_init);

%/**********************************************************
%**      18
%**********************************************************/
GAM0(eq_tech_infrastructure,v_tech_infrastructure)    =  1;
GAM1(eq_tech_infrastructure,v_tech_infrastructure_lag)    = -(1-tech_decay_rate);
GAM1(eq_ind_to_tech_growth,v_ind_to_tech_growth)    = -1;

%/**********************************************************
%**      19
%**********************************************************/
GAM0(eq_infl,v_infl)    =  1;
PSI(eq_infl,e_infl)    =  -1;
GAM1(eq_infl,v_res)    = res_scarcity_factor;
C(eq_infl)    = -res_scarcity_factor*res_init;
GAM1(eq_infl,v_ind_output)    = -ind_output_PP_factor/pop_init;
GAM1(eq_infl,v_pop)    = ind_output_PP_factor*(base_ind_productivity*pop_init*ind_init/(ind_init+agr_init+tech_infra_init))/pop_init^2;

%/**********************************************************
%**      20
%**********************************************************/
GAM0(eq_agr_efficiency,v_agr_efficiency)    =  1;
PSI(eq_agr_efficiency,e_agr_efficiency)    =  -1;
GAM1(eq_agr_efficiency,v_env)    =  -1/100;

%/**********************************************************
%**      21
%**********************************************************/
GAM0(eq_env_loss_from_ind,v_env_loss_from_ind)    =  1;
GAM1(eq_env_loss_from_ind,v_ind_output)    =  -ind_pollution_factor;

%/**********************************************************
%**      22
%**********************************************************/
GAM0(eq_env_loss_from_agr,v_env_loss_from_agr)    =  1;
GAM1(eq_env_loss_from_agr,v_agr_output)    =  -agr_pollution_factor;

%/**********************************************************
%**      23
%**********************************************************/
GAM0(eq_natural_env_growth,v_natural_env_growth)    =  1;
GAM1(eq_natural_env_growth,v_env)    =  100/(env_init+100)^2;
C(eq_natural_env_growth) = 0.5;

%/**********************************************************
%**      24
%**********************************************************/
GAM0(eq_starvation,v_starvation)    =  1;
% GAM0(eq_starvation,v_food)    =  starvation_rate;
% GAM0(eq_starvation,v_pop)    =  -starvation_rate;
% GAM0(eq_starvation,v_agr_output)    =  starvation_rate*env_init/100;
% GAM0(eq_starvation,v_agr_efficiency)    =  starvation_rate*(pop_init*agr_init/(ind_init+agr_init+tech_infra_init))*(base_agr_productivity + agr_prod_from_tech*tech_init);

%/**********************************************************
%**      25
%**********************************************************/
GAM0(eq_pop,v_pop)    =  1;
PSI(eq_pop,e_pop)    =  -1;
GAM1(eq_pop,v_pop_lag)    =  -1-pop_growth_rate-immigration_rate;
GAM1(eq_pop,v_starvation)    =  1;
GAM1(eq_pop,v_ind_to_services)    =  -base_healthcare_efficiency - hc_eff_from_tech*tech_init;
GAM1(eq_pop,v_tech)    =  - hc_eff_from_tech*(1/3)*base_ind_productivity*pop_init*ind_init/(ind_init+agr_init+tech_infra_init);

%/**********************************************************
%**      26
%**********************************************************/
GAM0(eq_ind,v_ind)    =  1;
PSI(eq_ind,e_ind)    =  -1;
GAM1(eq_ind,v_ind_lag)    =  -(1 - ind_decay_rate);
GAM1(eq_ind,v_ind_to_ind_growth)    =  -1;

%/**********************************************************
%**      27
%**********************************************************/
GAM0(eq_agr,v_agr)    =  1;
PSI(eq_agr,e_agr)    =  -1;
GAM1(eq_agr,v_agr_lag)    =  -(1 - agr_decay_rate);
GAM1(eq_agr,v_ind_to_agr_growth)    =  -1;

%/**********************************************************
%**      28
%**********************************************************/
GAM0(eq_food,v_food)    =  1;
PSI(eq_food,e_food)    =  -1;
GAM1(eq_food,v_food_lag)    =  -(1 - food_decay_rate);
GAM1(eq_food,v_agr_output)    =  -env_init/100;
GAM1(eq_food,v_agr_efficiency)    =  -(pop_init*agr_init/(ind_init+agr_init+tech_infra_init))*(base_agr_productivity + agr_prod_from_tech*tech_init);
GAM1(eq_food,v_pop)    =  1;

%/**********************************************************
%**      29
%**********************************************************/
GAM0(eq_res,v_res)    =  1;
PSI(eq_res,e_res)    =  -1;
GAM1(eq_res,v_res_lag)    =  -1;
GAM1(eq_res,v_ind_output)    =  -res_per_ind;

%/**********************************************************
%**      30
%**********************************************************/
GAM0(eq_env,v_env)    =  1;
GAMGAM10(eq_env,v_env_lag)    =  -1;
GAM1(eq_env,v_env_loss_from_ind)    =  1;
GAM1(eq_env,v_env_loss_from_agr)    =  1;
GAM1(eq_env,v_natural_env_growth)    =  -1;

%/**********************************************************
%**     31.  Auxiliary equation
%**********************************************************/
GAM0(eq_tech_lag,v_tech_lag)  = 1;
GAM1(eq_tech_lag,v_tech)     = 1;

%/**********************************************************
%**     32.  Auxiliary equation
%**********************************************************/
GAM0(eq_tech_infrastructure_lag,v_tech_infrastructure_lag)  = 1;
GAM1(eq_tech_infrastructure_lag,v_tech_infrastructure)     = 1;

%/**********************************************************
%**     33.  Auxiliary equation
%**********************************************************/
GAM0(eq_pop_lag,v_pop_lag)  = 1;
GAM1(eq_pop_lag,v_pop)     = 1;

%/**********************************************************
%**     34.  Auxiliary equation
%**********************************************************/
GAM0(eq_food_lag,v_food_lag)  = 1;
GAM1(eq_food_lag,v_food)     = 1;

%/**********************************************************
%**     35.  Auxiliary equation
%**********************************************************/
GAM0(eq_ind_lag,v_ind_lag)  = 1;
GAM1(eq_ind_lag,v_ind)     = 1;

%/**********************************************************
%**     36.  Auxiliary equation
%**********************************************************/
GAM0(eq_agr_lag,v_agr_lag)  = 1;
GAM1(eq_agr_lag,v_agr)     = 1;

%/**********************************************************
%**     37.  Auxiliary equation
%**********************************************************/
GAM0(eq_env_lag,v_env_lag)  = 1;
GAM1(eq_env_lag,v_env)     = 1;

%/**********************************************************
%**     38.  Auxiliary equation
%**********************************************************/
GAM0(eq_res_lag,v_res_lag)  = 1;
GAM1(eq_res_lag,v_res)     = 1;


[T1,TC,T0,TY,M,TZ,TETA,GEV] = gensys(GAM0,GAM1,C,PSI,PPI,1+1E-8);
end