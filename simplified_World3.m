clear all;
close all;
clc;

import casadi.* 
 T=160;

%% Variables:
pop_alloc_to_ind=SX.sym('pop. alloc. to ind.',[T,1]);
pop_alloc_to_agr=SX.sym('pop. alloc. to agr.',[T,1]);
pop_alloc_to_tech=SX.sym('pop. alloc. to tech.',[T,1]);
ind_output=SX.sym('ind. output',[T,1]);
agr_output=SX.sym('agr. output',[T,1]);
ind_growth_need=SX.sym('ind. growth need',[T,1]);
agr_growth_need=SX.sym('agr. growth need',[T,1]);
services_need=SX.sym('services need',[T,1]);
tech_growth_need=SX.sym('tech growth need',[T,1]);
ind_to_ind_growth=SX.sym('ind. to ind. growth',[T,1]);
ind_to_services=SX.sym('ind. to services',[T,1]);
ind_to_agr_growth=SX.sym('ind. to agr. growth',[T,1]);
ind_to_tech_growth=SX.sym('ind. to tech. growth',[T,1]);
agr_efficiency=SX.sym('agr. efficiency',[T,1]);
env_loss_from_ind=SX.sym('env. loss from ind.',[T,1]);
env_loss_from_agr=SX.sym('env. loss from agr.',[T,1]);
natural_env_growth=SX.sym('nat. env. growth',[T,1]);
starvation=SX.sym('starvation',[T,1]);
unemployment = SX.sym('unemp.',[T,1]);
tech_infrastructure=SX.sym('tech. infrastructure',[T+1,1]);
tech=SX.sym('tech',[T+1,1]);
pop=SX.sym('pop.',[T+1,1]);
ind=SX.sym('ind.',[T+1,1]);
agr=SX.sym('agr.',[T+1,1]);
food=SX.sym('food',[T+1,1]);
res=SX.sym('res.',[T+1,1]);
env=SX.sym('env.',[T+1,1]);
infl = SX.sym('infl.',[T,1]);
agr_productivity = SX.sym('agr_productivity',[T,1]);
ind_productivity = SX.sym('ind_productivity',[T,1]);
immigration = SX.sym('immigration',[T,1]);

% pop_shk = SX.sym('pop_shk',[T,1]);
% agr_growth_need_shk = SX.sym('agr_growth_need_shk',[T,1]);
% ind_growth_need_shk = SX.sym('ind_growth_need_shk',[T,1]);
% services_need_shk = SX.sym('services_need_shk',[T,1]);
% ind_output_shk = SX.sym('ind_output_shk',[T,1]);
% agr_output_shk = SX.sym('agr_output_shk',[T,1]);
% infl_shk = SX.sym('infl_shk',[T,1]);
% res_shk = SX.sym('res_shk',[T,1]);
% food_shk = SX.sym('food_shk',[T,1]);
% tech_shk = SX.sym('tech_shk',[T,1]);
% agr_efficiency_shk = SX.sym('agr_efficiency_shk',[T,1]);
% ind_shk = SX.sym('ind_shk',[T,1]);
% agr_shk = SX.sym('agr_shk',[T,1]);

pop_shk = zeros(T,1);
agr_growth_need_shk = zeros(T,1);
ind_growth_need_shk = zeros(T,1);
services_need_shk = zeros(T,1);
ind_output_shk = zeros(T,1);
agr_output_shk = zeros(T,1);
infl_shk = zeros(T,1);
res_shk = zeros(T,1);
food_shk = zeros(T,1);
tech_shk = zeros(T,1);
agr_efficiency_shk = zeros(T,1);
ind_shk = zeros(T,1);
agr_shk = zeros(T,1);

 %% Definitions:
% immigration_rate = 0.01; 
pop_growth_rate = 0.001;
base_ind_productivity = 0.6741;
base_agr_productivity = 5.8573;
base_healthcare_efficiency = 0;
ind_growth_per_pop = 0.01;
res_per_ind = 0.02;
tech_decay_rate = 0.01;
ind_decay_rate = 0.01;
agr_decay_rate = 0.02;
food_decay_rate = 0.1;
ind_pollution_factor = 0.02;
agr_pollution_factor = 0.002;
pop_starve_rate = 0.5;
constant_tech_need = 1;
agr_prod_from_tech = 0.1;
ind_prod_from_tech = 0.1;
hc_eff_from_tech = 0.001;
res_scarcity_factor = 0.0001;
ind_output_PP_factor = 0.0001;
ind_productivity_factor = 1.5636;
agr_productivity_factor = 5.2144*2;
food_consumption_rate = 2;
immigration_perGDP = 0.0376/4;

%% Initial conditions
pop(1) = 10.9576;
tech(1) = 0;
tech_infrastructure(1) = 7.6036;
ind(1) = 2.9145;
agr(1) = 0.4376;
food(1) = 69.16;
env(1) = 100;
res(1) = 926.606;

 %% Dynamics:

 disp('Simulating...')
 for t = 1:T 
    pop_alloc_to_ind(t) = min(pop(t)*ind(t)/(ind(t)+agr(t)+tech_infrastructure(t)),ind(t));
    pop_alloc_to_agr(t) = min(pop(t)*agr(t)/(ind(t)+agr(t)+tech_infrastructure(t)),agr(t));
    pop_alloc_to_tech(t) = min(pop(t)*tech_infrastructure(t)/(ind(t)+agr(t)+tech_infrastructure(t)),tech_infrastructure(t));
    tech(t+1) = tech_shk(t) + tech(t) + pop_alloc_to_tech(t);
    unemployment(t) = pop(t)-pop_alloc_to_ind(t)-pop_alloc_to_agr(t)-pop_alloc_to_tech(t);
    ind_productivity(t) = base_ind_productivity + ind_prod_from_tech*tech(t);
    ind_output(t) =  ind_output_shk(t) + (2/(1+exp(-10*res(t)))-1)*pop_alloc_to_ind(t)*(ind_productivity_factor*ind_productivity(t)); %res close to 0 => ind_output ~= 0
    agr_productivity(t) = base_agr_productivity + agr_prod_from_tech*tech(t);
    agr_output(t) = agr_output_shk(t) + pop_alloc_to_agr(t)*(agr_productivity_factor*agr_productivity(t));
    ind_growth_need(t) = ind_growth_need_shk(t) + res(t)*(1/(1+exp(-20*(pop_alloc_to_ind(t)-ind(t)))))/res(1);  %pop_alloc_to_ind>=ind or res=0 => ind_growth_need ~= 0
    agr_growth_need(t) = agr_growth_need_shk(t) + (1/(1+exp(-20*(pop_alloc_to_agr(t)-agr(t))))) + (1/(1+exp(-20*(2*pop(t)-food(t)))));  %pop_alloc_to_agr>=agr or food<pop => agr_growth_need ~= 0
    services_need(t) = services_need_shk(t) + pop(t)/100;
    tech_growth_need(t) = constant_tech_need;
    all_needs = ind_growth_need(t)+agr_growth_need(t)+services_need(t)+tech_growth_need(t);
    ind_to_ind_growth(t) = ind_output(t)*ind_growth_need(t)/all_needs + pop(t)*ind_growth_per_pop*ind_growth_need(t);
    ind_to_services(t) = ind_output(t)*services_need(t)/all_needs;
    ind_to_agr_growth(t) = ind_output(t)*agr_growth_need(t)/all_needs;
    ind_to_tech_growth(t) = ind_output(t)*tech_growth_need(t)/all_needs;
    tech_infrastructure(t+1) = tech_infrastructure(t)*(1-tech_decay_rate) + ind_to_tech_growth(t);
    infl(t) = infl_shk(t) + res_scarcity_factor*(res(1) - res(t)) + ind_output_PP_factor*ind_output(t)/pop(t);
    
    agr_efficiency(t) = agr_efficiency_shk(t) + env(t)/100; % combines factors such as soil degradation and climate change (wetter springs and dryer summers reduce efficiency)
    env_loss_from_ind(t) = ind_output(t)*ind_pollution_factor;
    env_loss_from_agr(t) = agr_output(t)*agr_pollution_factor;
    natural_env_growth(t) = 100/(env(t)+100) - 0.5;
    starvation(t) = max((-food(t)+pop(t)-agr_output(t)*agr_efficiency(t))*pop_starve_rate,0); 
    immigration(t) = (immigration_perGDP*ind_output(t)/pop(t));
    pop(t+1) = pop_shk(t) + pop(t)*(1 + pop_growth_rate + immigration(t)) - starvation(t) + ind_to_services(t)*(base_healthcare_efficiency + hc_eff_from_tech*tech(t));
    ind(t+1) = ind_shk(t) + ind(t)*(1 - ind_decay_rate) + ind_to_ind_growth(t);
    agr(t+1) = agr_shk(t) + agr(t)*(1 - agr_decay_rate) + ind_to_agr_growth(t);
    food(t+1) = food_shk(t) + food(t)*(1- food_decay_rate) + agr_output(t)*agr_efficiency(t) - food_consumption_rate*pop(t);
    res(t+1) = res_shk(t) + res(t) - ind_output(t)*res_per_ind;
    env(t+1) = env(t) - env_loss_from_ind(t) - env_loss_from_agr(t) + natural_env_growth(t);
 end 
disp('Done!')



%% create plots
figure(1)
hold on
tt=1:T;
plot(tt,full(evalf(pop(tt))),'m')
plot(tt,full(evalf(ind(tt))),'b')
plot(tt,full(evalf(agr(tt))),'r')
plot(tt,full(evalf(res(tt))/100),'y')
plot(tt,full(evalf(env(tt))),'g')
legend('population','industry','agriculture','resources','environment')
xticks(0:10:T)
xticklabels({'1981','1991','2001','2011','2020'})
hold off