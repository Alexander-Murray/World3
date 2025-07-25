clear all
close all
clc
% estimation is carried out via iterative regression wherein each iteration
% obtains parameter estimates given the data at time t and t-1.
% the final parameter estimates come from the mean of the set of parameter
% estimates across all iterations

% added canadian inflation

% inflation params estimated separately

% function Estimate_World3(est_start_y,est_start_q,est_end_y,est_end_q)
est_start_y='1950';
est_start_q='1';
est_end_y='2007';
est_end_q='1';

addpath(genpath('/home/mfa/mrra/CasADi_v3.5.5_linux'));
import casadi.*

interp = 1; % 0 = no interpolation, 1=linear interpolation
skip_ML=false; % choose whether to interpolate and extrapolate the lookup tables provided with the World3 model

save_plots = true;
est_params = true;
est_infq_params=true;
eval_jacobian=true;

H = 16; % forecast horizon

% data range to use for estimation
% est_start = 201; %201 = 1950Q1
% est_end = 488-H; %301 = 1975Q1

est_iter_period = 16; % number of timesteps in each iterative regression
minT = max(H,est_iter_period);
dt=0.25; % 0.5 => each time step is 6 months

% diary on

%% data
disp('Reading data...')

% load initial states and get variable names
World3_init_guesses = World3_init3();
var_names = fields(World3_init_guesses);
n_var = length(var_names);

% load estimation data
raw_data = readtable('my_World3_data.csv');
all_dates = table2array(raw_data(:,3));
est_start = find(strcmp([num2str(est_start_y) 'Q' num2str(est_start_q)],all_dates));
est_end = find(strcmp([num2str(est_end_y) 'Q' num2str(est_end_q)],all_dates));

dates = table2array(raw_data(est_start:est_end+H,3));

obs_vars = raw_data(:,4:end).Properties.VariableNames; % skip year, quarter, date columns
% old approach:
    % observed variables (MUST MATCH ORDER IN DATA!)
    % obs_vars = [...
    %     "fertility_control_facilities_per_capita";... %1
    %     "perceived_life_expectancy";... %2
    %     "delayed_industrial_output_per_capita";... %3
    %     "desired_completed_family_size";... %4
    %     "maximum_total_fertility";... %5
    %     "fecundity_multiplier";... %6
    %     "population";... %7
    %     "total_fertility";... %8
    %     "deaths";... %9
    %     "Population_0_To_14";... %10
    %     "Population_15_To_44";... %11
    %     "Population_45_To_64";... %12
    %     "Population_65_Plus";...%13
    %     "food";...   %14
    %     "industrial_output";...%15
    %     "fraction_of_industrial_output_allocated_to_services_1";... %16
    %     "Persistent_Pollution";... %17
    %     "Nonrenewable_Resources";... %18
    %     "Industrial_Capital";... %19
    %     "Arable_Land";... %20
    %     "life_expectancy";... %21
    %     "inflation";... %22
    %     "GDP_per_capita";... %23
    %     ];
% get the variable indices for each observed variable
n_obs = length(obs_vars);
obs_var_inds = nan(n_obs,1); 
for v = 1:n_obs
    obs_var_inds(v)=find(strcmp(var_names,obs_vars(v)));% column names in data must exactly match variable names, including case
%     for i = 1:n_var
%         if strcmp(var_names{i},obs_vars(v)) % column names in data must exactly match variable names, including case
%             obs_var_inds(v) = i;
%             break;
%         end
%     end
end
infq_ind_can = find(strcmp(var_names,"inflation_CAN"));
infq_ind_world = find(strcmp(var_names,"inflation"));

% put normalization in a struct and an array for easy look-up
normalization = nan(1,n_var);
for v = 1:n_var
    %%% THE PROBLEM HERE when doing so in an automated fashion is that some
    %%% quantities may appear together but have different normalizations (ie. x*10^3 - y*10^2)
    %     norm.(var_names{v}) = 10^floor(log10(max(abs(World3_init_guesses.(var_names{v})),1)));
    %     normalization(v) = 10^floor(log10(max(abs(World3_init_guesses.(var_names{v})),1)));
    
    if  floor(log10(max(abs(World3_init_guesses.(var_names{v})),1)))>6
        norm.(var_names{v}) = 10^9;
        normalization(v) = 10^9;
    else
        norm.(var_names{v}) = 1;
        normalization(v) = 1;
    end
    if strcmp(var_names{v},'land_erosion_rate') || strcmp(var_names{v},'land_removal_for_urban_and_industrial_use')
        norm.(var_names{v}) = 10^9;
        normalization(v) = 10^9;
    end
end

% normalize data
data = table2array(raw_data(est_start:4*dt:est_end+H,4:end))./normalization(obs_var_inds); % exclude timestamp column
T=H;%est_end-est_start+1;
infq_data_CAN = lin_interp(raw_data.inflation_CAN); % inflation data
infq_data_world = lin_interp(raw_data.inflation); % inflation data

% % linear interpolation for missing values
if interp == 0
    non_nan_data = data;
elseif interp==1
    non_nan_data = lin_interp(data);
else
    error('invalid interp option selected');
end

%% set up shocks and initial conditions

if ~skip_ML
    all_shocks = SX.sym('shocks',[n_obs,T]);
    shock_counter = 1;
    for var = 1:n_var
        eval([var_names{var} '_shk = SX.sym(''' var_names{var} '_shk'',[T,1]);']);
        % only add shocks/residuals to observed variables
        if ~ismember(var,obs_var_inds)
            eval([var_names{var} '_shk = zeros(T,1);']);
        else
            eval(['all_shocks(' num2str(shock_counter) ',:) = ' var_names{var} '_shk;']);
            shock_counter = shock_counter + 1;
        end
        %         eval(['all_shocks(' num2str(var) ',:) = ' var_names{var} '_shk;']);
    end
end

shocks = cell(T,1);
for t = 1:T
    % shocks
    shocks{t} = all_shocks(:,t);
end
n_shocks = length(shocks{1});

% % initial state for each variable
% if ~skip_ML
%     init_vars = SX.sym('init',[n_var,1]);
%     for var = 1:n_var
%         eval([var_names{var} '_init = SX.sym(''' var_names{var} '_init '',[1,1]);' ])
%         eval(['init_vars(' num2str(var) ') = ' var_names{var} '_init;']); % collect all initial conditions
%         %         eval([var_names{var} '_init = ' num2str(World3_init_guesses.(var_names{var})) ';']); % assign values to initial conditions
%     end
% end



%% Tables:
%%% TO DO: use these tables to create list of upper nad lower bounds on variables
% for example: 
% all>0
% 1>frac>0
% potentially_arable_land_total>Potentially_Arable_Land>0
% 1>land_yield_multiplier_from_air_pollution
% 1>land_yield_technology_change_rate_multiplier
% 1>land_life_multiplier_from_land_yield
% 1>marginal_land_yield_multiplier_from_capital

if ~skip_ML
    disp('Generating tables...')
    
    names{2}='x'; names{3} = 'y';
    x_cas=SX.sym('x',[1,1]);
    
    %     Education_Index_LOOKUP=[[0,0];[1000,0.81];[2000,0.88];[3000,0.92];[4000,0.95];[5000,0.98];[6000,0.99];[7000,1]];
    %     [coeffs{1},fit{1},fun_text{1},modelFun{1}] = get_fit(Education_Index_LOOKUP(:,1),Education_Index_LOOKUP(:,2),false,false,names);
    %     Education_Index_LOOKUP = @(x) modelFun{1}(coeffs{1},x);
    %     Education_Index_LOOKUP=Function('f',{x_cas},{Education_Index_LOOKUP(x_cas)});
%     GDP_per_capita_LOOKUP=[[0,120];[200,600];[400,1200];[600,1800];[800,2500];[1000,3200]];
% GDP_per_capita_LOOKUP=[[41.5625,42.3219683432339];
% [145.618282533395,104.070005850643];
% [247.866982230282,1053.07050945513];
% [258.056494322373,1138.11714316642];
% [267.541122270722,1162.79399506868];
% [272.020814409614,1264.97299991678];
% [263.848520203228,1291.21653649422];
% [256.098052460357,1345.08409517369];
% [249.092038979001,1345.68320807262];
% [253.550842954371,1412.88305963982];
% [259.109118998455,1520.11434358835];
% [272.1618788793,1528.91624344628];
% [281.891930076157,1507.49939698469];
% [286.39245499935,1487.92170170552];
% [292.533020620413,1515.70261227975];
% [305.234061284888,1538.89367313265];
% [301.919381842863,1515.4314552909];
% [298.021712124127,1544.98634716981];
% [304.677467531715,1671.49184441163];
% [317.538533853524,1813.42645095766];
% [331.977268721061,1907.47833026243];
% [346.863876479356,2006.45181403226];
% [358.722008922952,2171.13422329523];
% [356.256093445868,2304.42955444493];
% [316.55280008042,2197.50660350348];
% [321.91127793312,2327.17019588786];
% [331.501833165127,2484.86476602135];
% [330.953350834434,2502.08573123221];
% [332.686264198195,2529.33047436009];
% [337.601622670557,2556.21003211466];
% [342.084685195945,2430.80470861165];
% [344.516075962747,2439.93343259234];
% [353.277426978975,2530.58985271905];
% [361.436709310746,2620.52212820174];
% [366.693629521332,2626.32535999462];
% [346.063802916618,2554.03461357722];
% [364.813789181551,2773.76999307351]];

GDP_per_capita_LOOKUP=[[145.6394883,370.1];
[247.967436,3445.24];
[257.1949321,3782.38];
[268.0090444,3882.1];
[272.7524517,4304.09];
[264.5088727,4414.83];
[256.705003,4645.15];
[249.2185688,4647.74];
[254.3842421,4940.82];
[259.4363687,5421.6];
[272.9545648,5461.77];
[281.0471966,5364.2];
[285.6039343,5275.57];
[293.3537998,5401.5];
[305.7457941,5507.45];
[301.7294724,5400.26];
[297.826153,5535.41];
[304.9782603,6127.7];
[318.1097988,6818.9];
[332.4094932,7292.45];
[346.3116788,7804.16];
[358.313773,8685.99];
[356.7445201,9427.55];
[316.0196183,8830.73];
[322.0910158,9556.54];
[330.8297053,10470.99];
[330.9271106,10572.96];
[332.3865892,10735.13];
[337.9200798,10896.15];
[342.0139556,10153.58];
[344.7140321,10206.89];
[352.6398194,10742.65];
[361.8006299,11285.5];
[367.0338664,11320.92];
[345.6212582,10883.08];
[365.392863,12236.62]];

    [coeffs{2},fit{2},fun_text{2},modelFun{2}] = get_fit(GDP_per_capita_LOOKUP(:,1),GDP_per_capita_LOOKUP(:,2),false,false,names);
    GDP_per_capita_LOOKUP = @(x) modelFun{2}(coeffs{2},x);
    GDP_per_capita_LOOKUP=Function('f',{x_cas},{GDP_per_capita_LOOKUP(x_cas)});
    %     Life_Expectancy_Index_LOOKUP=[[25,0];[35,0.16];[45,0.33];[55,0.5];[65,0.67];[75,0.84];[85,1]];
    %     [coeffs{3},fit{3},fun_text{3},modelFun{3}] = get_fit(Life_Expectancy_Index_LOOKUP(:,1),Life_Expectancy_Index_LOOKUP(:,2),false,false,names);
    %     Life_Expectancy_Index_LOOKUP = @(x) modelFun{3}(coeffs{3},x);
    %     Life_Expectancy_Index_LOOKUP=Function('f',{x_cas},{Life_Expectancy_Index_LOOKUP(x_cas)});
    %     development_cost_per_hectare_table=[[0,100000];[0.1,7400];[0.2,5200];[0.3,3500];[0.4,2400];[0.5,1500];[0.6,750];[0.7,300];[0.8,150];[0.9,75];[1,50]];
    development_cost_per_hectare_table=[[0,12000];[0.1,7400];[0.2,5200];[0.3,3500];[0.4,2400];[0.5,1500];[0.6,750];[0.7,300];[0.8,150];[0.9,75];[1,50]];
    [coeffs{4},fit{4},fun_text{4},modelFun{4}] = get_fit(development_cost_per_hectare_table(:,1),development_cost_per_hectare_table(:,2),false,false,names);
    development_cost_per_hectare_table = @(x) modelFun{4}(coeffs{4},x);
    development_cost_per_hectare_table=Function('f',{x_cas},{development_cost_per_hectare_table(x_cas)});
    %     development_cost_per_hectare_table = @(x) interp_f(development_cost_per_hectare_table,x);
    %     fraction_industrial_output_allocated_to_agriculture_table_1=[[0,0.4];[0.5,0.2];[1,0.1];[1.5,0.025];[2,0];[2.5,0]];
    fraction_industrial_output_allocated_to_agriculture_table_1=[[0,0.4];[0.5,0.2];[1,0.1];[1.5,0.025];[2,0.01];[2.5,0.005]];
    [coeffs{5},fit{5},fun_text{5},modelFun{5}] = get_fit(fraction_industrial_output_allocated_to_agriculture_table_1(:,1),fraction_industrial_output_allocated_to_agriculture_table_1(:,2),false,false,names);
    fraction_industrial_output_allocated_to_agriculture_table_1 = @(x) modelFun{5}(coeffs{5},x);
    fraction_industrial_output_allocated_to_agriculture_table_1=Function('f',{x_cas},{fraction_industrial_output_allocated_to_agriculture_table_1(x_cas)});
    %     fraction_industrial_output_allocated_to_agriculture_table_1 = @(x) interp_f(fraction_industrial_output_allocated_to_agriculture_table_1,x);
    %     fraction_industrial_output_allocated_to_agriculture_table_2=[[0,0.4];[0.5,0.2];[1,0.1];[1.5,0.025];[2,0];[2.5,0]];
    fraction_industrial_output_allocated_to_agriculture_table_2=[[0,0.4];[0.5,0.2];[1,0.1];[1.5,0.025];[2,0.005];[2.5,0]];
    [coeffs{6},fit{6},fun_text{6},modelFun{6}] = get_fit(fraction_industrial_output_allocated_to_agriculture_table_2(:,1),fraction_industrial_output_allocated_to_agriculture_table_2(:,2),false,false,names);
    fraction_industrial_output_allocated_to_agriculture_table_2 = @(x) modelFun{6}(coeffs{6},x);
    fraction_industrial_output_allocated_to_agriculture_table_2=Function('f',{x_cas},{fraction_industrial_output_allocated_to_agriculture_table_2(x_cas)});
    %     fraction_industrial_output_allocated_to_agriculture_table_2 = @(x) interp_f(fraction_industrial_output_allocated_to_agriculture_table_2,x);
    indicated_food_per_capita_table_1=[[0,230];[200,480];[400,690];[600,850];[800,970];[1000,1070];[1200,1150];[1400,1210];[1600,1250]];
    [coeffs{7},fit{7},fun_text{7},modelFun{7}] = get_fit(indicated_food_per_capita_table_1(:,1),indicated_food_per_capita_table_1(:,2),false,false,names);
    indicated_food_per_capita_table_1 = @(x) modelFun{7}(coeffs{7},x);
    indicated_food_per_capita_table_1=Function('f',{x_cas},{indicated_food_per_capita_table_1(x_cas)});
    %     indicated_food_per_capita_table_1 = @(x) interp_f(indicated_food_per_capita_table_1,x);
    indicated_food_per_capita_table_2=[[0,230];[200,480];[400,690];[600,850];[800,970];[1000,1070];[1200,1150];[1400,1210];[1600,1250]];
    [coeffs{8},fit{8},fun_text{8},modelFun{8}] = get_fit(indicated_food_per_capita_table_2(:,1),indicated_food_per_capita_table_2(:,2),false,false,names);
    indicated_food_per_capita_table_2 = @(x) modelFun{8}(coeffs{8},x);
    indicated_food_per_capita_table_2=Function('f',{x_cas},{indicated_food_per_capita_table_2(x_cas)});
    %     indicated_food_per_capita_table_2 = @(x) interp_f(indicated_food_per_capita_table_2,x);
    %     land_yield_multiplier_from_capital_table=[[0,1];[40,3];[80,4.5];[120,5];[160,5.3];[200,5.6];[240,5.9];[280,6.1];[320,6.35];[360,6.6];[400,6.9];[440,7.2];[480,7.4];[520,7.6];[560,7.8];[600,8];[640,8.2];[680,8.4];[720,8.6];[760,8.8];[800,9];[840,9.2];[880,9.4];[920,9.6];[960,9.8];[1000,10]];
    land_yield_multiplier_from_capital_table=[[0,1];[40,3];[80,3.8];[120,4.4];[160,4.9];[200,5.4];[240,5.7];[280,6.0];[320,6.3];[360,6.6];[400,6.9];[440,7.2];[480,7.4];[520,7.6];[560,7.8];[600,8];[640,8.2];[680,8.4];[720,8.6];[760,8.8];[800,9];[840,9.2];[880,9.4];[920,9.6];[960,9.8];[1000,10]];
    %     land_yield_multiplier_from_capital_table=[[0,1];[5.33,1.26];[6.576,1.329];[9.96,1.50];[40,3];[80,3.8];[120,4.4];[160,4.9];[200,5.4];[240,5.7];[280,6.0];[320,6.3];[360,6.6];[400,6.9];[440,7.2];[480,7.4];[520,7.6];[560,7.8];[600,8];[640,8.2];[680,8.4];[720,8.6];[760,8.8];[800,9];[840,9.2];[880,9.4];[920,9.6];[960,9.8];[1000,10]];
    [coeffs{9},fit{9},fun_text{9},modelFun{9}] = get_fit(land_yield_multiplier_from_capital_table(:,1),land_yield_multiplier_from_capital_table(:,2),false,false,names);
    land_yield_multiplier_from_capital_table = @(x) modelFun{9}(coeffs{9},x);
    land_yield_multiplier_from_capital_table=Function('f',{x_cas},{land_yield_multiplier_from_capital_table(x_cas)});
    %     land_yield_multiplier_from_capital_table = @(x) interp_f(land_yield_multiplier_from_capital_table,x);
    land_yield_multipler_from_air_pollution_table_1=[[0,1];[10,1];[20,0.7];[30,0.4]];
    %     land_yield_multipler_from_air_pollution_table_1=[[0,1];[0.5,1];[1,1];[5,1];[10,1];[20,0.7];[30,0.4]];
    [coeffs{10},fit{10},fun_text{10},modelFun{10}] = get_fit(land_yield_multipler_from_air_pollution_table_1(:,1),land_yield_multipler_from_air_pollution_table_1(:,2),false,false,names);
    land_yield_multipler_from_air_pollution_table_1 = @(x) modelFun{10}(coeffs{10},x);
    land_yield_multipler_from_air_pollution_table_1=Function('f',{x_cas},{land_yield_multipler_from_air_pollution_table_1(x_cas)});
    %     land_yield_multipler_from_air_pollution_table_1 = @(x) interp_f(land_yield_multipler_from_air_pollution_table_1,x);
    land_yield_multipler_from_air_pollution_table_2=[[0,1];[10,1];[20,0.98];[30,0.95]];
    [coeffs{11},fit{11},fun_text{11},modelFun{11}] = get_fit(land_yield_multipler_from_air_pollution_table_2(:,1),land_yield_multipler_from_air_pollution_table_2(:,2),false,false,names);
    land_yield_multipler_from_air_pollution_table_2 = @(x) modelFun{11}(coeffs{11},x);
    land_yield_multipler_from_air_pollution_table_2=Function('f',{x_cas},{land_yield_multipler_from_air_pollution_table_2(x_cas)});
    %     land_yield_multipler_from_air_pollution_table_2 = @(x) interp_f(land_yield_multipler_from_air_pollution_table_2,x);
    %     land_yield_technology_change_rate_multiplier_table=[[0,0];[1,0]];
    land_yield_technology_change_rate_multiplier_table=[[-1,0];[0,0];[1,1];[2,1]];
    [coeffs{12},fit{12},fun_text{12},modelFun{12}] = get_fit(land_yield_technology_change_rate_multiplier_table(:,1),land_yield_technology_change_rate_multiplier_table(:,2),false,false,names);
    land_yield_technology_change_rate_multiplier_table = @(x) modelFun{12}(coeffs{12},x);
    land_yield_technology_change_rate_multiplier_table=Function('f',{x_cas},{land_yield_technology_change_rate_multiplier_table(x_cas)});
    %     land_yield_technology_change_rate_multiplier_table = @(x) interp_f(land_yield_technology_change_rate_multiplier_table,x);
    land_life_multiplier_from_land_yield_table_1=[[0,1.2];[1,1];[2,0.63];[3,0.36];[4,0.16];[5,0.055];[6,0.04];[7,0.025];[8,0.015];[9,0.01]];
    %     land_life_multiplier_from_land_yield_table_1 = @(x) interp_f(land_life_multiplier_from_land_yield_table_1,x);
    [coeffs{13},fit{13},fun_text{13},modelFun{13}] = get_fit(land_life_multiplier_from_land_yield_table_1(:,1),land_life_multiplier_from_land_yield_table_1(:,2),false,false,names);
    land_life_multiplier_from_land_yield_table_1 = @(x) modelFun{13}(coeffs{13},x);
    land_life_multiplier_from_land_yield_table_1=Function('f',{x_cas},{land_life_multiplier_from_land_yield_table_1(x_cas)});
    land_life_multiplier_from_land_yield_table_2=[[0,1.2];[1,1];[2,0.63];[3,0.36];[4,0.29];[5,0.26];[6,0.24];[7,0.22];[8,0.21];[9,0.2]];
    %     land_life_multiplier_from_land_yield_table_2 = @(x) interp_f(land_life_multiplier_from_land_yield_table_2,x);
    [coeffs{14},fit{14},fun_text{14},modelFun{14}] = get_fit(land_life_multiplier_from_land_yield_table_2(:,1),land_life_multiplier_from_land_yield_table_2(:,2),false,false,names);
    land_life_multiplier_from_land_yield_table_2 = @(x) modelFun{14}(coeffs{14},x);
    land_life_multiplier_from_land_yield_table_2=Function('f',{x_cas},{land_life_multiplier_from_land_yield_table_2(x_cas)});
    urban_and_industrial_land_required_per_capita_table=[[0,0.005];[200,0.008];[400,0.015];[600,0.025];[800,0.04];[1000,0.055];[1200,0.07];[1400,0.08];[1600,0.09]];
    %     urban_and_industrial_land_required_per_capita_table = @(x) interp_f(urban_and_industrial_land_required_per_capita_table,x);
    [coeffs{15},fit{15},fun_text{15},modelFun{15}] = get_fit(urban_and_industrial_land_required_per_capita_table(:,1),urban_and_industrial_land_required_per_capita_table(:,2),false,false,names);
    urban_and_industrial_land_required_per_capita_table = @(x) modelFun{15}(coeffs{15},x);
    urban_and_industrial_land_required_per_capita_table=Function('f',{x_cas},{urban_and_industrial_land_required_per_capita_table(x_cas)});
    land_fertility_degredation_rate_table=[[0,0];[10,0.1];[20,0.3];[30,0.5]];
    %     land_fertility_degredation_rate_table = @(x) interp_f(land_fertility_degredation_rate_table,x);
    [coeffs{16},fit{16},fun_text{16},modelFun{16}] = get_fit(land_fertility_degredation_rate_table(:,1),land_fertility_degredation_rate_table(:,2),false,false,names);
    coeffs{16}(3)=0; %fixed point at 0, and always positive for positive x
    land_fertility_degredation_rate_table = @(x) modelFun{16}(coeffs{16},x);
    land_fertility_degredation_rate_table=Function('f',{x_cas},{land_fertility_degredation_rate_table(x_cas)});
    land_fertility_regeneration_time_table=[[0,20];[0.02,13];[0.04,8];[0.06,4];[0.08,2];[0.1,2]];
    %     land_fertility_regeneration_time_table = @(x) interp_f(land_fertility_regeneration_time_table,x);
    [coeffs{17},fit{17},fun_text{17},modelFun{17}] = get_fit(land_fertility_regeneration_time_table(:,1),land_fertility_regeneration_time_table(:,2),false,false,names);
    land_fertility_regeneration_time_table = @(x) modelFun{17}(coeffs{17},x);
    land_fertility_regeneration_time_table=Function('f',{x_cas},{land_fertility_regeneration_time_table(x_cas)});
    fraction_of_agricultural_inputs_for_land_maintenance_table=[[0,0];[1,0.04];[2,0.07];[3,0.09];[4,0.1]];
    %     fraction_of_agricultural_inputs_for_land_maintenance_table = @(x) interp_f(fraction_of_agricultural_inputs_for_land_maintenance_table,x);
    [coeffs{18},fit{18},fun_text{18},modelFun{18}] = get_fit(fraction_of_agricultural_inputs_for_land_maintenance_table(:,1),fraction_of_agricultural_inputs_for_land_maintenance_table(:,2),false,false,names);
    fraction_of_agricultural_inputs_for_land_maintenance_table = @(x) modelFun{18}(coeffs{18},x);
    fraction_of_agricultural_inputs_for_land_maintenance_table=Function('f',{x_cas},{fraction_of_agricultural_inputs_for_land_maintenance_table(x_cas)});
    fraction_of_agricultural_inputs_allocated_to_land_dev_table=[[0,0];[0.25,0.05];[0.5,0.15];[0.75,0.3];[1,0.5];[1.25,0.7];[1.5,0.85];[1.75,0.95];[2,1]];
    %     fraction_of_agricultural_inputs_allocated_to_land_dev_table = @(x) interp_f(fraction_of_agricultural_inputs_allocated_to_land_dev_table,x);
    [coeffs{19},fit{19},fun_text{19},modelFun{19}] = get_fit(fraction_of_agricultural_inputs_allocated_to_land_dev_table(:,1),fraction_of_agricultural_inputs_allocated_to_land_dev_table(:,2),false,false,names);
    fraction_of_agricultural_inputs_allocated_to_land_dev_table = @(x) modelFun{19}(coeffs{19},x);
    fraction_of_agricultural_inputs_allocated_to_land_dev_table=Function('f',{x_cas},{fraction_of_agricultural_inputs_allocated_to_land_dev_table(x_cas)});
    marginal_land_yield_multiplier_from_capital_table=[[0,0.075];[40,0.03];[80,0.015];[120,0.011];[160,0.009];[200,0.008];[240,0.007];[280,0.006];[320,0.005];[360,0.005];[400,0.005];[440,0.005];[480,0.005];[520,0.005];[560,0.005];[600,0.005]];
    %     marginal_land_yield_multiplier_from_capital_table = @(x) interp_f(marginal_land_yield_multiplier_from_capital_table,x);
    [coeffs{20},fit{20},fun_text{20},modelFun{20}] = get_fit(marginal_land_yield_multiplier_from_capital_table(:,1),marginal_land_yield_multiplier_from_capital_table(:,2),false,false,names);
    marginal_land_yield_multiplier_from_capital_table = @(x) modelFun{20}(coeffs{20},x);
    marginal_land_yield_multiplier_from_capital_table=Function('f',{x_cas},{marginal_land_yield_multiplier_from_capital_table(x_cas)});
    industrial_capital_output_ratio_multiplier_from_resource_table=[[0,3.75];[0.1,3.6];[0.2,3.47];[0.3,3.36];[0.4,3.25];[0.5,3.16];[0.6,3.1];[0.7,3.06];[0.8,3.02];[0.9,3.01];[1,3]];
    %     industrial_capital_output_ratio_multiplier_from_resource_table = @(x) interp_f(industrial_capital_output_ratio_multiplier_from_resource_table,x);
    [coeffs{21},fit{21},fun_text{21},modelFun{21}] = get_fit(industrial_capital_output_ratio_multiplier_from_resource_table(:,1),industrial_capital_output_ratio_multiplier_from_resource_table(:,2),false,false,names);
    industrial_capital_output_ratio_multiplier_from_resource_table = @(x) modelFun{21}(coeffs{21},x);
    industrial_capital_output_ratio_multiplier_from_resource_table=Function('f',{x_cas},{industrial_capital_output_ratio_multiplier_from_resource_table(x_cas)});
    frac_of_industrial_output_allocated_to_consumption_var_table=[[0,0.3];[0.2,0.32];[0.4,0.34];[0.6,0.36];[0.8,0.38];[1,0.43];[1.2,0.73];[1.4,0.77];[1.6,0.81];[1.8,0.82];[2,0.83]];
    %     frac_of_industrial_output_allocated_to_consumption_var_table = @(x) interp_f(frac_of_industrial_output_allocated_to_consumption_var_table,x);
    [coeffs{22},fit{22},fun_text{22},modelFun{22}] = get_fit(frac_of_industrial_output_allocated_to_consumption_var_table(:,1),frac_of_industrial_output_allocated_to_consumption_var_table(:,2),false,false,names);
    frac_of_industrial_output_allocated_to_consumption_var_table = @(x) modelFun{22}(coeffs{22},x);
    frac_of_industrial_output_allocated_to_consumption_var_table=Function('f',{x_cas},{frac_of_industrial_output_allocated_to_consumption_var_table(x_cas)});
    industrial_capital_output_ratio_multiplier_from_pollution_table=[[0,1.25];[0.1,1.2];[0.2,1.15];[0.3,1.11];[0.4,1.08];[0.5,1.05];[0.6,1.03];[0.7,1.02];[0.8,1.01];[0.9,1];[1,1]];
    %     industrial_capital_output_ratio_multiplier_from_pollution_table = @(x) interp_f(industrial_capital_output_ratio_multiplier_from_pollution_table,x);
    [coeffs{23},fit{23},fun_text{23},modelFun{23}] = get_fit(industrial_capital_output_ratio_multiplier_from_pollution_table(:,1),industrial_capital_output_ratio_multiplier_from_pollution_table(:,2),false,false,names);
    industrial_capital_output_ratio_multiplier_from_pollution_table = @(x) modelFun{23}(coeffs{23},x);
    industrial_capital_output_ratio_multiplier_from_pollution_table=Function('f',{x_cas},{industrial_capital_output_ratio_multiplier_from_pollution_table(x_cas)});
    industrial_capital_output_ratio_multiplier_table=[[1,1];[1.2,1.05];[1.4,1.12];[1.6,1.25];[1.8,1.35];[2,1.5]];
    %     industrial_capital_output_ratio_multiplier_table = @(x) interp_f(industrial_capital_output_ratio_multiplier_table,x);
    [coeffs{24},fit{24},fun_text{24},modelFun{24}] = get_fit(industrial_capital_output_ratio_multiplier_table(:,1),industrial_capital_output_ratio_multiplier_table(:,2),false,false,names);
    industrial_capital_output_ratio_multiplier_table = @(x) modelFun{24}(coeffs{24},x);
    industrial_capital_output_ratio_multiplier_table=Function('f',{x_cas},{industrial_capital_output_ratio_multiplier_table(x_cas)});
    capacity_utilization_fraction_table=[[1,1];[3,0.9];[5,0.7];[7,0.3];[9,0.1];[11,0.1]];
    %     capacity_utilization_fraction_table = @(x) interp_f(capacity_utilization_fraction_table,x);
    [coeffs{25},fit{25},fun_text{25},modelFun{25}] = get_fit(capacity_utilization_fraction_table(:,1),capacity_utilization_fraction_table(:,2),false,false,names);
    capacity_utilization_fraction_table = @(x) modelFun{25}(coeffs{25},x);
    capacity_utilization_fraction_table=Function('f',{x_cas},{capacity_utilization_fraction_table(x_cas)});
    jobs_per_hectare_table=[[2,2];[6,0.5];[10,0.4];[14,0.3];[18,0.27];[22,0.24];[26,0.2];[30,0.2]];
    %     jobs_per_hectare_table=[[0,5];[2,2];[6,0.5];[10,0.4];[14,0.3];[18,0.27];[22,0.24];[30,0.2];[50,0.15]];
    %     jobs_per_hectare_table = @(x) interp_f(jobs_per_hectare_table,x);
    [coeffs{26},fit{26},fun_text{26},modelFun{26}] = get_fit(jobs_per_hectare_table(:,1),jobs_per_hectare_table(:,2),false,false,names);
    jobs_per_hectare_table = @(x) modelFun{26}(coeffs{26},x);
    jobs_per_hectare_table=Function('f',{x_cas},{jobs_per_hectare_table(x_cas)});
    jobs_per_industrial_capital_unit_table=[[50,0.37];[200,0.18];[350,0.12];[500,0.09];[650,0.07];[800,0.06]];
    %     jobs_per_industrial_capital_unit_table = @(x) interp_f(jobs_per_industrial_capital_unit_table,x);
    [coeffs{27},fit{27},fun_text{27},modelFun{27}] = get_fit(jobs_per_industrial_capital_unit_table(:,1),jobs_per_industrial_capital_unit_table(:,2),false,false,names);
    jobs_per_industrial_capital_unit_table = @(x) modelFun{27}(coeffs{27},x);
    jobs_per_industrial_capital_unit_table=Function('f',{x_cas},{jobs_per_industrial_capital_unit_table(x_cas)});
    jobs_per_service_capital_unit_table=[[50,1.1];[200,0.6];[350,0.35];[500,0.2];[650,0.15];[800,0.15];[950,0.15];[1100,0.15];[1250,0.15];[1400,0.15];[1550,0.15]];
    %     jobs_per_service_capital_unit_table = @(x) interp_f(jobs_per_service_capital_unit_table,x);
    [coeffs{28},fit{28},fun_text{28},modelFun{28}] = get_fit(jobs_per_service_capital_unit_table(:,1),jobs_per_service_capital_unit_table(:,2),false,false,names);
    jobs_per_service_capital_unit_table = @(x) modelFun{28}(coeffs{28},x);
    jobs_per_service_capital_unit_table=Function('f',{x_cas},{jobs_per_service_capital_unit_table(x_cas)});
    fraction_of_industrial_output_allocated_to_services_table_1=[[0,0.3];[0.5,0.2];[1,0.1];[1.5,0.05];[2,0]];
    %     fraction_of_industrial_output_allocated_to_services_table_1 = @(x) interp_f(fraction_of_industrial_output_allocated_to_services_table_1,x);
    [coeffs{29},fit{29},fun_text{29},modelFun{29}] = get_fit(fraction_of_industrial_output_allocated_to_services_table_1(:,1),fraction_of_industrial_output_allocated_to_services_table_1(:,2),false,false,names);
    fraction_of_industrial_output_allocated_to_services_table_1 = @(x) modelFun{29}(coeffs{29},x);
    fraction_of_industrial_output_allocated_to_services_table_1=Function('f',{x_cas},{fraction_of_industrial_output_allocated_to_services_table_1(x_cas)});
    fraction_of_industrial_output_allocated_to_services_table_2=[[0,0.3];[0.5,0.2];[1,0.1];[1.5,0.05];[2,0]];
    %     fraction_of_industrial_output_allocated_to_services_table_2 = @(x) interp_f(fraction_of_industrial_output_allocated_to_services_table_2,x);
    [coeffs{30},fit{30},fun_text{30},modelFun{30}] = get_fit(fraction_of_industrial_output_allocated_to_services_table_2(:,1),fraction_of_industrial_output_allocated_to_services_table_2(:,2),false,false,names);
    fraction_of_industrial_output_allocated_to_services_table_2 = @(x) modelFun{30}(coeffs{30},x);
    fraction_of_industrial_output_allocated_to_services_table_2=Function('f',{x_cas},{fraction_of_industrial_output_allocated_to_services_table_2(x_cas)});
    indicated_services_output_per_capita_table_1=[[0,40];[200,300];[400,640];[600,1000];[800,1220];[1000,1450];[1200,1650];[1400,1800];[1600,2000]];
    %     indicated_services_output_per_capita_table_1=[[0,40];[41.5,94];[200,300];[400,640];[600,1000];[800,1220];[1000,1450];[1200,1650];[1400,1800];[1600,2000]];
    %     indicated_services_output_per_capita_table_1 = @(x) interp_f(indicated_services_output_per_capita_table_1,x);
    [coeffs{31},fit{31},fun_text{31},modelFun{31}] = get_fit(indicated_services_output_per_capita_table_1(:,1),indicated_services_output_per_capita_table_1(:,2),false,false,names);
    indicated_services_output_per_capita_table_1 = @(x) modelFun{31}(coeffs{31},x);
    indicated_services_output_per_capita_table_1=Function('f',{x_cas},{indicated_services_output_per_capita_table_1(x_cas)});
    indicated_services_output_per_capita_table_2=[[0,40];[200,300];[400,640];[600,1000];[800,1220];[1000,1450];[1200,1650];[1400,1800];[1600,2000]];
    %     indicated_services_output_per_capita_table_2 = @(x) interp_f(indicated_services_output_per_capita_table_2,x);
    [coeffs{32},fit{32},fun_text{32},modelFun{32}] = get_fit(indicated_services_output_per_capita_table_2(:,1),indicated_services_output_per_capita_table_2(:,2),false,false,names);
    indicated_services_output_per_capita_table_2 = @(x) modelFun{32}(coeffs{32},x);
    indicated_services_output_per_capita_table_2=Function('f',{x_cas},{indicated_services_output_per_capita_table_2(x_cas)});
    assimilation_half_life_mult_table=[[1,1];[251,11];[501,21];[751,31];[1001,41]];
    %     assimilation_half_life_mult_table=[[0,1];[0.5,1];[1,1];[2.29,1.05];[3.53,1.10];[7.60,1.26];[9.439,1.333];[11,1.4];[12,1.44];[13,1.48];[14,1.52];[15,1.56];[251,11];[501,21];[751,31];[1001,41]];
    %     assimilation_half_life_mult_table = @(x) interp_f(assimilation_half_life_mult_table,x);
    [coeffs{33},fit{33},fun_text{33},modelFun{33}] = get_fit(assimilation_half_life_mult_table(:,1),assimilation_half_life_mult_table(:,2),false,false,names);
    assimilation_half_life_mult_table = @(x) modelFun{33}(coeffs{33},x);
    assimilation_half_life_mult_table=Function('f',{x_cas},{assimilation_half_life_mult_table(x_cas)});
%     persistent_pollution_technology_change_mult_table=[[-1,0];[0,0]];
    persistent_pollution_technology_change_mult_table=[[-1,0];[0,0];[1,0]];
    %     persistent_pollution_technology_change_mult_table = @(x) interp_f(persistent_pollution_technology_change_mult_table,x);
    [coeffs{34},fit{34},fun_text{34},modelFun{34}] = get_fit(persistent_pollution_technology_change_mult_table(:,1),persistent_pollution_technology_change_mult_table(:,2),false,false,names);
    persistent_pollution_technology_change_mult_table = @(x) modelFun{34}(coeffs{34},x);
    persistent_pollution_technology_change_mult_table=Function('f',{x_cas},{persistent_pollution_technology_change_mult_table(x_cas)});
    mortality_45_to_64_table=[[20,0.0562];[30,0.0373];[40,0.0252];[50,0.0171];[60,0.0118];[70,0.0083];[80,0.006]];
    %     mortality_45_to_64_table = @(x) interp_f(mortality_45_to_64_table,x);
    [coeffs{35},fit{35},fun_text{35},modelFun{35}] = get_fit(mortality_45_to_64_table(:,1),mortality_45_to_64_table(:,2),false,false,names);
    mortality_45_to_64_table = @(x) modelFun{35}(coeffs{35},x);
    mortality_45_to_64_table=Function('f',{x_cas},{mortality_45_to_64_table(x_cas)});
    mortality_65_plus_table=[[20,0.13];[30,0.11];[40,0.09];[50,0.07];[60,0.06];[70,0.05];[80,0.04]];
    %     mortality_65_plus_table = @(x) interp_f(mortality_65_plus_table,x);
    [coeffs{37},fit{37},fun_text{37},modelFun{37}] = get_fit(mortality_65_plus_table(:,1),mortality_65_plus_table(:,2),false,false,names);
    mortality_65_plus_table = @(x) modelFun{37}(coeffs{37},x);
    mortality_65_plus_table=Function('f',{x_cas},{mortality_65_plus_table(x_cas)});
    mortality_0_to_14_table=[[20,0.0567];[30,0.0366];[40,0.0243];[50,0.0155];[60,0.0082];[70,0.0023];[80,0.001]];
    %     mortality_0_to_14_table = @(x) interp_f(mortality_0_to_14_table,x);
    [coeffs{39},fit{39},fun_text{39},modelFun{39}] = get_fit(mortality_0_to_14_table(:,1),mortality_0_to_14_table(:,2),false,false,names);
    mortality_0_to_14_table = @(x) modelFun{39}(coeffs{39},x);
    mortality_0_to_14_table=Function('f',{x_cas},{mortality_0_to_14_table(x_cas)});
    mortality_15_to_44_table=[[20,0.0266];[30,0.0171];[40,0.011];[50,0.0065];[60,0.004];[70,0.0016];[80,0.0008]];
    %     mortality_15_to_44_table = @(x) interp_f(mortality_15_to_44_table,x);
    [coeffs{41},fit{41},fun_text{41},modelFun{41}] = get_fit(mortality_15_to_44_table(:,1),mortality_15_to_44_table(:,2),false,false,names);
    mortality_15_to_44_table = @(x) modelFun{41}(coeffs{41},x);
    mortality_15_to_44_table=Function('f',{x_cas},{mortality_15_to_44_table(x_cas)});
    completed_multiplier_from_perceived_lifetime_table=[[0,3];[10,2.1];[20,1.6];[30,1.4];[40,1.3];[50,1.2];[60,1.1];[70,1.05];[80,1]];
    %     completed_multiplier_from_perceived_lifetime_table = @(x) interp_f(completed_multiplier_from_perceived_lifetime_table,x);
    [coeffs{43},fit{43},fun_text{43},modelFun{43}] = get_fit(completed_multiplier_from_perceived_lifetime_table(:,1),completed_multiplier_from_perceived_lifetime_table(:,2),false,false,names);
    completed_multiplier_from_perceived_lifetime_table = @(x) modelFun{43}(coeffs{43},x);
    completed_multiplier_from_perceived_lifetime_table=Function('f',{x_cas},{completed_multiplier_from_perceived_lifetime_table(x_cas)});
    family_response_to_social_norm_table=[[-0.2,0.5];[-0.1,0.6];[0,0.7];[0.1,0.85];[0.2,1]];
    %     family_response_to_social_norm_table = @(x) interp_f(family_response_to_social_norm_table,x);
    [coeffs{44},fit{44},fun_text{44},modelFun{44}] = get_fit(family_response_to_social_norm_table(:,1),family_response_to_social_norm_table(:,2),false,false,names);
    family_response_to_social_norm_table = @(x) modelFun{44}(coeffs{44},x);
    family_response_to_social_norm_table=Function('f',{x_cas},{family_response_to_social_norm_table(x_cas)});
    fecundity_multiplier_table=[[0,0];[10,0.2];[20,0.4];[30,0.6];[40,0.7];[50,0.75];[60,0.79];[70,0.84];[80,0.87]];
    %     fecundity_multiplier_table = @(x) interp_f(fecundity_multiplier_table,x);
    [coeffs{46},fit{46},fun_text{46},modelFun{46}] = get_fit(fecundity_multiplier_table(:,1),fecundity_multiplier_table(:,2),false,false,names);
    fecundity_multiplier_table = @(x) modelFun{46}(coeffs{46},x);
    fecundity_multiplier_table=Function('f',{x_cas},{fecundity_multiplier_table(x_cas)});
    fertility_control_effectiveness_table=[[0,0.75];[0.5,0.85];[1,0.9];[1.5,0.95];[2,0.98];[2.5,0.99];[3,1]];
    %     fertility_control_effectiveness_table=[[0,0.75];[0.5,0.85];[1,0.9];[1.5,0.93];[2,0.95];[2.5,0.96];[3,0.97];[4,0.98];[5,0.99];[6,0.993];[7,0.993];[8,0.995];[9,0.997];[10,0.999]];
    %     fertility_control_effectiveness_table = @(x) interp_f(fertility_control_effectiveness_table,x);
    [coeffs{47},fit{47},fun_text{47},modelFun{47}] = get_fit(fertility_control_effectiveness_table(:,1),fertility_control_effectiveness_table(:,2),false,false,names);
    fertility_control_effectiveness_table = @(x) modelFun{47}(coeffs{47},x);
    fertility_control_effectiveness_table=Function('f',{x_cas},{fertility_control_effectiveness_table(x_cas)});
    fraction_services_allocated_to_fertility_control_table=[[-1,0];[0,0];[2,0.005];[4,0.015];[6,0.025];[8,0.03];[10,0.035];[20,0.04];[30,0.045]];
    %     fraction_services_allocated_to_fertility_control_table = @(x) interp_f(fraction_services_allocated_to_fertility_control_table,x);
    [coeffs{49},fit{49},fun_text{49},modelFun{49}] = get_fit(fraction_services_allocated_to_fertility_control_table(:,1),fraction_services_allocated_to_fertility_control_table(:,2),false,false,names);
    fraction_services_allocated_to_fertility_control_table = @(x) modelFun{49}(coeffs{49},x);
    fraction_services_allocated_to_fertility_control_table=Function('f',{x_cas},{fraction_services_allocated_to_fertility_control_table(x_cas)});
    %     social_family_size_normal_table=[[0,1.25];[200,0.94];[400,0.715];[600,0.59];[800,0.5]];
    social_family_size_normal_table=[[0,1.25];[200,1];[400,0.9];[600,0.8];[800,0.75]];
    %     social_family_size_normal_table = @(x) interp_f(social_family_size_normal_table,x);
    [coeffs{50},fit{50},fun_text{50},modelFun{50}] = get_fit(social_family_size_normal_table(:,1),social_family_size_normal_table(:,2),false,false,names);
    social_family_size_normal_table = @(x) modelFun{50}(coeffs{50},x);
    social_family_size_normal_table=Function('f',{x_cas},{social_family_size_normal_table(x_cas)});
    crowding_multiplier_from_industry_table=[[0,0.5];[200,0.05];[400,-0.1];[600,-0.08];[800,-0.02];[1000,0.05];[1200,0.1];[1400,0.15];[1600,0.2]];
    %     crowding_multiplier_from_industry_table = @(x) interp_f(crowding_multiplier_from_industry_table,x);
    [coeffs{51},fit{51},fun_text{51},modelFun{51}] = get_fit(crowding_multiplier_from_industry_table(:,1),crowding_multiplier_from_industry_table(:,2),false,false,names);
    crowding_multiplier_from_industry_table = @(x) modelFun{51}(coeffs{51},x);
    crowding_multiplier_from_industry_table=Function('f',{x_cas},{crowding_multiplier_from_industry_table(x_cas)});
    fraction_of_population_urban_table=[[0,0];[2e+009,0.2];[4e+009,0.4];[6e+009,0.5];[8e+009,0.58];[1e+010,0.65];[1.2e+010,0.72];[1.4e+010,0.78];[1.6e+010,0.8]];
    %     fraction_of_population_urban_table = @(x) interp_f(fraction_of_population_urban_table,x);
    [coeffs{52},fit{52},fun_text{52},modelFun{52}] = get_fit(fraction_of_population_urban_table(:,1),fraction_of_population_urban_table(:,2),false,false,names);
    fraction_of_population_urban_table = @(x) modelFun{52}(coeffs{52},x);
    fraction_of_population_urban_table=Function('f',{x_cas},{fraction_of_population_urban_table(x_cas)});
    %     health_services_per_capita_table=[[0,0];[250,20];[500,50];[750,95];[1000,140];[1250,175];[1500,200];[1750,220];[2000,230]];
    health_services_per_capita_table=[[0,0];[90,7.2];[250,20];[500,50];[750,95];[1000,140];[1250,175];[1500,200];[1750,220];[2000,230]];
    %     health_services_per_capita_table = @(x) interp_f(health_services_per_capita_table,x);
    [coeffs{53},fit{53},fun_text{53},modelFun{53}] = get_fit(health_services_per_capita_table(:,1),health_services_per_capita_table(:,2),false,false,names);
    health_services_per_capita_table = @(x) modelFun{53}(coeffs{53},x);
    health_services_per_capita_table=Function('f',{x_cas},{health_services_per_capita_table(x_cas)});
    %     lifetime_multiplier_from_food_table=[[0,0];[1,1];[2,1.43];[3,1.5];[4,1.5];[5,1.5]];
    lifetime_multiplier_from_food_table=[[0,0];[1,1];[2,1.2];[3,1.3];[4,1.35];[5,1.4]];
    %     lifetime_multiplier_from_food_table = @(x) interp_f(lifetime_multiplier_from_food_table,x);
    [coeffs{55},fit{55},fun_text{55},modelFun{55}] = get_fit(lifetime_multiplier_from_food_table(:,1),lifetime_multiplier_from_food_table(:,2),false,false,names);
    lifetime_multiplier_from_food_table = @(x) modelFun{55}(coeffs{55},x);
    lifetime_multiplier_from_food_table=Function('f',{x_cas},{lifetime_multiplier_from_food_table(x_cas)});
    lifetime_multiplier_from_health_services_1_table=[[0,1];[20,1.1];[40,1.4];[60,1.6];[80,1.7];[100,1.8]];
    %     lifetime_multiplier_from_health_services_1_table = @(x) interp_f(lifetime_multiplier_from_health_services_1_table,x);
    [coeffs{57},fit{57},fun_text{57},modelFun{57}] = get_fit(lifetime_multiplier_from_health_services_1_table(:,1),lifetime_multiplier_from_health_services_1_table(:,2),false,false,names);
    lifetime_multiplier_from_health_services_1_table = @(x) modelFun{57}(coeffs{57},x);
    lifetime_multiplier_from_health_services_1_table=Function('f',{x_cas},{lifetime_multiplier_from_health_services_1_table(x_cas)});
    %     lifetime_multiplier_from_health_services_2_table=[[0,1];[20,1.5];[40,1.9];[60,2];[80,2];[100,2]];
    lifetime_multiplier_from_health_services_2_table=[[0,1];[20,1.4];[40,1.6];[60,1.8];[80,1.95];[100,2]];
    %     lifetime_multiplier_from_health_services_2_table = @(x) interp_f(lifetime_multiplier_from_health_services_2_table,x);
    [coeffs{58},fit{58},fun_text{58},modelFun{58}] = get_fit(lifetime_multiplier_from_health_services_2_table(:,1),lifetime_multiplier_from_health_services_2_table(:,2),false,false,names);
    lifetime_multiplier_from_health_services_2_table = @(x) modelFun{58}(coeffs{58},x);
    lifetime_multiplier_from_health_services_2_table=Function('f',{x_cas},{lifetime_multiplier_from_health_services_2_table(x_cas)});
    lifetime_multiplier_from_persistent_pollution_table=[[0,1];[10,0.99];[20,0.97];[30,0.95];[40,0.9];[50,0.85];[60,0.75];[70,0.65];[80,0.55];[90,0.4];[100,0.2]];
    %     lifetime_multiplier_from_persistent_pollution_table=[[0,1];[2,0.999];[4,0.998];[6,0.997];[8,0.996];[10,0.99];[20,0.97];[30,0.95];[40,0.9];[50,0.85];[60,0.75];[70,0.65];[80,0.55];[90,0.4];[100,0.2];[200,0.01];[300,0.01];[400,0.001]];
    %     lifetime_multiplier_from_persistent_pollution_table = @(x) interp_f(lifetime_multiplier_from_persistent_pollution_table,x);
    [coeffs{59},fit{59},fun_text{59},modelFun{59}] = get_fit(lifetime_multiplier_from_persistent_pollution_table(:,1),lifetime_multiplier_from_persistent_pollution_table(:,2),false,false,names);
    lifetime_multiplier_from_persistent_pollution_table = @(x) modelFun{59}(coeffs{59},x);
    lifetime_multiplier_from_persistent_pollution_table=Function('f',{x_cas},{lifetime_multiplier_from_persistent_pollution_table(x_cas)});
    fraction_of_capital_allocated_to_obtaining_resources_1_table=[[0,1];[0.1,0.9];[0.2,0.7];[0.3,0.5];[0.4,0.2];[0.5,0.1];[0.6,0.05];[0.7,0.05];[0.8,0.05];[0.9,0.05];[1,0.05]];
    %     fraction_of_capital_allocated_to_obtaining_resources_1_table = @(x) interp_f(fraction_of_capital_allocated_to_obtaining_resources_1_table,x);
    [coeffs{60},fit{60},fun_text{60},modelFun{60}] = get_fit(fraction_of_capital_allocated_to_obtaining_resources_1_table(:,1),fraction_of_capital_allocated_to_obtaining_resources_1_table(:,2),false,false,names);
    fraction_of_capital_allocated_to_obtaining_resources_1_table = @(x) modelFun{60}(coeffs{60},x);
    fraction_of_capital_allocated_to_obtaining_resources_1_table=Function('f',{x_cas},{fraction_of_capital_allocated_to_obtaining_resources_1_table(x_cas)});
    fraction_of_capital_allocated_to_obtaining_resources_2_table=[[0,1];[0.1,0.2];[0.2,0.1];[0.3,0.05];[0.4,0.05];[0.5,0.05];[0.6,0.05];[0.7,0.05];[0.8,0.05];[0.9,0.05];[1,0.05]];
    %     fraction_of_capital_allocated_to_obtaining_resources_2_table = @(x) interp_f(fraction_of_capital_allocated_to_obtaining_resources_2_table,x);
    [coeffs{61},fit{61},fun_text{61},modelFun{61}] = get_fit(fraction_of_capital_allocated_to_obtaining_resources_2_table(:,1),fraction_of_capital_allocated_to_obtaining_resources_2_table(:,2),false,false,names);
    fraction_of_capital_allocated_to_obtaining_resources_2_table = @(x) modelFun{61}(coeffs{61},x);
    fraction_of_capital_allocated_to_obtaining_resources_2_table=Function('f',{x_cas},{fraction_of_capital_allocated_to_obtaining_resources_2_table(x_cas)});
%     resource_technology_change_mult_table=[[-1,0];[0,0]];
    resource_technology_change_mult_table=[[-1,0];[0,0];[1,0]];
    %     resource_technology_change_mult_table = @(x) interp_f(resource_technology_change_mult_table,x);
    [coeffs{62},fit{62},fun_text{62},modelFun{62}] = get_fit(resource_technology_change_mult_table(:,1),resource_technology_change_mult_table(:,2),false,false,names);
    resource_technology_change_mult_table = @(x) modelFun{62}(coeffs{62},x);
    resource_technology_change_mult_table=Function('f',{x_cas},{resource_technology_change_mult_table(x_cas)});
    %     per_capita_resource_use_mult_table=[[0,0];[200,0.85];[400,2.6];[600,3.4];[800,3.8];[1000,4.1];[1200,4.4];[1400,4.7];[1600,5]];
    per_capita_resource_use_mult_table=[[0,0];[200,0.85];[400,2.6];[600,4.4];[800,5.4];[1000,6.2];[1200,6.8];[1400,7.0];[1600,7.0]];
    %     per_capita_resource_use_mult_table=[[0,0];[20,0.085];[40,0.17];[100,0.43];[200,0.85];[400,2.6];[600,4.4];[800,5.4];[1000,6.2];[1200,6.8];[1400,7.0];[1600,7.0]];
    %     per_capita_resource_use_mult_table = @(x) interp_f(per_capita_resource_use_mult_table,x);
    [coeffs{63},fit{63},fun_text{63},modelFun{63}] = get_fit(per_capita_resource_use_mult_table(:,1),per_capita_resource_use_mult_table(:,2),false,false,names);
    per_capita_resource_use_mult_table = @(x) modelFun{63}(coeffs{63},x);
    per_capita_resource_use_mult_table=Function('f',{x_cas},{per_capita_resource_use_mult_table(x_cas)});
end


%% Calibrated Params:
disp('Generating parameters...')

persistent_pollution_transmission_delay=20;
% arable_land_erosion_factor=0.92;
% w3_real_exhange_rate=7.18783;
LIFE_TIME_MULTIPLIER_FROM_SERVICES=1;%0.557;
% investment_into_services=1;%2.07;
GDP_pc_unit=1;
unit_agricultural_input=1;
unit_population=1;
ha_per_Gha=1e+009;
% ha_per_unit_of_pollution=4;
one_year=1;
% Ref_Hi_GDP=9508;
% Ref_Lo_GDP=24;
% Total_Land=1.91;
% land_fraction_harvested=0.7;%0.68;
potentially_arable_land_total=3.2e+009/norm.('Potentially_Arable_Land');
% processing_loss=0.1;%0.35;
% desired_food_ratio=2;
IND_OUT_IN_1970=7.9e+011/norm.('industrial_output');
average_life_of_agricultural_inputs_1=2;
average_life_of_agricultural_inputs_2=2;
% land_yield_factor_1=1;%1.634;
% air_pollution_policy_implementation_time=4000;
% average_life_of_land_normal=6000/norm.('average_life_of_land');%1000;
% land_life_policy_implementation_time=4000;
urban_and_industrial_land_development_time=10;
% inherent_land_fertility=600;
food_shortage_perception_delay=2;
subsistence_food_per_capita=230/norm.('food_per_capita');
% social_discount=0.07;
% industrial_output_per_capita_desired=400;
average_life_of_industrial_capital_1=14/norm.('average_life_of_industrial_capital');
average_life_of_industrial_capital_2=14/norm.('average_life_of_industrial_capital');
fraction_of_industrial_output_allocated_to_consumption_const_1=0.43;
fraction_of_industrial_output_allocated_to_consumption_const_2=0.43;
% industrial_capital_output_ratio_1=3;%3.64;
% industrial_equilibrium_time=4000;
labor_force_participation_fraction=0.75;
labor_utilization_fraction_delay_time=2;
average_life_of_service_capital_1=24.07/norm.('average_life_of_service_capital');
average_life_of_service_capital_2=20/norm.('average_life_of_service_capital');
% service_capital_output_ratio_1=1;%0.579;
service_capital_output_ratio_2=1;
% FINAL_TIME=2100;
% INITIAL_TIME=1995;
% SAVEPER=1;
% POLICY_YEAR=2101;
% TIME_STEP=0.0078125;
agricultural_material_toxicity_index=1;
assimilation_half_life_in_1970=1.5/norm.('assimilation_half_life');%0.95;
% desired_persistent_pollution_index=1.2;
% fraction_of_agricultural_inputs_from_persistent_materials=0.001;
% fraction_of_resources_from_persistent_materials=0.02;
% industrial_material_toxicity_index=10;
% industrial_material_emissions_factor=0.1;
% persistent_pollution_generation_factor_1=1;%0;
persistent_pollution_in_1970=1.36e+008/norm.('Persistent_Pollution');%2.5e7;
% desired_completed_family_size_normal=4;%3.412;
income_expectation_averaging_time=3;%3.572;
lifetime_perception_delay=20;%23.54;
% maximum_total_fertility_normal=12;
reproductive_lifetime=30;
social_adjustment_delay=20;%26;
% fertility_control_effectiveness_time=4000;
% population_equilibrium_time=4000;
% zero_population_growth_time=4000;
% THOUSAND=1000;
health_services_impact_delay=20;%24.977;
% life_expectancy_normal=28;
desired_resource_use_rate=4.8e+009/norm.('resource_usage_rate');
% resource_use_factor_1=1;%0;
% frac_of_ind_capital_allocated_to_obtaining_res_switch_time=1990;
technology_development_delay=20;
% PRICE_OF_FOOD=0.22;
Nonrenewable_Resources_1950=947945000000/norm.('Nonrenewable_Resources');

world_inflation_param1=2.7304;
world_inflation_param2=-2.1527;
world_inflation_param3=0.0950;
world_inflation_param4=0.3307;

inflation_param1_val=0.4174;
inflation_param2_val=0.0741;
inflation_param3_val=0.1266;
inflation_param4_val=-0.0212;
inflation_param5_val=-0.0718;
inflation_param6_val=-0.0865;

%% params to estimate
param_names = ["maximum_total_fertility_normal";...
    "desired_completed_family_size_normal";...
    "land_fraction_harvested";...
    "desired_food_ratio";...
    "inherent_land_fertility";...
    "inv_industrial_output_per_capita_desired";...
    "inv_desired_persistent_pollution_index";...
    "inv_social_discount";...
    "industrial_capital_output_ratio_1";...
    "investment_into_services";...
    "processing_loss";...
    "average_life_of_land_normal";...
    "fraction_of_agricultural_inputs_from_persistent_materials";...
    "fraction_of_resources_from_persistent_materials";...
    "industrial_material_toxicity_index";...
    "industrial_material_emissions_factor";...
    "persistent_pollution_generation_rate_factor";...
    "life_expectancy_normal";...
    "fcfpc_param";...
    "le_param1";...
    "le_param2";...
    "diopc_param1";...
    "diopc_param2";...
    "resource_use_factor_1";...
    "ppar_param1";...
    "ppar_param2";...
    "ppar_param3";...
    "persistent_pollution_generation_factor_1";...
    "land_yield_factor_1";...
    "service_capital_output_ratio_1";...
    "inflation_param1";...
    "inflation_param2";...
    "inflation_param3";...
    "inflation_param4";...
    "inflation_param5";...
    "inflation_param6";...
%     "inflation_init_1";...
%     "inflation_init_2";...
%     "inflation_init_3";...
%     "inflation_init_4";...
    ];

n_params = length(param_names);

params = SX.sym('params',n_params,1);
for p = 1:n_params
   eval([char(param_names(p)) ' = SX.sym(''' char(param_names(p)) ''',1,1);']);
   eval(['params(p) =  ' char(param_names(p)) ';']);
end

%%% TO DO: get proper initial guesses for:
% fcfpc_param
% inherent_land_fertility

%%% TO DO: put this in a separate file and then load it
param_settings.lower_bound.maximum_total_fertility_normal = 12;%8;%2;
param_settings.init_param_guess.maximum_total_fertility_normal = 12;
param_settings.upper_bound.maximum_total_fertility_normal = 12;%16;%20;

param_settings.lower_bound.desired_completed_family_size_normal = 3.3;%3;%1;
param_settings.init_param_guess.desired_completed_family_size_normal = 3.3;%4;
param_settings.upper_bound.desired_completed_family_size_normal = 3.3;%5;%8;

param_settings.lower_bound.land_fraction_harvested = 0.7;%0.5;%0.4;
param_settings.init_param_guess.land_fraction_harvested = 0.7;
param_settings.upper_bound.land_fraction_harvested = 0.7;%0.9;%1;

param_settings.lower_bound.desired_food_ratio = 2;%1;
param_settings.init_param_guess.desired_food_ratio = 2;
param_settings.upper_bound.desired_food_ratio = 2;%3;%5;

param_settings.lower_bound.inherent_land_fertility = 6;%5;
param_settings.init_param_guess.inherent_land_fertility = 6;
param_settings.upper_bound.inherent_land_fertility = 6;%10;

param_settings.lower_bound.inv_industrial_output_per_capita_desired = 1/400;%0.0001;
param_settings.init_param_guess.inv_industrial_output_per_capita_desired = 1/400;
param_settings.upper_bound.inv_industrial_output_per_capita_desired = 1/400;%2/400;%0.01;

param_settings.lower_bound.inv_desired_persistent_pollution_index = 1/1.2;%0.5;
param_settings.init_param_guess.inv_desired_persistent_pollution_index = 1/1.2;
param_settings.upper_bound.inv_desired_persistent_pollution_index = 1/1.2;%1;

param_settings.lower_bound.inv_social_discount = 1/0.07;%14;%1;
param_settings.init_param_guess.inv_social_discount = 1/0.07;
param_settings.upper_bound.inv_social_discount = 1/0.07;%15;%14.5;%50;

param_settings.lower_bound.industrial_capital_output_ratio_1 = 3;%2.9;%2.95;%1;
param_settings.init_param_guess.industrial_capital_output_ratio_1 = 3;
param_settings.upper_bound.industrial_capital_output_ratio_1 = 3;%3.05;%10;

param_settings.lower_bound.investment_into_services = 1;%0.1;
param_settings.init_param_guess.investment_into_services = 1;
param_settings.upper_bound.investment_into_services = 1;%3;

param_settings.lower_bound.processing_loss = 0.1;%0;
param_settings.init_param_guess.processing_loss = 0.1;
param_settings.upper_bound.processing_loss = 0.1;%0.3;%0.2;

param_settings.lower_bound.average_life_of_land_normal = 6;%5.5;%1;
param_settings.init_param_guess.average_life_of_land_normal = 6;
param_settings.upper_bound.average_life_of_land_normal = 6;%6.5;%10;

param_settings.lower_bound.fraction_of_agricultural_inputs_from_persistent_materials = 0.001;%0.0001;
param_settings.init_param_guess.fraction_of_agricultural_inputs_from_persistent_materials = 0.001;
param_settings.upper_bound.fraction_of_agricultural_inputs_from_persistent_materials = 0.001;%0.1;

param_settings.lower_bound.fraction_of_resources_from_persistent_materials = 0.02;%0.0001;
param_settings.init_param_guess.fraction_of_resources_from_persistent_materials = 0.02;
param_settings.upper_bound.fraction_of_resources_from_persistent_materials = 0.02;%0.1;

param_settings.lower_bound.industrial_material_toxicity_index = 10;%9;%0.1;
param_settings.init_param_guess.industrial_material_toxicity_index = 10;
param_settings.upper_bound.industrial_material_toxicity_index = 10;%11;%100;

param_settings.lower_bound.industrial_material_emissions_factor = 0.1;%0.0001;
param_settings.init_param_guess.industrial_material_emissions_factor = 0.1;
param_settings.upper_bound.industrial_material_emissions_factor = 0.1;%1;

param_settings.lower_bound.persistent_pollution_generation_rate_factor = (0.5*3/persistent_pollution_transmission_delay)^3;%10^-5;
param_settings.init_param_guess.persistent_pollution_generation_rate_factor = (0.5*3/persistent_pollution_transmission_delay)^3;
param_settings.upper_bound.persistent_pollution_generation_rate_factor = (0.5*3/persistent_pollution_transmission_delay)^3;%10^-3;

param_settings.lower_bound.life_expectancy_normal = 28;%20;
param_settings.init_param_guess.life_expectancy_normal = 28;
param_settings.upper_bound.life_expectancy_normal = 28;%60;%50;

param_settings.lower_bound.fcfpc_param = 0.002;%0;
param_settings.init_param_guess.fcfpc_param = 0.002;
param_settings.upper_bound.fcfpc_param = 0.002;%5;

param_settings.lower_bound.le_param1 = 0.02;%0;
param_settings.init_param_guess.le_param1 = 0.02;
param_settings.upper_bound.le_param1 = 0.02;%5;

param_settings.lower_bound.le_param2 = 1;%0;
param_settings.init_param_guess.le_param2 = 1;
param_settings.upper_bound.le_param2 = 1;%5;

param_settings.lower_bound.diopc_param1 = 0.915;%0;
param_settings.init_param_guess.diopc_param1 = 0.915;
param_settings.upper_bound.diopc_param1 = 0.915;%5;

param_settings.lower_bound.diopc_param2 = 1.05;%0;
param_settings.init_param_guess.diopc_param2 = 1.05;
param_settings.upper_bound.diopc_param2 = 1.05;%5;

param_settings.lower_bound.resource_use_factor_1 = 0.9;%0;
param_settings.init_param_guess.resource_use_factor_1=1.1;%1;%0.61;
param_settings.upper_bound.resource_use_factor_1 = 1.3;%1.2;%5;

param_settings.lower_bound.ppar_param1 = (1	+	1/(-5	+	1/(5	+	1/(-8	-	1/3))));%0.7415;%-5;
param_settings.init_param_guess.ppar_param1 = (1	+	1/(-5	+	1/(5	+	1/(-8	-	1/3))));
param_settings.upper_bound.ppar_param1 = (1	+	1/(-5	+	1/(5	+	1/(-8	-	1/3))));%0.8;%5;

param_settings.lower_bound.ppar_param2 = (-3	+	1/(2	+	1/(3	+	1/(4	+	1/(5	+	1/10)))));%-2.5769;%-5;
param_settings.init_param_guess.ppar_param2 = (-3	+	1/(2	+	1/(3	+	1/(4	+	1/(5	+	1/10)))));
param_settings.upper_bound.ppar_param2 = (-3	+	1/(2	+	1/(3	+	1/(4	+	1/(5	+	1/10)))));%-2.5569;%5;

param_settings.lower_bound.ppar_param3 = (0.5*3*(1+3*12)/20);%2.7650;%-5;
param_settings.init_param_guess.ppar_param3 = (0.5*3*(1+3*12)/20);
param_settings.upper_bound.ppar_param3 = (0.5*3*(1+3*12)/20);%2.7850;%5;

param_settings.lower_bound.persistent_pollution_generation_factor_1 = 1.017;%0.95;%0;
param_settings.init_param_guess.persistent_pollution_generation_factor_1 = 1.017;%1;
param_settings.upper_bound.persistent_pollution_generation_factor_1 = 1.017;%1.05;%5;

param_settings.lower_bound.land_yield_factor_1 = 1;%0;
param_settings.init_param_guess.land_yield_factor_1 = 1;%1.86;
param_settings.upper_bound.land_yield_factor_1 = 1.1;%5;

param_settings.lower_bound.service_capital_output_ratio_1 = 1;%0.9;%0;
param_settings.init_param_guess.service_capital_output_ratio_1 = 1;%0.56;
param_settings.upper_bound.service_capital_output_ratio_1 = 1;%1.1;%5;

% NOTE: these are now estimated separately
param_settings.lower_bound.inflation_param1 = inflation_param1_val;
param_settings.init_param_guess.inflation_param1 = inflation_param1_val;
param_settings.upper_bound.inflation_param1 = inflation_param1_val;

param_settings.lower_bound.inflation_param2 = inflation_param2_val;
param_settings.init_param_guess.inflation_param2 = inflation_param2_val;
param_settings.upper_bound.inflation_param2 = inflation_param2_val;

param_settings.lower_bound.inflation_param3 = inflation_param3_val;
param_settings.init_param_guess.inflation_param3 = inflation_param3_val;
param_settings.upper_bound.inflation_param3 = inflation_param3_val;

param_settings.lower_bound.inflation_param4 = inflation_param4_val;
param_settings.init_param_guess.inflation_param4 = inflation_param4_val;
param_settings.upper_bound.inflation_param4 = inflation_param4_val;

param_settings.lower_bound.inflation_param5 = inflation_param5_val;
param_settings.init_param_guess.inflation_param5 = inflation_param5_val;
param_settings.upper_bound.inflation_param5 = inflation_param5_val;%10;

param_settings.lower_bound.inflation_param6 = inflation_param6_val;
param_settings.init_param_guess.inflation_param6 = inflation_param6_val;
param_settings.upper_bound.inflation_param6 = inflation_param6_val;%10;

% param_settings.lower_bound.inflation_init_1 = -10;
% param_settings.init_param_guess.inflation_init_1 = 5.7;
% param_settings.upper_bound.inflation_init_1 = 20;
% 
% param_settings.lower_bound.inflation_init_2 = -10;
% param_settings.init_param_guess.inflation_init_2 = 5.7;
% param_settings.upper_bound.inflation_init_2 = 20;
% 
% param_settings.lower_bound.inflation_init_3 = -10;
% param_settings.init_param_guess.inflation_init_3 = 5.7;
% param_settings.upper_bound.inflation_init_3 = 20;
% 
% param_settings.lower_bound.inflation_init_4 = -10;
% param_settings.init_param_guess.inflation_init_4 = 5.7;
% param_settings.upper_bound.inflation_init_4 = 20;

% initial parameter guess
try
    disp("loading initial guess from mat file...")
    load('param_mean.mat');
    if length(param_means)~=n_params
        error(['param_mean.mat contains ' num2str(length(param_means)) ' parameter values but ' num2str(n_params) ' are required. Using param_settings values instead...'])
    else
        init_param_guess = param_means;
    end
catch
    init_param_guess = nan(n_params,1);
    for p = 1:n_params
        init_param_guess(p) = param_settings.init_param_guess.(param_names(p));
    end
    init_param_guess = init_param_guess;
end
if size(init_param_guess,2)>1 % make it a column vector
    init_param_guess = init_param_guess';
end

% parameter lower bounds
param_lb = nan(n_params,1);
for p = 1:n_params
    if est_params
    param_lb(p) = param_settings.lower_bound.(param_names(p));
    else
    param_lb(p) = param_settings.init_param_guess.(param_names(p));
    end
end
param_lb = param_lb;

% parameter upper bounds
param_ub = nan(n_params,1);
for p = 1:n_params
    if est_params
    param_ub(p) = param_settings.upper_bound.(param_names(p));
    else
    param_ub(p) = param_settings.init_param_guess.(param_names(p));
    end
end
param_ub = param_ub;

%% initial conditions are for 1950. If dt = 0.25, a shift=-40 implies a shift in 1940, 100=1975
shift_all = T+1;
shift_fraction_of_industrial_output_allocated_to_agriculture=shift_all;
shift_indicated_food_per_capita=shift_all;
shift_average_life_agricultural_inputs=shift_all;
% shift_resource_technology_change_rate=max(0,(301-est_start)/(dt*4));%shift_all;
shift_fraction_of_industrial_capital_for_obtaining_resources=shift_all;
% shift_resource_use_factor=max(0,(341-est_start)/(dt*4));%shift_all;
% shift_lifetime_multiplier_from_health_services=max(0,(161-est_start)/(dt*4));
shift_fertility_control_effectiveness=T*10;%shift_all;
shift_births=T*10;%shift_all;
shift_desired_completed_family_size=T*10;%shift_all;
shift_persistent_pollution_technology_change_rate=shift_all;
% shift_persistent_pollution_generation_factor=max(0,(321-est_start)/(dt*4));%shift_all;
shift_average_life_of_service_capital=0;%shift_all;
shift_fraction_of_industrial_output_allocated_to_services=shift_all;
shift_indicated_services_output_per_capita=shift_all;
shift_service_capital_output_ratio=shift_all;
shift_average_life_of_industrial_capital=shift_all;
shift_fraction_of_industrial_output_allocated_to_consumption=shift_all;
shift_industrial_capital_output_ratio=shift_all;
shift_fraction_of_industrial_output_for_consumption_const=shift_all;
shift_land_yield_multiplier_from_technology=shift_all;
shift_land_yield_multiplier_from_air_pollution=shift_all;
shift_land_yield_technology_change_rate=shift_all;
shift_land_life_multiplier_from_land_yield=shift_all;


shift_resource_technology_change_rate=SX.sym('shift_resource_technology_change_rate',[1,1]);
shift_resource_use_factor=SX.sym('shift_resource_use_factor',[1,1]);
shift_lifetime_multiplier_from_health_services=SX.sym('shift_lifetime_multiplier_from_health_services',[1,1]);
shift_persistent_pollution_generation_factor=SX.sym('shift_persistent_pollution_generation_factor',[1,1]);

shifts = [shift_resource_technology_change_rate;...
            shift_resource_use_factor;...
            shift_lifetime_multiplier_from_health_services;...
            shift_persistent_pollution_generation_factor];
        
shift_times = [(301-est_start)/(dt*4);...
                (341-est_start)/(dt*4);...
                (161-est_start)/(dt*4);...
                (321-est_start)/(dt*4)];

%% load a simulation
% this is needed to initialize unobserved state variables
load("world3_sim2.mat"); % load the simulation trajectory (state variable values are needed for this estimation method)
if isstruct(sim_traj)
    sim_traj = struct2array(sim_traj)';
end
if size(sim_traj,1)~=n_var
   error('a simulated trajectory is not available for all variables. Check that your simulation (such as World3g) has all of the required variables and that its output has been saved to world3_sim.mat') 
end
if dt~=0.5 % assume that sim_traj has been generated with dt=0.5, since the equations seem to work best with that step length for some reason
   sim_traj_temp = nan(n_var,T+H);
   try
       sim_traj_temp(:,1:max(1,1/(2*dt)):T+H) = sim_traj(:,est_start-201+1:max(1,dt*2):(est_start-201+T+H)*max(1,dt*2)/max(1,1/(2*dt)));
   catch
       sim_traj_temp(:,1:max(1,1/(2*dt)):T+H-1) = sim_traj(:,est_start-201+1:max(1,dt*2):(est_start-201+T+H)*max(1,dt*2)/max(1,1/(2*dt)));
   end
   sim_traj = lin_interp(sim_traj_temp')';
end

%% Dynamics:
disp('Generating equations...')

eq = cell(minT,1);
ineq2eq = cell(minT,1);

% allocate space in memory for equations
for var = 1:n_var
    eval([var_names{var} ' = cell(minT,1);']);
end

% allocate space in memory for initial states and collect them in the init_vars array
init_vars = SX.sym('init',[n_var+8,1]);
for var = 1:n_var
    eval([var_names{var} '_init = SX.sym(''' var_names{var} '_init'',[1,1]);' ])
    
    eval(['init_vars(' num2str(var) ') = ' var_names{var} '_init;']); % collect all initial conditions
end
inflation_init_1 = SX.sym('inflation_init_1',[1,1]);
inflation_init_2 = SX.sym('inflation_init_2',[1,1]);
inflation_init_3 = SX.sym('inflation_init_3',[1,1]);
inflation_init_4 = SX.sym('inflation_init_4',[1,1]);

world_inflation_init_1 = SX.sym('world_inflation_init_1',[1,1]);
world_inflation_init_2 = SX.sym('world_inflation_init_2',[1,1]);
world_inflation_init_3 = SX.sym('world_inflation_init_3',[1,1]);
world_inflation_init_4 = SX.sym('world_inflation_init_4',[1,1]);
init_vars(n_var+1:n_var+8) = [inflation_init_1;inflation_init_2;inflation_init_3;inflation_init_4;world_inflation_init_1;world_inflation_init_2;world_inflation_init_3;world_inflation_init_4];

for t = 1:minT
World3_eqns;
end

%% estimation
opts.use_shocks = true; % shocks variables are used in the estimation procedure, but are penalized according to lambda2
opts.lambda1 = 0; %regularization parameter for estimated params
opts.lambda2 = 10^6; %regularization parameter for shocks
opts.regression_type = 'ridge'; % options: ridge, lasso, OLS
opts.solver = 'ipopt'; % options: sqpmethod, blocksqp, qrsqp, bonmin, cplex, gurobi, SNOPT, WORHP and KNITRO
opts.try_fancy_shock_initialization = false; % true: run a simulation to get residuals of equations from initial parameter guesses and use those for the shock values. false: initialize shocks at zero
opts.sim_opts.nlpsol = 'ipopt';
opts.sim_opts.dump_out = true;
opts.sim_opts.error_on_fail = false;
opts.est_opts.ipopt.max_iter = 30000; % default is 3000
opts.est_opts.ipopt.hessian_approximation='limited-memory';

count = 1;
% TO DO: run this in parallel
% for t = 1:est_iter_period-1:T-est_iter_period+1
for t = 1:est_iter_period:T
    % initial state for each variable
    %     init_states = nan(n_var,1);
%     for v = 1:n_var
%         init_states(v) = World3_init_guesses.(var_names{v})/norm.(var_names{v});
%     end
%     if ~skip_ML
    %     init_vars = SX.sym('init',[n_var,1]);
    init_var_vals = nan(n_var+4,1);
        for var = 1:n_var
            if ~isempty(find(var==obs_var_inds))
            eval([var_names{var} '_init = ' num2str(non_nan_data(t,find(var==obs_var_inds))) ';']); % assign values to initial conditions    
            else
            eval([var_names{var} '_init = ' num2str(sim_traj(var,t)) ';']); % assign values to initial conditions
            end
            
            eval(['init_var_vals(' num2str(var) ') = ' var_names{var} '_init;']); % collect all initial conditions
        end
        init_var_vals(n_var+1) = infq_data_CAN(est_start+t-1); %inflation_init_1
        init_var_vals(n_var+2) = infq_data_CAN(est_start+t-2); %inflation_init_2
        init_var_vals(n_var+3) = infq_data_CAN(est_start+t-3); %inflation_init_3
        init_var_vals(n_var+4) = infq_data_CAN(est_start+t-4); %inflation_init_4
        
        init_var_vals(n_var+5) = infq_data_world(est_start+t-1); %inflation_init_1
        init_var_vals(n_var+6) = infq_data_world(est_start+t-2); %inflation_init_2
        init_var_vals(n_var+7) = infq_data_world(est_start+t-3); %inflation_init_3
        init_var_vals(n_var+8) = infq_data_world(est_start+t-4); %inflation_init_4
        
%     end

    % create system of equations for nonlinear estimation
    for i = 1:minT
        % construct equations
        eq{i} = SX.sym('eq',[n_var,1]);

        for v = 1:n_var
            %         if ismember(v,obs_var_inds)
            % just add shocks for observed variables
            %             eval(['eq{' num2str(t) '}(' num2str(v) ') = ' var_names{v} '{' num2str(t) '} + shocks{' num2str(t) '}(' num2str(v) ');']);
            %             eval(['eq{' num2str(t) '}(' num2str(v) ') = ' var_names{v} '{' num2str(t) '} + all_shocks(' num2str(v) ',' num2str(t) ');']);
            %         else
            eval(['eq{' num2str(i) '}(' num2str(v) ') = ' var_names{v} '{' num2str(i) '};']);
            %         end
        end

        shocks_vec = vertcat(shocks{1:i});
        if opts.use_shocks
            shocks_val = shocks_vec;
        else
            shocks_val = zeros(n_shocks*i,1);
        end
        eq_fun{i} = Function('eq',{params,init_vars,shifts,shocks_vec},{[eq{i}]});
        ineq_fun{i} = Function('ineq',{params,init_vars,shifts,shocks_vec},{[ineq2eq{i}]});
%         no_shocks{i} = zeros(length(shocks{i}),1);
        
        if i<=est_iter_period
            eq_est{i} = eq_fun{i}(params,init_var_vals,shift_times-t+1,shocks_val);
            ineq_est{i} = ineq_fun{i}(params,init_var_vals,shift_times-t+1,shocks_val);
        end
    end

    if est_params
 % solve regression problem
    disp('Estimating parameters...')
    tic
    [est_params,traj,shock_sol,flag] = nonlin_est_v4(non_nan_data(t:t+est_iter_period-1,:),eq_est,ineq_est,obs_var_inds,{shocks{1:est_iter_period}},params,init_param_guess,param_lb,param_ub,opts);
% [est_params,traj,shock_sol] = nonlin_est_v4(non_nan_data(tt:tt+est_iter_period-1,:),eq_est,ineq_est,obs_var_inds,shocks,params,init_param_guess,init_param_guess-abs(init_param_guess)*0.00,init_param_guess+abs(init_param_guess)*0.00,opts);
    est_time = toc
    
    param_sol{count} = est_params;
    sol_flags{count}=flag;
    count = count+1;
    end
end

%% estimate inflation parameters
if est_infq_params
infl_params = AR_est_world3(data(1:T,find(strcmp(obs_vars,"inflation_CAN"))),[data(1:T,find(strcmp(obs_vars,"Nonrenewable_Resources")))/Nonrenewable_Resources_1950,data(1:T,find(strcmp(obs_vars,"GDP_per_capita")))/10^4],4);
end
%% save parameter results

if est_params
param_sols = horzcat(param_sol{:});
if size(param_sols,2)==1
    param_means=param_sols';
else
    param_means = [mean(param_sols')];
end
param_means(end-5:end)=infl_params; % use independently estimated parameters
param_stds = [std(param_sols')];

save('param_mean.mat','param_means')
save('param_sols.mat','param_sols')
else
param_means = init_param_guess;
if est_infq_params
   param_means(end-5:end)=infl_params; % use independently estimated parameters 
end
end

%% in sample trajectories
% for tt = 1:H:T
%     for h = 1:H
for tt = 1:est_iter_period:T
    for h = 1:est_iter_period
        % add specific shocks
        no_shocks{tt+h-1} = zeros(n_shocks,1);
        
        % run the simulation
        sim_eq{tt+h-1} = eq_fun{h}(param_means,[sim_traj(:,tt);infq_data_CAN(est_start+tt-1);infq_data_CAN(est_start+tt-2);infq_data_CAN(est_start+tt-3);infq_data_CAN(est_start+tt-4);infq_data_world(est_start+tt-1);infq_data_world(est_start+tt-2);infq_data_world(est_start+tt-3);infq_data_world(est_start+tt-4)],shift_times-tt-h+1,zeros(n_shocks*h,1));
    end
end
% [in_sample_traj] = nonlin_sim4b(sim_eq,[],shocks,no_shocks,params,param_means);
in_sample_traj = full(evalf(horzcat(sim_eq{:})));
save('in_sample_traj.mat','in_sample_traj')

%% save Jacobian (optional)
if eval_jacobian
eq_vars=SX.sym('eqns',[2*n_var, 1]);
tt=3;
for v = 1:n_var
    eval([var_names{v} '_t=SX.sym(''' var_names{v} '_t'',[1,1]);']);
    eval([var_names{v} '{' num2str(tt-1) '}=SX.sym(''' var_names{v} '_tm1'',[1,1]);']);
%     eval([var_names{v} '_tm1=SX.sym(''' var_names{v} '_tm1'',[1,1]);']);
    eval(['eq_vars(' num2str(v) ') = ' var_names{v} '_t;']);
    eval(['eq_vars(' num2str(n_var+v) ') = ' var_names{v} '{' num2str(tt-1) '};']);   
%     eval(['eq_vars(' num2str(n_var+v) ') = ' var_names{v} '_tm1;']);   
end
t=tt;
World3_eqns;

residual = SX.sym('res',[n_var,1]);
for v = 1:n_var
    eval(['residual(' num2str(v) ') = ' var_names{v} '_t - ' var_names{v} '{' num2str(tt) '};']); % var_names{v}_t  for the symbolic LHS and var_names{v}{3} for the RHS of the dynamic system
end

% Symbolic residual only (without evaluating it yet)
residual_expr = Function('residual_expr',{params,eq_vars,init_vars,shifts,vertcat(shocks{1:tt})},{residual});
% Symbolically define jacobian of residual wrt eq_vars
world3_jac = jacobian(residual, eq_vars);
% Create symbolic function for the Jacobian
world3_jac_eq = Function('jacobian',{params,eq_vars,init_vars,shifts,vertcat(shocks{1:tt})},{world3_jac});
% evaluate using the sim trajectory
world3_jac_eval = world3_jac_eq(init_param_guess, reshape(in_sample_traj(:,tt-1:tt),n_var*2,1), init_var_vals, shift_times-tt+1, zeros(n_shocks*tt,1));
% remove inflation vars
% world3_jac_eval = world3_jac_eval(:,1:n_var); 

% use evaluated jacobian as transition matrix
Trans_mat = full(evalf(world3_jac_eval));
edge_list{1}=["Edge Weight","Target","Source"];
counter = 2;
for i = 1:size(Trans_mat,1)
    for j = 1:size(Trans_mat,2)
        if Trans_mat(i,j)~=0 && i~=j && i+n_var~=j
            if j>n_var
                edge_list{counter}=[-Trans_mat(i,j),var_names(i),var_names(j-n_var)];
            else
                edge_list{counter}=[-Trans_mat(i,j),var_names(i),var_names(j)];
            end
           counter = counter + 1;
        end
    end
end
Table = array2table(vertcat(edge_list{:}));
writetable(Table,'edges_World3.csv','WriteRowNames',false,'WriteVariableNames',false)

timeline{1}=["name",dates{1:T}];
for i = 1:length(var_names)
   timeline{i+1} = [string(var_names{i}),in_sample_traj(i,1:T)];
end
Table2=array2table(vertcat(timeline{:}));
writetable(Table2,'nodes_World3.csv','WriteRowNames',false,'WriteVariableNames',false)
end
%% forecasting
disp('Forecasting...')

% to do: use names and then search var_names
vars_to_plot = ["population";... %1
                "food_per_capita";... %2
                "industrial_output_per_capita";... %3
                "Persistent_Pollution";... %4
                "Nonrenewable_Resources";... %5
                "inflation_CAN";... %6
                "land_yield";... %7
                "Arable_Land";... %8
                "Land_Fertility";... %9
                "land_yield_multiplier_from_capital";... %10
                "agricultural_input_per_hectare";... %11
                "Agricultural_Inputs";... %12
                "fraction_of_resources_remaining";... %13
                "GDP_per_capita";... %14
                ];
for v = 1:length(vars_to_plot)
    var_inds_to_plot(v) = find(strcmp(vars_to_plot(v),var_names));
    plot_norm(v) = 10^floor(log10(max(abs(sim_traj(var_inds_to_plot(v),1)),1)));
end

% set up initial conditions using obs data and sim_traj
forecast_init = nan(n_var+8,1);
for var = 1:n_var
    if ~isempty(find(var==obs_var_inds))
    forecast_init(var) = non_nan_data(T,find(var==obs_var_inds)); % assign values to initial conditions    
    else
    forecast_init(var) = in_sample_traj(var,T); % assign values to initial conditions
    end
end
forecast_init(n_var+1:n_var+8)=[infq_data_CAN(est_start+T-1);infq_data_CAN(est_start+T-2);infq_data_CAN(est_start+T-3);infq_data_CAN(est_start+T-4);infq_data_world(est_start+T-1);infq_data_world(est_start+T-2);infq_data_world(est_start+T-3);infq_data_world(est_start+T-4)];
% set up shocks 
no_shocks = cell(minT,1);
% generate and save forecasts
for h = 1:H
    % add specific shocks
    no_shocks{h} = zeros(n_shocks,1);

    % run the simulation
    %forecast_eq{h} = eq_fun{h}(param_means,[sim_traj(:,T);sim_traj(infq_ind,T-1);sim_traj(infq_ind,T-2);sim_traj(infq_ind,T-3);sim_traj(infq_ind,T-4)],shift_times-T-h+1,zeros(n_shocks*h,1));
%     forecast_eq{h} = eq_fun{h}(param_means,[sim_traj(:,T);infq_data_CAN(est_start+T-1);infq_data_CAN(est_start+T-2);infq_data_CAN(est_start+T-3);infq_data_CAN(est_start+T-4);infq_data_world(est_start+T-1);infq_data_world(est_start+T-2);infq_data_world(est_start+T-3);infq_data_world(est_start+T-4)],shift_times-T-h+1,zeros(n_shocks*h,1));
    forecast_eq{h} = eq_fun{h}(param_means,forecast_init,shift_times-T-h+1,zeros(n_shocks*h,1));
end
%[forecast_traj] = nonlin_sim4b(forecast_eq,[],{shocks{1:H}},no_shocks,params,param_means);
forecast_traj=full(evalf(horzcat(forecast_eq{:})));
save('forecast_traj.mat','forecast_traj')
infq_forecast = forecast_traj(var_inds_to_plot(6),:);
save('infq_forecast.mat','infq_forecast')

if save_plots
    % out of sample fit
    figure(1)
    hold on
    tt=T+1:T+H;
    plot(tt,forecast_traj(var_inds_to_plot(1),tt-T)/plot_norm(1),'r') %population
    plot(tt,forecast_traj(var_inds_to_plot(2),tt-T)/plot_norm(2),'g') %food_per_capita
    plot(tt,forecast_traj(var_inds_to_plot(3),tt-T)/plot_norm(3),'y') %industrial_output_per_capita
    plot(tt,forecast_traj(var_inds_to_plot(4),tt-T)/plot_norm(4),'m') %persistent_pollution
    plot(tt,forecast_traj(var_inds_to_plot(5),tt-T)/plot_norm(5),'b') %Nonrenewable_Resources

%     plot(tt,sim_traj(var_inds_to_plot(1),tt)/plot_norm(1),'r*') %population
%     plot(tt,sim_traj(var_inds_to_plot(2),tt)/plot_norm(2),'g*') %food_per_capita
%     plot(tt,sim_traj(var_inds_to_plot(3),tt)/plot_norm(3),'y*') %industrial_output_per_capita
%     plot(tt,sim_traj(var_inds_to_plot(4),tt)/plot_norm(4),'m*') %persistent_pollution
%     plot(tt,sim_traj(var_inds_to_plot(5),tt)/plot_norm(5),'b*') %Nonrenewable_Resources

    plot(tt,data(tt,find(strcmp(obs_vars,"population")))/plot_norm(1),'r*') %population
    plot(tt,data(tt,find(strcmp(obs_vars,"food_per_capita")))/plot_norm(2),'g*') %food_per_capita
    plot(tt,data(tt,find(strcmp(obs_vars,"industrial_output")))./(plot_norm(3)*data(tt,find(strcmp(obs_vars,"population")))),'y*') %industrial_output_per_capita
    plot(tt,data(tt,find(strcmp(obs_vars,"Persistent_Pollution")))/plot_norm(4),'m*') %persistent_pollution
    plot(tt,data(tt,find(strcmp(obs_vars,"Nonrenewable_Resources")))/plot_norm(5),'b*') %Nonrenewable_Resources
    legend('population','food per capita','industrial output per capita','Persistent Pollution','Nonrenewable Resources')
    hold off
    xticks(T+1:T+H)
    set(gca,'XTickLabel',vertcat(dates{T+1:T+H}),'fontsize',12)
    saveas(gcf,'OOS_fit_main.png')


    % inflation
    figure(2)
    tt=T+1:T+H;
    hold on
    plot(tt,forecast_traj(var_inds_to_plot(6),tt-T),'b') % inflation
    % plot(tt,sim_traj(var_inds_to_plot(6),tt),'b*') % inflation
    plot(tt,data(tt,find(strcmp(obs_vars,"inflation_CAN"))),'b*') %inflation
    legend('inflation')
    hold off
    xticks(T+1:T+H)
    set(gca,'XTickLabel',vertcat(dates{T+1:T+H}),'fontsize',12)
    saveas(gcf,'OOS_fit_infl.png')


    % in sample fit (sim_traj)
    % figure(3)
    % hold on
    % tt=1:T;
    % plot(tt,in_sample_traj(var_inds_to_plot(1),tt)/plot_norm(1),'r') %population
    % plot(tt,in_sample_traj(var_inds_to_plot(2),tt)/plot_norm(2),'g') %food_per_capita
    % plot(tt,in_sample_traj(var_inds_to_plot(3),tt)/plot_norm(3),'y') %industrial_output_per_capita
    % plot(tt,in_sample_traj(var_inds_to_plot(4),tt)/plot_norm(4),'m') %persistent_pollution
    % plot(tt,in_sample_traj(var_inds_to_plot(5),tt)/plot_norm(5),'b') %Nonrenewable_Resources
    % legend('population','food per capita','industrial output per capita','Persistent Pollution','Nonrenewable Resources')
    % plot(tt,sim_traj(var_inds_to_plot(1),tt)/plot_norm(1),'r*') %population
    % plot(tt,sim_traj(var_inds_to_plot(2),tt)/plot_norm(2),'g*') %food_per_capita
    % plot(tt,sim_traj(var_inds_to_plot(3),tt)/plot_norm(3),'y*') %industrial_output_per_capita
    % plot(tt,sim_traj(var_inds_to_plot(4),tt)/plot_norm(4),'m*') %persistent_pollution
    % plot(tt,sim_traj(var_inds_to_plot(5),tt)/plot_norm(5),'b*') %Nonrenewable_Resources
    % hold off

    % % agriculture
    % figure(4)
    % hold on
    % tt=1:T;
    % for v = 7:12
    % plot(tt,in_sample_traj(var_inds_to_plot(v),tt)/plot_norm(v)) 
    % end
    % legend([vars_to_plot(7:12)],'interpreter','none')
    % hold off
    % 
    % % out of sample fit
    % figure(5)
    % hold on
    % tt=T+1:T+H;
    % plot(tt,forecast_traj(var_inds_to_plot(1),tt-T)/plot_norm(1),'r') %population
    % plot(tt,forecast_traj(var_inds_to_plot(2),tt-T)/plot_norm(2),'g') %food_per_capita
    % plot(tt,forecast_traj(var_inds_to_plot(3),tt-T)/plot_norm(3),'y') %industrial_output_per_capita
    % plot(tt,forecast_traj(var_inds_to_plot(4),tt-T)/plot_norm(4),'m') %Persistent_Pollution
    % plot(tt,forecast_traj(var_inds_to_plot(5),tt-T)/plot_norm(5),'b') %Nonrenewable_Resources
    % legend('population','food per capita','industrial output per capita','Persistent Pollution','Nonrenewable Resources')
    % plot(tt,data(tt,find(strcmp(obs_vars,"population")))/plot_norm(1),'r*') %population
    % plot(tt,data(tt,find(strcmp(obs_vars,"food")))./(plot_norm(2)*data(tt,find(strcmp(obs_vars,"population")))),'g*') %food_per_capita
    % plot(tt,data(tt,find(strcmp(obs_vars,"industrial_output")))./(plot_norm(3)*data(tt,find(strcmp(obs_vars,"population")))),'y*') %industrial_output_per_capita
    % plot(tt,data(tt,find(strcmp(obs_vars,"Persistent_Pollution")))/plot_norm(4),'m*') %Persistent_Pollution
    % plot(tt,data(tt,find(strcmp(obs_vars,"Nonrenewable_Resources")))/plot_norm(5),'b*') %Nonrenewable_Resources
    % hold off

    % in sample fit (data)
    figure(6)
    hold on
    tt=1:T;
    plot(tt,in_sample_traj(var_inds_to_plot(1),tt)/plot_norm(1),'r') %population
    plot(tt,in_sample_traj(var_inds_to_plot(2),tt)/plot_norm(2),'g') %food_per_capita
    plot(tt,in_sample_traj(find(strcmp('food',var_names)),tt)/(10*plot_norm(2)),'Color','#77AC30') %food
    plot(tt,in_sample_traj(find(strcmp('GDP_per_capita',var_names)),tt)/(10*plot_norm(14)),'Color','#AC3077') %GDP_per_capita
    plot(tt,in_sample_traj(var_inds_to_plot(3),tt)/plot_norm(3),'y') %industrial_output_per_capita
    plot(tt,in_sample_traj(var_inds_to_plot(4),tt)/(0.1*plot_norm(4)),'m') %Persistent_Pollution
    plot(tt,in_sample_traj(var_inds_to_plot(5),tt)/plot_norm(5),'b') %Nonrenewable_Resources

    plot(tt,data(tt,find(strcmp(obs_vars,"population")))/plot_norm(1),'r*') %population
    plot(tt,data(tt,find(strcmp(obs_vars,"food_per_capita")))./(plot_norm(2)),'g*') %food_per_capita
    plot(tt,data(tt,find(strcmp(obs_vars,"food_per_capita")))./(10*plot_norm(2)).*data(tt,find(strcmp(obs_vars,"population")))/plot_norm(1),'*','Color','#77AC30') %food
    plot(tt,data(tt,find(strcmp(obs_vars,"GDP_per_capita")))/(10*plot_norm(14)),'*','Color','#AC3077') %GDP_per_capita
    plot(tt,data(tt,find(strcmp(obs_vars,"industrial_output")))./(plot_norm(3)*data(tt,find(strcmp(obs_vars,"population")))),'y*') %industrial_output_per_capita
    plot(tt,data(tt,find(strcmp(obs_vars,"Persistent_Pollution")))/(0.1*plot_norm(4)),'m*') %Persistent_Pollution
    plot(tt,data(tt,find(strcmp(obs_vars,"Nonrenewable_Resources")))/plot_norm(5),'b*') %Nonrenewable_Resources
    hold off
    legend('population','food per capita','food','GDP per capita','industrial output per capita','Persistent Pollution','Nonrenewable Resources')
    saveas(gcf,'IS_fit_main.png')
    xticks(1:16:T)
    set(gca,'XTickLabel',vertcat(dates{1:16:T}),'fontsize',12)

    % inflation
    figure(7)
    tt=1:T;
    hold on
    plot(tt,in_sample_traj(var_inds_to_plot(6),tt),'b') % inflation
    % plot(tt,sim_traj(var_inds_to_plot(6),tt),'b*') % inflation
    plot(tt,data(tt,find(strcmp(obs_vars,"inflation_CAN"))),'b*') %inflation
    % plot(tt,data(tt,find(strcmp(obs_vars,"GDP_per_capita"))),'g*') %GDP_per_capita
    legend('inflation')
    hold off
    xticks(1:16:T)
    set(gca,'XTickLabel',vertcat(dates{1:16:T}),'fontsize',12)
    saveas(gcf,'IS_fit_infl.png')
    
    n_fig=7;
    for i=n_fig+1:n_obs+n_fig
        colour = rand(1,3);
        figure(i)
        hold on
        title(var_names(obs_var_inds(i-n_fig)),'interpreter','none')
        plot(data(T:T+H,i-n_fig)*normalization(obs_var_inds(i-n_fig)),'*','color',colour)
        plot(1:H+1,[data(T,i-n_fig)*normalization(obs_var_inds(i-n_fig)) forecast_traj(obs_var_inds(i-n_fig),:)*normalization(obs_var_inds(i-n_fig))],'color',colour)
        hold off
    end

end

disp('Done')

% diary off

% end