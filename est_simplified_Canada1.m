clear all;
close all;
clc;

addpath(genpath('/home/mrra/CasADi_v3.5.5_linux'));
import casadi.* 

 
%% data
raw_data = readtable('Estimation/Canada1_estimationData.csv');
data = table2array(raw_data(1:end,2:end)); % exclude timestamp column
% data = data(1:10,:); % for testing purposes only
T=size(data,1);
% normalize data:
data(:,2) =  data(:,2)./1000; %pop_alloc_to_agr
data(:,3) =  data(:,3)./1000; %pop_alloc_to_ind
data(:,4) =  data(:,4)./1000; %pop_alloc_to_tech
data(:,5) =  data(:,5)./100; %ind_output
data(:,6) =  data(:,6); %infl
data(:,7) =  data(:,7)./1000; %unemployment
data(:,8) =  data(:,8).*1000; %res
data(:,9) =  data(:,9)./10^5; %food
data(:,10) =  data(:,10)./(2*10^5); %agr_output
data(:,11) =  data(:,11).*1; %agr_productivity
data(:,12) =  data(:,12)./100; %ind_productivity
data(:,1) =  data(:,1).*(data(1,2)+data(1,3)+data(1,4)+data(1,7))./data(1,1);%pop % Calibrated so that pop(1) = pop_alloc_to_ind(1) + pop_alloc_to_agr(1) + pop_alloc_to_tech(1) + unemployment(1)

% create a version of the data where a very basic constant imputation is used 
%(a more advanced imputation method shouldn't make a difference since this is just used for initial guesses and so a rough estimate is fine)
non_nan_data = fill_nan_vals(data);

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

pop_shk = SX.sym('pop_shk',[T,1]);
agr_growth_need_shk = SX.sym('agr_growth_need_shk',[T,1]);
ind_growth_need_shk = SX.sym('ind_growth_need_shk',[T,1]);
services_need_shk = SX.sym('services_need_shk',[T,1]);
ind_output_shk = SX.sym('ind_output_shk',[T,1]);
agr_output_shk = SX.sym('agr_output_shk',[T,1]);
infl_shk = SX.sym('infl_shk',[T,1]);
res_shk = SX.sym('res_shk',[T,1]);
food_shk = SX.sym('food_shk',[T,1]);
tech_shk = SX.sym('tech_shk',[T,1]);
agr_efficiency_shk = SX.sym('agr_efficiency_shk',[T,1]);
ind_shk = SX.sym('ind_shk',[T,1]);
agr_shk = SX.sym('agr_shk',[T,1]);
tech_infrastructure_shk = SX.sym('tech_infrastructure_shk',[T,1]);

%%
 max_lag = 1;
 
%% set up vars for estimation
for t = 1+max_lag:T
obs_vars{t-max_lag} =[
    pop(t); %1 
    pop_alloc_to_agr(t); %2
    pop_alloc_to_ind(t); %3
    pop_alloc_to_tech(t); %4
    ind_output(t); %5
    infl(t); %6
    unemployment(t); %7
    res(t); %8
    food(t); %9
    agr_output(t); %10
    agr_productivity(t); %11
    ind_productivity(t); %12
];

state_vars{t-max_lag} = [
    ind_growth_need(t); %13
    agr_growth_need(t); %14
    services_need(t); %15
    tech_growth_need(t); %16
    ind_to_ind_growth(t); %17
    ind_to_services(t); %18
    ind_to_agr_growth(t); %19
    ind_to_tech_growth(t); %20
    agr_efficiency(t); %21
    env_loss_from_ind(t); %22
    env_loss_from_agr(t); %23
    natural_env_growth(t); %24
    starvation(t); %25
    tech_infrastructure(t); %26
    tech(t); %27
    ind(t); %28
    agr(t); %29
    env(t); %30
    immigration(t); %31
];

shocks{t-max_lag}=[
    pop_shk(t) ;
    agr_growth_need_shk(t) ;
    ind_growth_need_shk(t) ;
    services_need_shk(t) ;
    ind_output_shk(t) ;
    agr_output_shk(t) ;
    infl_shk(t) ;
    res_shk(t) ;
    food_shk(t) ;
    tech_shk(t) ;
    agr_efficiency_shk(t) ;
    ind_shk(t) ;
    agr_shk(t) ;
    tech_infrastructure_shk(t);
];
end
% other_vars=[tech(T+1);tech_infrastructure(T+1);pop(T+1);ind(T+1);agr(T+1);food(T+1);res(T+1);env(T+1)];

states_init_guess = [ones(9,1);zeros(4,1);non_nan_data(1,4);0;non_nan_data(1,3);non_nan_data(1,2);100;0.01]; 
if length(states_init_guess)~=length(state_vars{1})
   error("must provide an initial guess for each state variable") 
end

n_obs = length(obs_vars{1});
n_states = length(state_vars{1});
n_shocks = length(shocks{1});

 %% params:
% immigration_rate=SX.sym('immigration_rate',[1,1]);
pop_growth_rate=SX.sym('pop_growth_rate',[1,1]);
base_ind_productivity=SX.sym('base_ind_productivity',[1,1]);
base_agr_productivity=SX.sym('base_agr_productivity',[1,1]);
base_healthcare_efficiency=SX.sym('base_healthcare_efficiency',[1,1]);
ind_growth_per_pop=SX.sym('ind_growth_per_pop',[1,1]);
res_per_ind=SX.sym('res_per_ind',[1,1]);
tech_decay_rate=SX.sym('tech_decay_rate',[1,1]);
ind_decay_rate=SX.sym('ind_decay_rate',[1,1]);
agr_decay_rate=SX.sym('agr_decay_rate',[1,1]);
food_decay_rate=SX.sym('food_decay_rate',[1,1]);
ind_pollution_factor=SX.sym('ind_pollution_factor',[1,1]);
agr_pollution_factor=SX.sym('agr_pollution_factor',[1,1]);
pop_starve_rate=SX.sym('pop_starve_rate',[1,1]);
constant_tech_need=SX.sym('constant_tech_need',[1,1]);
agr_prod_from_tech=SX.sym('agr_prod_from_tech',[1,1]);
ind_prod_from_tech=SX.sym('ind_prod_from_tech',[1,1]);
hc_eff_from_tech=SX.sym('hc_eff_from_tech',[1,1]);
res_scarcity_factor=SX.sym('res_scarcity_factor',[1,1]);
ind_output_PP_factor=SX.sym('ind_output_PP_factor',[1,1]);
ind_productivity_factor=SX.sym('ind_productivity_factor',[1,1]);
agr_productivity_factor=SX.sym('agr_productivity_factor',[1,1]);
ind_per_IO=SX.sym('ind_per_IO',[1,1]);
agr_per_IO=SX.sym('agr_per_IO',[1,1]);
tech_per_IO=SX.sym('tech_per_IO',[1,1]);
immigration_perGDP=SX.sym('immigration_perGDP',[1,1]);
tech_PP_factor = SX.sym('tech_PP_factor',[1,1]);
unemployment_factor = SX.sym('unemployment_factor',[1,1]);

params = [
%     immigration_rate;
    pop_growth_rate;
    base_ind_productivity;
    base_agr_productivity;
    base_healthcare_efficiency;
    ind_growth_per_pop;
    res_per_ind;
    tech_decay_rate;
    ind_decay_rate;
    agr_decay_rate;
    food_decay_rate;
    ind_pollution_factor;
    agr_pollution_factor;
    pop_starve_rate;
    constant_tech_need;
    agr_prod_from_tech;
    ind_prod_from_tech;
    hc_eff_from_tech;
    res_scarcity_factor;
    ind_output_PP_factor;
    ind_productivity_factor;
    agr_productivity_factor;
    ind_per_IO;
    agr_per_IO;
    tech_per_IO;
    immigration_perGDP;
    tech_PP_factor;
    unemployment_factor;
];

init_guess=[
%      0.01; %immigration_rate 
     0.001;%pop_growth_rate 
     non_nan_data(1,12);%base_ind_productivity 
     non_nan_data(1,11);%base_agr_productivity 
     0;%base_healthcare_efficiency 
     0.001;%ind_growth_per_pop 
     0.01;%res_per_ind 
     0.001;%tech_decay_rate 
     0.002;%ind_decay_rate 
     0.004;%agr_decay_rate 
     0.01;%food_decay_rate 
     0.01;%ind_pollution_factor 
     0.005;%agr_pollution_factor 
     0.1;%pop_starve_rate 
     1;%constant_tech_need 
     0.001;%agr_prod_from_tech 
     0.001;%ind_prod_from_tech 
     0;%hc_eff_from_tech 
     0.0001;%res_scarcity_factor 
     0.0001;%ind_output_PP_factor 
     non_nan_data(1,5)/(non_nan_data(1,3)*non_nan_data(1,12));%ind_productivity_factor
     non_nan_data(1,10)/(non_nan_data(1,2)*non_nan_data(1,11));%agr_productivity_factor
     0.0001;%ind_per_IO;
     0.0001;%agr_per_IO;
     0.0001;%tech_per_IO;
     0.0376/4;%immigration_perGDP
     1;%tech_PP_factor
     0.001;%unemployment_factor
];

param_lb=[
%     -0.05; %immigration_rate 
    -0.005;%pop_growth_rate 
     0;%base_ind_productivity 
     0;%base_agr_productivity 
     0;%base_healthcare_efficiency 
     0;%ind_growth_per_pop 
     0;%res_per_ind 
     0;%tech_decay_rate 
     0;%ind_decay_rate 
     0;%agr_decay_rate 
     0;%food_decay_rate 
     0;%ind_pollution_factor 
     0;%agr_pollution_factor 
     0;%pop_starve_rate 
     -1;%constant_tech_need 
     0;%agr_prod_from_tech 
     0;%ind_prod_from_tech 
     0;%hc_eff_from_tech 
     0;%res_scarcity_factor 
     0;%ind_output_PP_factor 
     0;%ind_productivity_factor
     0;%agr_productivity_factor
     0;%ind_per_IO;
     0;%agr_per_IO;
     0;%tech_per_IO;
     -0.1;%immigration_perGDP
     0;%tech_PP_factor
     -0.1;%unemployment_factor
];

param_ub=[
%      0.1; %immigration_rate 
     0.05;%pop_growth_rate 
     10;%base_ind_productivity 
     100;%base_agr_productivity 
     0.1;%base_healthcare_efficiency 
     0.1;%ind_growth_per_pop 
     10;%res_per_ind 
     0.2;%tech_decay_rate 
     0.2;%ind_decay_rate 
     0.2;%agr_decay_rate 
     10;%food_decay_rate 
     0.5;%ind_pollution_factor 
     0.5;%agr_pollution_factor 
     1;%pop_starve_rate 
     100;%constant_tech_need 
     10;%agr_prod_from_tech 
     10;%ind_prod_from_tech 
     10;%hc_eff_from_tech 
     0.1;%res_scarcity_factor 
     0.1;%ind_output_PP_factor 
     100;%ind_productivity_factor
     100;%agr_productivity_factor
     10;%ind_per_IO;
     10;%agr_per_IO;
     10;%tech_per_IO;
     1;%immigration_perGDP
     10;%tech_PP_factor
     0.1;%unemployment_factor
];



 %% Dynamics:
 res_init = non_nan_data(1,8);
 food_consumption_rate = 2;
 sigmoid_factor = 10;
 sig = SX.sym('sigmoid_factor',[1,1]);
 
 for t = 1+max_lag:T
    all_sectors = ind(t)+agr(t)+tech_infrastructure(t);
    ineq{t-max_lag}=[...
%     pop_alloc_to_ind(t) - ind(t);
%     pop_alloc_to_agr(t) - agr(t);
%     pop_alloc_to_tech(t) - tech_infrastructure(t);  
%     -pop_alloc_to_ind(t) + 1.1*ind(t); % don't allow ind to spiral out of control
%     -pop_alloc_to_agr(t) + 1.1*agr(t); % don't allow agr to spiral out of control
%     -pop_alloc_to_tech(t) + 1.1*tech_infrastructure(t);  % don't allow tech_infrastructure to spiral out of control
        ];
    ineq2eq{t-max_lag} = [... % this is specifically for the simulations. otherwise, they would treat the inequations as equations and generate absurd results
%     pop_alloc_to_ind(t) - 0.95*pop(t)*ind(t)/all_sectors;
%     pop_alloc_to_agr(t) - 0.95*pop(t)*agr(t)/all_sectors;
%     pop_alloc_to_tech(t) - 0.95*pop(t)*tech_infrastructure(t)/all_sectors;    
    ];
    eq{t-max_lag}=[...
%     pop_alloc_to_ind(t) - ( min(pop(t)*ind(t)/all_sectors,ind(t)));
%     pop_alloc_to_agr(t) - ( min(pop(t)*agr(t)/all_sectors,agr(t)));
%     pop_alloc_to_tech(t) - ( min(pop(t)*tech_infrastructure(t)/all_sectors,tech_infrastructure(t)));
%     pop_alloc_to_ind(t) - pop(t)*ind(t)/all_sectors;
%     pop_alloc_to_agr(t) - pop(t)*agr(t)/all_sectors;
%     pop_alloc_to_tech(t) - pop(t)*tech_infrastructure(t)/all_sectors; 
    pop_alloc_to_ind(t) - ind(t);
    pop_alloc_to_agr(t) - agr(t);
    pop_alloc_to_tech(t) - tech_infrastructure(t);  
    tech(t) - ( tech_shk(t) + tech(t-1) + tech_PP_factor*pop_alloc_to_tech(t));
    unemployment(t) - ( pop(t)-pop_alloc_to_ind(t)-pop_alloc_to_agr(t)-pop_alloc_to_tech(t));
    ind_productivity(t) - ( base_ind_productivity + ind_prod_from_tech*tech(t));
%     ind_output(t) - (  ind_output_shk(t) + (2/(1+exp(-sig*res(t)))-1)*pop_alloc_to_ind(t)*(ind_productivity_factor*ind_productivity(t))); %res close to 0 => ind_output ~= 0
    ind_output(t) - (  ind_output_shk(t) + (exp(res(t)/res_init)/exp(1))*pop_alloc_to_ind(t)*ind_productivity_factor*ind_productivity(t)); %ind_output scales with avail. res. (lower res implies higher res cost which implies industry less profitable)
    agr_productivity(t) - ( base_agr_productivity + agr_prod_from_tech*tech(t));
    agr_output(t) - ( agr_output_shk(t) + pop_alloc_to_agr(t)*(agr_productivity_factor*agr_productivity(t)));
%     ind_growth_need(t) - ( ind_growth_need_shk(t) + res(t)*(1/(1+exp(-sig*(pop_alloc_to_ind(t)-ind(t)))))/res_init);  %pop_alloc_to_ind>=ind or res=0 => ind_growth_need ~= 0
    ind_growth_need(t) - ( ind_growth_need_shk(t) + (res(t)/res_init));%*exp(pop_alloc_to_ind(t)-ind(t)));  % scale down industry growth as resources are depleted
%     agr_growth_need(t) - ( agr_growth_need_shk(t) + (1/(1+exp(-sig*(pop_alloc_to_agr(t)-agr(t)))))+(1/(1+exp(-sig*(2*pop(t)-food(t))))));  %pop_alloc_to_agr>=agr or food<2*pop => agr_growth_need ~= 0
    agr_growth_need(t) - ( agr_growth_need_shk(t) + (pop(t)/(food(t)+1)));%*exp(pop_alloc_to_agr(t)-agr(t))); 
    services_need(t) - ( services_need_shk(t) + pop(t)/10); % 10 chosen arbitrarily
    tech_growth_need(t) - ( constant_tech_need);
    ];
    all_needs = ind_growth_need(t)+agr_growth_need(t)+services_need(t)+tech_growth_need(t);
    eq{t-max_lag}=[eq{t-max_lag};
    ind_to_ind_growth(t) - ( ind_output(t)*ind_growth_need(t)/all_needs + pop(t)*ind_growth_per_pop*ind_growth_need(t));
    ind_to_services(t) - ( ind_output(t)*services_need(t)/all_needs);
    ind_to_agr_growth(t) - ( ind_output(t)*agr_growth_need(t)/all_needs);
    ind_to_tech_growth(t) - ( ind_output(t)*tech_growth_need(t)/all_needs);
    tech_infrastructure(t) - ( tech_infrastructure_shk(t) + tech_infrastructure(t-1)*(1-tech_decay_rate) + tech_per_IO*ind_to_tech_growth(t));
    infl(t) - ( infl_shk(t) + res_scarcity_factor*(res_init - res(t)) + ind_output_PP_factor*ind_output(t)/pop(t) - unemployment_factor*unemployment(t));
    agr_efficiency(t) - ( agr_efficiency_shk(t) + env(t)/100); % combines factors such as soil degradation and climate change (wetter springs and dryer summers reduce efficiency)
    env_loss_from_ind(t) - ( ind_output(t)*ind_pollution_factor);
    env_loss_from_agr(t) - ( agr_output(t)*agr_pollution_factor);
    natural_env_growth(t) - ( 100/(env(t)+100) - 0.5);
    starvation(t) - ( max((-food(t)+pop(t)-agr_output(t)*agr_efficiency(t))*pop_starve_rate,0) );
    immigration(t) - (immigration_perGDP*ind_output(t)/pop(t));
    pop(t) - ( pop_shk(t) + pop(t-1)*(1 + pop_growth_rate) + immigration(t) - starvation(t));% + ind_to_services(t)*(base_healthcare_efficiency + hc_eff_from_tech*tech(t)));
    ind(t) - ( ind_shk(t) + ind(t-1)*(1 - ind_decay_rate) + ind_per_IO*ind_to_ind_growth(t));
    agr(t) - ( agr_shk(t) + agr(t-1)*(1 - agr_decay_rate) + agr_per_IO*ind_to_agr_growth(t));
    food(t) - ( food_shk(t) + food(t-1)*(1- food_decay_rate) + agr_output(t)*agr_efficiency(t) - food_consumption_rate*pop(t));
    res(t) - ( res_shk(t) + res(t-1) - ind_output(t)*res_per_ind);
    env(t) - ( env(t-1) - env_loss_from_ind(t) - env_loss_from_agr(t) + natural_env_growth(t));
    ];
 end
 
 %% Initial conditions
% eq{T+1} = [pop(1) - data(1,1);
%         tech(1) - 0;
%         tech_infrastructure(1) - data(1,4); %assumes tech_infrastructure(1)=pop_alloc_to_tech(1)
%         ind(1) - data(1,3);  %assumes ind(1)=pop_alloc_to_ind(1)
%         agr(1) - data(1,2);  %assumes agr(1)=pop_alloc_to_agr(1)
%         food(1) - data(1,9);
%         env(1) - 100;
%         res(1) - data(1,8);];

%% set up and simulate model
% vars_lb = [repmat([zeros(n_obs,1);zeros(n_states,1);-1000*ones(n_shocks,1)],T,1);zeros(8,1)];
% vars_ub = [repmat([1000*ones(5,1);100;1000;1000;10000;1000;100;100;1000*ones(8,1);ones(4,1);1000*ones(5,1);100;0.01;1000*ones(n_shocks,1)],T,1);1000*ones(5,1);10000;1000;100];


% if length(vars_lb)~=length(vars_ub)
%    error("mismatched lengths of upper and lower bounds") 
% end

% for lagged vars
init_conds = [non_nan_data(1,1);
    0;
    non_nan_data(1,4);
    non_nan_data(1,3);
    non_nan_data(1,2);
    non_nan_data(1,9);
    100;
    non_nan_data(1,8)];
% set up bounds for all vars
vars_lb = [];
vars_ub = [];
for t = 1+max_lag:T
    % define lagged vars
    lagged_vars{t-max_lag} = [pop(t-1);
        tech(t-1);
        tech_infrastructure(t-1); 
        ind(t-1);  
        agr(t-1);  
        food(t-1);
        env(t-1);
        res(t-1)];
    % define all vars
    all_vars{t-max_lag} = [obs_vars{t-max_lag};state_vars{t-max_lag}];
    % initial guess for trajectories
    x0{t-max_lag} = [non_nan_data(t,:)';states_init_guess];
    % add specific shocks
    shock_vals{t-max_lag} = zeros(length(shocks{t-max_lag}),1);
    % set up bounds for all vars   
%     vars_lb = [vars_lb;data(t,:)';zeros(n_states,1);-1000*ones(n_shocks,1)];
    vars_lb = [vars_lb; zeros(5,1);-10;zeros(24,1);-10; -1000*ones(n_shocks,1)];
    vars_lb(isnan(vars_lb))=-inf;
%     vars_ub = [vars_ub;data(t,:)';1000*ones(8,1);ones(4,1);1000*ones(5,1);100;0.01;1000*ones(n_shocks,1)];
    vars_ub = [vars_ub; 100*ones(4,1);1000;100;100;1000;10000;1000;100;100; 1000*ones(8,1);ones(4,1);1000;1000;100*ones(3,1);100;1; 1000*ones(n_shocks,1)];
    vars_ub(isnan(vars_ub))=inf;
end
% define lagged vars
% lagged_vars{T+1} = [pop(T+1);
%         tech(T+1);
%         tech_infrastructure(T+1); 
%         ind(T+1);  
%         agr(T+1);  
%         food(T+1);
%         env(T+1);
%         res(T+1)];
% initial guess for last timestep of lagged vars
% x0{T+1} = [0;non_nan_data(T,4);non_nan_data(T,1);non_nan_data(T,3);non_nan_data(T,2);non_nan_data(T,9);non_nan_data(T,8);90]; 
% bounds for last timestep of lagged vars
vars_lb = [vars_lb; zeros(8,1)];
vars_ub = [vars_ub; 100;1000;100*ones(3,1);10000;100;1000];

% run a simulation with fixed params to get a feasible initial trajectory
[sim_traj,lagged_vals] = nonlin_sim2(eq,ineq2eq,lagged_vars,lag_inds,init_conds,all_vars,vars_lb,vars_ub,x0{1},shocks,shock_vals,params,init_guess,T-max_lag,sig,sigmoid_factor);
% traj_names = all_vars{1};

%% estimate model
% indices of the latent variables
% states_inds = length(obs_vars{1})+1:length(all_vars{1});
for t = 1:T-max_lag
   init_state_traj{t} = sim_traj(:,t);
end
% x0{T+1} = sim_traj([1,27,26,28,29,9,30,8],T+1);
x0{T} = lagged_vals{T-max_lag};

lag_inds = [1;27;26;28;29;9;30;8]; %indices of pop, tech, tech. infrastructure, ind, agr, food, env, and res in all_vars

% adjust param vals to fit trajectories to observations
[est_params,traj,shock_sol] = nonlin_est_v2(data(max_lag+1:T,:),[vertcat(eq{:});lagged_vars{1}-init_conds],vertcat(ineq{:}),obs_vars,state_vars,shocks,lagged_vars{1},x0{T},init_state_traj,vars_lb,vars_ub,params,init_guess,param_lb,param_ub,sig,sigmoid_factor);

%% display estimation results
shock_scores = sum(abs(shock_sol)');
[scores_sorted,score_indices] = sort(shock_scores);

disp("top three model concepts to improve:")
disp(shocks{1}(score_indices(end)))
disp(shocks{1}(score_indices(end-1)))
disp(shocks{1}(score_indices(end-2)))
% [[all_vars{1};shocks{1}] traj];
% [params est_params];
%% create plots
figure(1)
hold on
tt=1+max_lag:T;
plot(tt,full(traj(1,tt-max_lag)),'m')
plot(tt,full(traj(3,tt-max_lag)),'b')
plot(tt,full(traj(2,tt-max_lag)),'r')
plot(tt,full(traj(8,tt-max_lag))/10,'c')
plot(tt,full(traj(30,tt-max_lag)),'g')
hold off
lgd = legend('population','pop. alloc. to industry','pop. alloc. to agriculture','resources','environment');
lgd.Location='bestoutside';
% xticks(0:10:T)
% labels = (1981:10:1981+T);
% xticklabels({labels})

%% forecasting
H = 8; % forecast horizon
init_conds2 = [traj(1,T-max_lag);
    traj(27,T-max_lag);
    traj(26,T-max_lag);
    traj(28,T-max_lag);
    traj(29,T-max_lag);
    traj(9,T-max_lag);
    traj(30,T-max_lag);
    traj(8,T-max_lag)];


forecast_traj = nonlin_sim2(eq,ineq2eq,lagged_vars,lag_inds,init_conds2,all_vars,vars_lb,vars_ub,traj(1:length(all_vars{1}),T-max_lag),shocks,shock_vals,params,est_params,H,sig,sigmoid_factor);

hold on
tt=1:H;
plot(tt+T,full(forecast_traj(1,tt)),'m','HandleVisibility','off')
plot(tt+T,full(forecast_traj(3,tt)),'b','HandleVisibility','off')
plot(tt+T,full(forecast_traj(2,tt)),'r','HandleVisibility','off')
plot(tt+T,full(forecast_traj(8,tt)/10),'c','HandleVisibility','off')
plot(tt+T,full(forecast_traj(30,tt)),'g','HandleVisibility','off')
hold off
% xticks(0:10:T+H)
% labels = (1981:10:1981+T+H);
xticks(0:4:T+H)
labels = (1981:1981+floor((T+H)/4));
xticklabels({labels})
set(gcf,'Position',[100 100 1000 500])