addpath(genpath('/home/mrra/CasADi_v3.5.5_linux'));
import casadi.* 
T0 = 1950;
T = 250;
skip_ML=false;

%% Variables:
industrial_capital_output_ratio_mult_from_res_conserv_tech=SX.sym('industrial_capital_output_ratio_mult_from_res_conservation_tech',[T,1]);
industrial_capital_output_ratio_mult_from_land_yield_tech=SX.sym('industrial_capital_output_ratio_mult_from_land_yield_tech',[T,1]);
industrial_capital_output_ratio_mult_from_pollution_tech=SX.sym('industrial_capital_output_ratio_mult_from_pollution_tech',[T,1]);
fraction_of_industrial_output_alloc_to_consumption_const=SX.sym('fraction_of_industrial_output_allocated_to_consumption_constant',[T,1]);
fraction_of_industrial_output_alloc_to_consumption_var=SX.sym('fraction_of_industrial_output_allocated_to_consumption_variable',[T,1]);
fraction_of_industrial_capital_alloc_to_obtaining_res=SX.sym('fraction_of_industrial_capital_allocated_to_obtaining_resources',[T,1]);
fraction_of_agricultural_inputs_allocated_to_land_development=SX.sym('fraction_of_agricultural_inputs_allocated_to_land_development',[T,1]);
fraction_of_industrial_output_allocated_to_agriculture_1=SX.sym('fraction_of_industrial_output_allocated_to_agriculture_1',[T,1]);
fraction_of_industrial_output_allocated_to_agriculture_2=SX.sym('fraction_of_industrial_output_allocated_to_agriculture_2',[T,1]);
fraction_of_industrial_output_allocated_to_agriculture=SX.sym('fraction_of_industrial_output_allocated_to_agriculture',[T,1]);
fraction_of_industrial_output_allocated_to_consumption=SX.sym('fraction_of_industrial_output_allocated_to_consumption',[T,1]);
fraction_of_capital_allocated_to_obtaining_resources_1=SX.sym('fraction_of_capital_allocated_to_obtaining_resources_1',[T,1]);
fraction_of_capital_allocated_to_obtaining_resources_2=SX.sym('fraction_of_capital_allocated_to_obtaining_resources_2',[T,1]);
fraction_of_industrial_output_allocated_to_investment=SX.sym('fraction_of_industrial_output_allocated_to_investment',[T,1]);
fraction_of_industrial_output_allocated_to_services_1=SX.sym('fraction_of_industrial_output_allocated_to_services_1',[T,1]);
fraction_of_industrial_output_allocated_to_services_2=SX.sym('fraction_of_industrial_output_allocated_to_services_2',[T,1]);
fraction_of_agricultural_inputs_for_land_maintenance=SX.sym('fraction_of_agricultural_inputs_for_land_maintenance',[T,1]);
fraction_of_industrial_output_allocated_to_services=SX.sym('fraction_of_industrial_output_allocated_to_services',[T,1]);
persistent_pollution_technology_change_multiplier=SX.sym('persistent_pollution_technology_change_multiplier',[T,1]);
fraction_services_allocated_to_fertility_control=SX.sym('fraction_services_allocated_to_fertility_control',[T,1]);
urban_and_industrial_land_required_per_capita=SX.sym('urban_and_industrial_land_required_per_capita',[T,1]);
lifetime_multiplier_from_persistent_pollution=SX.sym('lifetime_multiplier_from_persistent_pollution',[T,1]);
land_yield_technology_change_rate_multiplier=SX.sym('land_yield_technology_change_rate_multiplier',[T,1]);
marginal_productivity_of_agricultural_inputs=SX.sym('marginal_productivity_of_agricultural_inputs',[T,1]);
completed_multiplier_from_perceived_lifetime=SX.sym('completed_multiplier_from_perceived_lifetime',[T,1]);
marginal_land_yield_multiplier_from_capital=SX.sym('marginal_land_yield_multiplier_from_capital',[T,1]);
persistent_pollution_generation_agriculture=SX.sym('persistent_pollution_generation_agriculture',[T,1]);
persistent_pollution_technology_change_rate=SX.sym('persistent_pollution_technology_change_rate',[T,1]);
land_yield_multiplier_from_air_pollution_2=SX.sym('land_yield_multiplier_from_air_pollution_2',[T,1]);
lifetime_multiplier_from_health_services_1=SX.sym('lifetime_multiplier_from_health_services_1',[T,1]);
lifetime_multiplier_from_health_services_2=SX.sym('lifetime_multiplier_from_health_services_2',[T,1]);
resource_technology_change_rate_multiplier=SX.sym('resource_technology_change_rate_multiplier',[T,1]);
land_yield_multipler_from_air_pollution_1=SX.sym('land_yield_multipler_from_air_pollution_1',[T,1]);
land_removal_for_urban_and_industrial_use=SX.sym('land_removal_for_urban_and_industrial_use',[T,1]);
marginal_productivity_of_land_development=SX.sym('marginal_productivity_of_land_development',[T,1]);
land_yield_multiplier_from_air_pollution=SX.sym('land_yield_multiplier_from_air_pollution',[T,1]);
persistent_pollution_generation_factor_2=SX.sym('persistent_pollution_generation_factor_2',[T,1]);
persistent_pollution_generation_industry=SX.sym('persistent_pollution_generation_industry',[T,1]);
lifetime_multiplier_from_health_services=SX.sym('lifetime_multiplier_from_health_services',[T,1]);
fertility_control_facilities_per_capita=SX.sym('fertility_control_facilities_per_capita',[T,1]);
fertility_control_allocation_per_capita=SX.sym('fertility_control_allocation_per_capita',[T,1]);
% persistent_pollution_intensity_industry=SX.sym('persistent_pollution_intensity_industry',[T,1]);
land_life_multiplier_from_land_yield_1=SX.sym('land_life_multiplier_from_land_yield_1',[T,1]);
land_life_multiplier_from_land_yield_2=SX.sym('land_life_multiplier_from_land_yield_2',[T,1]);
indicated_services_output_per_capita_1=SX.sym('indicated_services_output_per_capita_1',[T,1]);
indicated_services_output_per_capita_2=SX.sym('indicated_services_output_per_capita_2',[T,1]);
persistent_pollution_assimilation_rate=SX.sym('persistent_pollution_assimilation_rate',[T,1]);
persistent_pollution_generation_factor=SX.sym('persistent_pollution_generation_factor',[T,1]);
land_yield_multiplier_from_technology=SX.sym('land_yield_multiplier_from_technology',[T,1]);
% consumed_industrial_output_per_capita=SX.sym('consumed_industrial_output_per_capita',[T,1]);
land_life_multiplier_from_land_yield=SX.sym('land_life_multiplier_from_land_yield',[T,1]);
indicated_services_output_per_capita=SX.sym('indicated_services_output_per_capita',[T,1]);
persistent_pollution_appearance_rate=SX.sym('persistent_pollution_appearance_rate',[T,1]);
persistent_pollution_generation_rate=SX.sym('persistent_pollution_generation_rate',[T,1]);
average_industrial_output_per_capita=SX.sym('average_industrial_output_per_capita',[T,1]);
delayed_industrial_output_per_capita=SX.sym('delayed_industrial_output_per_capita',[T,1]);
effective_health_services_per_capita=SX.sym('effective_health_services_per_capita',[T,1]);
land_yield_multiplier_from_capital=SX.sym('land_yield_multiplier_from_capital',[T,1]);
urban_and_industrial_land_required=SX.sym('urban_and_industrial_land_required',[T,1]);
average_life_of_industrial_capital=SX.sym('average_life_of_industrial_capital',[T,1]);
Delayed_Labor_Utilization_Fraction=SX.sym('Delayed_Labor_Utilization_Fraction',[T,1]);
potential_jobs_agricultural_sector=SX.sym('potential_jobs_agricultural_sector',[T,1]);
per_capita_resource_use_multiplier=SX.sym('per_capita_resource_use_multiplier',[T,1]);
land_yield_technology_change_rate=SX.sym('land_yield_technology_change_rate',[T,1]);
industrial_capital_output_ratio_2=SX.sym('industrial_capital_output_ratio_2',[T,1]);
assimilation_half_life_multiplier=SX.sym('assimilation_half_life_multiplier',[T,1]);
crowding_multiplier_from_industry=SX.sym('crowding_multiplier_from_industry',[T,1]);
lifetime_multiplier_from_crowding=SX.sym('lifetime_multiplier_from_crowding',[T,1]);
% fraction_of_output_in_agriculture=SX.sym('fraction_of_output_in_agriculture',[T,1]);
average_life_agricultural_inputs=SX.sym('average_life_agricultural_inputs',[T,1]);
land_fertility_regeneration_time=SX.sym('land_fertility_regeneration_time',[T,1]);
jobs_per_industrial_capital_unit=SX.sym('jobs_per_industrial_capital_unit',[T,1]);
potential_jobs_industrial_sector=SX.sym('potential_jobs_industrial_sector',[T,1]);
Resource_Conservation_Technology=SX.sym('Resource_Conservation_Technology',[T,1]);
land_fertility_degredation_rate=SX.sym('land_fertility_degredation_rate',[T,1]);
industrial_capital_depreciation=SX.sym('industrial_capital_depreciation',[T,1]);
industrial_capital_output_ratio=SX.sym('industrial_capital_output_ratio',[T,1]);
average_life_of_service_capital=SX.sym('average_life_of_service_capital',[T,1]);
Persistent_Pollution_Technology=SX.sym('Persistent_Pollution_Technology',[T,1]);
fertility_control_effectiveness=SX.sym('fertility_control_effectiveness',[T,1]);
fraction_of_resources_remaining=SX.sym('fraction_of_resources_remaining',[T,1]);
resource_technology_change_rate=SX.sym('resource_technology_change_rate',[T,1]);
agricultural_input_per_hectare=SX.sym('agricultural_input_per_hectare',[T,1]);
family_response_to_social_norm=SX.sym('family_response_to_social_norm',[T,1]);
% fraction_of_output_in_industry=SX.sym('fraction_of_output_in_industry',[T,1]);
% fraction_of_output_in_services=SX.sym('fraction_of_output_in_services',[T,1]);
total_agricultural_investment=SX.sym('total_agricultural_investment',[T,1]);
industrial_capital_investment=SX.sym('industrial_capital_investment',[T,1]);
capacity_utilization_fraction=SX.sym('capacity_utilization_fraction',[T,1]);
jobs_per_service_capital_unit=SX.sym('jobs_per_service_capital_unit',[T,1]);
potential_jobs_service_sector=SX.sym('potential_jobs_service_sector',[T,1]);
desired_completed_family_size=SX.sym('desired_completed_family_size',[T,1]);
lifetime_multiplier_from_food=SX.sym('lifetime_multiplier_from_food',[T,1]);
industrial_output_2005_value=SX.sym('industrial_output_2005_value',[T,1]);
development_cost_per_hectare=SX.sym('development_cost_per_hectare',[T,1]);
industrial_output_per_capita=SX.sym('industrial_output_per_capita',[T,1]);
service_capital_output_ratio=SX.sym('service_capital_output_ratio',[T,1]);
service_capital_depreciation=SX.sym('service_capital_depreciation',[T,1]);
fraction_of_population_urban=SX.sym('fraction_of_population_urban',[T,1]);
Arable_Land_in_Gigahectares=SX.sym('Arable_Land_in_Gigahectares',[T,1]);
indicated_food_per_capita_1=SX.sym('indicated_food_per_capita_1',[T,1]);
indicated_food_per_capita_2=SX.sym('indicated_food_per_capita_2',[T,1]);
current_agricultural_inputs=SX.sym('current_agricultural_inputs',[T,1]);
land_fertility_regeneration=SX.sym('land_fertility_regeneration',[T,1]);
% Human_Ecological_Footprint=SX.sym('Human_Ecological_Footprint',[T,1]);
land_fertility_degredation=SX.sym('land_fertility_degredation',[T,1]);
labor_utilization_fraction=SX.sym('labor_utilization_fraction',[T,1]);
service_capital_investment=SX.sym('service_capital_investment',[T,1]);
persistent_pollution_index=SX.sym('persistent_pollution_index',[T,1]);
need_for_fertility_control=SX.sym('need_for_fertility_control',[T,1]);
health_services_per_capita=SX.sym('health_services_per_capita',[T,1]);
% consumed_industrial_output=SX.sym('consumed_industrial_output',[T,1]);
% service_output_2005_value=SX.sym('service_output_2005_value',[T,1]);
indicated_food_per_capita=SX.sym('indicated_food_per_capita',[T,1]);
Urban_and_Industrial_Land=SX.sym('Urban_and_Industrial_Land',[T,1]);
service_output_per_capita=SX.sym('service_output_per_capita',[T,1]);
perceived_life_expectancy=SX.sym('perceived_life_expectancy',[T,1]);
family_income_expectation=SX.sym('family_income_expectation',[T,1]);
social_family_size_normal=SX.sym('social_family_size_normal',[T,1]);
Potentially_Arable_Land=SX.sym('Potentially_Arable_Land',[T,1]);
desired_total_fertility=SX.sym('desired_total_fertility',[T,1]);
maximum_total_fertility=SX.sym('maximum_total_fertility',[T,1]);
assimilation_half_life=SX.sym('assimilation_half_life',[T,1]);
Nonrenewable_Resources=SX.sym('Nonrenewable_Resources',[T,1]);
% resource_use_intensity=SX.sym('resource_use_intensity',[T,1]);
arable_land_harvested=SX.sym('arable_land_harvested',[T,1]);
% Life_Expectancy_Index=SX.sym('Life_Expectancy_Index',[T,1]);
land_development_rate=SX.sym('land_development_rate',[T,1]);
Land_Yield_Technology=SX.sym('Land_Yield_Technology',[T,1]);
average_life_of_land=SX.sym('average_life_of_land',[T,1]);
Perceived_Food_Ratio=SX.sym('Perceived_Food_Ratio',[T,1]);
Persistent_Pollution=SX.sym('Persistent_Pollution',[T,1]);
fecundity_multiplier=SX.sym('fecundity_multiplier',[T,1]);
% Human_Welfare_Index=SX.sym('Human_Welfare_Index',[T,1]);
Agricultural_Inputs=SX.sym('Agricultural_Inputs',[T,1]);
land_yield_factor_2=SX.sym('land_yield_factor_2',[T,1]);
maturation_14_to_15=SX.sym('maturation_14_to_15',[T,1]);
maturation_44_to_45=SX.sym('maturation_44_to_45',[T,1]);
maturation_64_to_65=SX.sym('maturation_64_to_65',[T,1]);
Population_15_To_44=SX.sym('Population_15_To_44',[T,1]);
Population_45_To_64=SX.sym('Population_45_To_64',[T,1]);
resource_usage_rate=SX.sym('resource_usage_rate',[T,1]);
resource_use_fact_2=SX.sym('resource_use_fact_2',[T,1]);
resource_use_factor=SX.sym('resource_use_factor',[T,1]);
Industrial_Capital=SX.sym('Industrial_Capital',[T,1]);
mortality_45_to_64=SX.sym('mortality_45_to_64',[T,1]);
mortality_15_to_44=SX.sym('mortality_15_to_44',[T,1]);
Population_0_To_14=SX.sym('Population_0_To_14',[T,1]);
Population_65_Plus=SX.sym('Population_65_Plus',[T,1]);
land_erosion_rate=SX.sym('land_erosion_rate',[T,1]);
industrial_output=SX.sym('industrial_output',[T,1]);
mortality_65_plus=SX.sym('mortality_65_plus',[T,1]);
mortality_0_to_14=SX.sym('mortality_0_to_14',[T,1]);
jobs_per_hectare=SX.sym('jobs_per_hectare',[T,1]);
% Absorption_Land=SX.sym('Absorption_Land',[T,1]);
% Education_Index=SX.sym('Education_Index',[T,1]);
food_per_capita=SX.sym('food_per_capita',[T,1]);
Service_Capital=SX.sym('Service_Capital',[T,1]);
deaths_15_to_44=SX.sym('deaths_15_to_44',[T,1]);
deaths_45_to_64=SX.sym('deaths_45_to_64',[T,1]);
total_fertility=SX.sym('total_fertility',[T,1]);
life_expectancy=SX.sym('life_expectancy',[T,1]);
% GDP_per_capita=SX.sym('GDP_per_capita',[T,1]);
Land_Fertility=SX.sym('Land_Fertility',[T,1]);
service_output=SX.sym('service_output',[T,1]);
deaths_0_to_14=SX.sym('deaths_0_to_14',[T,1]);
deaths_65_plus=SX.sym('deaths_65_plus',[T,1]);
land_fr_cult=SX.sym('land_fr_cult',[T,1]);
Arable_Land=SX.sym('Arable_Land',[T,1]);
labor_force=SX.sym('labor_force',[T,1]);
% Urban_Land=SX.sym('Urban_Land',[T,1]);
land_yield=SX.sym('land_yield',[T,1]);
food_ratio=SX.sym('food_ratio',[T,1]);
% population=SX.sym('population',[T,1]);
population=SX.zeros([T,1]);
% birth_rate=SX.sym('birth_rate',[T,1]);
% death_rate=SX.sym('death_rate',[T,1]);
% GDP_Index=SX.sym('GDP_Index',[T,1]);
births=SX.sym('births',[T,1]);
deaths=SX.sym('deaths',[T,1]);
food=SX.sym('food',[T,1]);
jobs=SX.sym('jobs',[T,1]);

 %% Tables:
if ~skip_ML
    names{2}='x'; names{3} = 'y';
    x_cas=SX.sym('x',[1,1]); 

%     Education_Index_LOOKUP=[[0,0];[1000,0.81];[2000,0.88];[3000,0.92];[4000,0.95];[5000,0.98];[6000,0.99];[7000,1]];
%     [coeffs{1},fit{1},fun_text{1},modelFun{1}] = get_fit(Education_Index_LOOKUP(:,1),Education_Index_LOOKUP(:,2),false,false,names);
%     Education_Index_LOOKUP = @(x) modelFun{1}(coeffs{1},x); 
%     Education_Index_LOOKUP=Function('f',{x_cas},{Education_Index_LOOKUP(x_cas)}); 
%     GDP_per_capita_LOOKUP=[[0,120];[200,600];[400,1200];[600,1800];[800,2500];[1000,3200]];
%     [coeffs{2},fit{2},fun_text{2},modelFun{2}] = get_fit(GDP_per_capita_LOOKUP(:,1),GDP_per_capita_LOOKUP(:,2),false,false,names);
%     GDP_per_capita_LOOKUP = @(x) modelFun{2}(coeffs{2},x); 
%     GDP_per_capita_LOOKUP=Function('f',{x_cas},{GDP_per_capita_LOOKUP(x_cas)}); 
    Life_Expectancy_Index_LOOKUP=[[25,0];[35,0.16];[45,0.33];[55,0.5];[65,0.67];[75,0.84];[85,1]];
    [coeffs{3},fit{3},fun_text{3},modelFun{3}] = get_fit(Life_Expectancy_Index_LOOKUP(:,1),Life_Expectancy_Index_LOOKUP(:,2),false,false,names);
    Life_Expectancy_Index_LOOKUP = @(x) modelFun{3}(coeffs{3},x); 
    Life_Expectancy_Index_LOOKUP=Function('f',{x_cas},{Life_Expectancy_Index_LOOKUP(x_cas)}); 
%     development_cost_per_hectare_table=[[0,100000];[0.1,7400];[0.2,5200];[0.3,3500];[0.4,2400];[0.5,1500];[0.6,750];[0.7,300];[0.8,150];[0.9,75];[1,50]];
    development_cost_per_hectare_table=[[0,12000];[0.1,7400];[0.2,5200];[0.3,3500];[0.4,2400];[0.5,1500];[0.6,750];[0.7,300];[0.8,150];[0.9,75];[1,50]];
%     [coeffs{4},fit{4},fun_text{4},modelFun{4}] = get_fit(development_cost_per_hectare_table(:,1),development_cost_per_hectare_table(:,2),false,false,names);
%     development_cost_per_hectare_table = @(x) modelFun{4}(coeffs{4},x); 
%     development_cost_per_hectare_table=Function('f',{x_cas},{development_cost_per_hectare_table(x_cas)}); 
    development_cost_per_hectare_table = @(x) interp_f(development_cost_per_hectare_table,x);
%     fraction_industrial_output_allocated_to_agriculture_table_1=[[0,0.4];[0.5,0.2];[1,0.1];[1.5,0.025];[2,0];[2.5,0]];
    fraction_industrial_output_allocated_to_agriculture_table_1=[[0,0.4];[0.5,0.2];[1,0.1];[1.5,0.025];[2,0.01];[2.5,0.005]];
%     [coeffs{5},fit{5},fun_text{5},modelFun{5}] = get_fit(fraction_industrial_output_allocated_to_agriculture_table_1(:,1),fraction_industrial_output_allocated_to_agriculture_table_1(:,2),false,false,names);
%     fraction_industrial_output_allocated_to_agriculture_table_1 = @(x) modelFun{5}(coeffs{5},x); 
%     fraction_industrial_output_allocated_to_agriculture_table_1=Function('f',{x_cas},{fraction_industrial_output_allocated_to_agriculture_table_1(x_cas)}); 
    fraction_industrial_output_allocated_to_agriculture_table_1 = @(x) interp_f(fraction_industrial_output_allocated_to_agriculture_table_1,x);
%     fraction_industrial_output_allocated_to_agriculture_table_2=[[0,0.4];[0.5,0.2];[1,0.1];[1.5,0.025];[2,0];[2.5,0]];
    fraction_industrial_output_allocated_to_agriculture_table_2=[[0,0.4];[0.5,0.2];[1,0.1];[1.5,0.025];[2,0.005];[2.5,0]];
%     [coeffs{6},fit{6},fun_text{6},modelFun{6}] = get_fit(fraction_industrial_output_allocated_to_agriculture_table_2(:,1),fraction_industrial_output_allocated_to_agriculture_table_2(:,2),false,false,names);
%     fraction_industrial_output_allocated_to_agriculture_table_2 = @(x) modelFun{6}(coeffs{6},x); 
%     fraction_industrial_output_allocated_to_agriculture_table_2=Function('f',{x_cas},{fraction_industrial_output_allocated_to_agriculture_table_2(x_cas)}); 
    fraction_industrial_output_allocated_to_agriculture_table_2 = @(x) interp_f(fraction_industrial_output_allocated_to_agriculture_table_2,x);
    indicated_food_per_capita_table_1=[[0,230];[200,480];[400,690];[600,850];[800,970];[1000,1070];[1200,1150];[1400,1210];[1600,1250]];
%     [coeffs{7},fit{7},fun_text{7},modelFun{7}] = get_fit(indicated_food_per_capita_table_1(:,1),indicated_food_per_capita_table_1(:,2),false,false,names);
%     indicated_food_per_capita_table_1 = @(x) modelFun{7}(coeffs{7},x); 
%     indicated_food_per_capita_table_1=Function('f',{x_cas},{indicated_food_per_capita_table_1(x_cas)}); 
    indicated_food_per_capita_table_1 = @(x) interp_f(indicated_food_per_capita_table_1,x);
    indicated_food_per_capita_table_2=[[0,230];[200,480];[400,690];[600,850];[800,970];[1000,1070];[1200,1150];[1400,1210];[1600,1250]];
%     [coeffs{8},fit{8},fun_text{8},modelFun{8}] = get_fit(indicated_food_per_capita_table_2(:,1),indicated_food_per_capita_table_2(:,2),false,false,names);
%     indicated_food_per_capita_table_2 = @(x) modelFun{8}(coeffs{8},x); 
%     indicated_food_per_capita_table_2=Function('f',{x_cas},{indicated_food_per_capita_table_2(x_cas)}); 
    indicated_food_per_capita_table_2 = @(x) interp_f(indicated_food_per_capita_table_2,x);
%     land_yield_multiplier_from_capital_table=[[0,1];[40,3];[80,4.5];[120,5];[160,5.3];[200,5.6];[240,5.9];[280,6.1];[320,6.35];[360,6.6];[400,6.9];[440,7.2];[480,7.4];[520,7.6];[560,7.8];[600,8];[640,8.2];[680,8.4];[720,8.6];[760,8.8];[800,9];[840,9.2];[880,9.4];[920,9.6];[960,9.8];[1000,10]];
    land_yield_multiplier_from_capital_table=[[0,1];[40,3];[80,3.8];[120,4.4];[160,4.9];[200,5.4];[240,5.7];[280,6.0];[320,6.3];[360,6.6];[400,6.9];[440,7.2];[480,7.4];[520,7.6];[560,7.8];[600,8];[640,8.2];[680,8.4];[720,8.6];[760,8.8];[800,9];[840,9.2];[880,9.4];[920,9.6];[960,9.8];[1000,10]];  
%     land_yield_multiplier_from_capital_table=[[0,1];[5.33,1.26];[6.576,1.329];[9.96,1.50];[40,3];[80,3.8];[120,4.4];[160,4.9];[200,5.4];[240,5.7];[280,6.0];[320,6.3];[360,6.6];[400,6.9];[440,7.2];[480,7.4];[520,7.6];[560,7.8];[600,8];[640,8.2];[680,8.4];[720,8.6];[760,8.8];[800,9];[840,9.2];[880,9.4];[920,9.6];[960,9.8];[1000,10]];
%     [coeffs{9},fit{9},fun_text{9},modelFun{9}] = get_fit(land_yield_multiplier_from_capital_table(:,1),land_yield_multiplier_from_capital_table(:,2),false,false,names);
%     land_yield_multiplier_from_capital_table = @(x) modelFun{9}(coeffs{9},x); 
%     land_yield_multiplier_from_capital_table=Function('f',{x_cas},{land_yield_multiplier_from_capital_table(x_cas)}); 
    land_yield_multiplier_from_capital_table = @(x) interp_f(land_yield_multiplier_from_capital_table,x);
    land_yield_multipler_from_air_pollution_table_1=[[0,1];[10,1];[20,0.7];[30,0.4]];
%     land_yield_multipler_from_air_pollution_table_1=[[0,1];[0.5,1];[1,1];[5,1];[10,1];[20,0.7];[30,0.4]];
%     [coeffs{10},fit{10},fun_text{10},modelFun{10}] = get_fit(land_yield_multipler_from_air_pollution_table_1(:,1),land_yield_multipler_from_air_pollution_table_1(:,2),false,false,names);
%     land_yield_multipler_from_air_pollution_table_1 = @(x) modelFun{10}(coeffs{10},x); 
%     land_yield_multipler_from_air_pollution_table_1=Function('f',{x_cas},{land_yield_multipler_from_air_pollution_table_1(x_cas)}); 
    land_yield_multipler_from_air_pollution_table_1 = @(x) interp_f(land_yield_multipler_from_air_pollution_table_1,x);
    land_yield_multipler_from_air_pollution_table_2=[[0,1];[10,1];[20,0.98];[30,0.95]];
%     [coeffs{11},fit{11},fun_text{11},modelFun{11}] = get_fit(land_yield_multipler_from_air_pollution_table_2(:,1),land_yield_multipler_from_air_pollution_table_2(:,2),false,false,names);
%     land_yield_multipler_from_air_pollution_table_2 = @(x) modelFun{11}(coeffs{11},x); 
%     land_yield_multipler_from_air_pollution_table_2=Function('f',{x_cas},{land_yield_multipler_from_air_pollution_table_2(x_cas)}); 
    land_yield_multipler_from_air_pollution_table_2 = @(x) interp_f(land_yield_multipler_from_air_pollution_table_2,x);
%     land_yield_technology_change_rate_multiplier_table=[[0,0];[1,0]];
    land_yield_technology_change_rate_multiplier_table=[[0,0];[0.5,0.5];[1,1]];
%     [coeffs{12},fit{12},fun_text{12},modelFun{12}] = get_fit(land_yield_technology_change_rate_multiplier_table(:,1),land_yield_technology_change_rate_multiplier_table(:,2),false,false,names);
%     land_yield_technology_change_rate_multiplier_table = @(x) modelFun{12}(coeffs{12},x); 
%     land_yield_technology_change_rate_multiplier_table=Function('f',{x_cas},{land_yield_technology_change_rate_multiplier_table(x_cas)}); 
    land_yield_technology_change_rate_multiplier_table = @(x) interp_f(land_yield_technology_change_rate_multiplier_table,x);
    land_life_multiplier_from_land_yield_table_1=[[0,1.2];[1,1];[2,0.63];[3,0.36];[4,0.16];[5,0.055];[6,0.04];[7,0.025];[8,0.015];[9,0.01]];
    land_life_multiplier_from_land_yield_table_1 = @(x) interp_f(land_life_multiplier_from_land_yield_table_1,x);
%     [coeffs{13},fit{13},fun_text{13},modelFun{13}] = get_fit(land_life_multiplier_from_land_yield_table_1(:,1),land_life_multiplier_from_land_yield_table_1(:,2),false,false,names);
%     land_life_multiplier_from_land_yield_table_1 = @(x) modelFun{13}(coeffs{13},x); 
%     land_life_multiplier_from_land_yield_table_1=Function('f',{x_cas},{land_life_multiplier_from_land_yield_table_1(x_cas)}); 
    land_life_multiplier_from_land_yield_table_2=[[0,1.2];[1,1];[2,0.63];[3,0.36];[4,0.29];[5,0.26];[6,0.24];[7,0.22];[8,0.21];[9,0.2]];
    land_life_multiplier_from_land_yield_table_2 = @(x) interp_f(land_life_multiplier_from_land_yield_table_2,x);
%     [coeffs{14},fit{14},fun_text{14},modelFun{14}] = get_fit(land_life_multiplier_from_land_yield_table_2(:,1),land_life_multiplier_from_land_yield_table_2(:,2),false,false,names);
%     land_life_multiplier_from_land_yield_table_2 = @(x) modelFun{14}(coeffs{14},x); 
%     land_life_multiplier_from_land_yield_table_2=Function('f',{x_cas},{land_life_multiplier_from_land_yield_table_2(x_cas)}); 
    urban_and_industrial_land_required_per_capita_table=[[0,0.005];[200,0.008];[400,0.015];[600,0.025];[800,0.04];[1000,0.055];[1200,0.07];[1400,0.08];[1600,0.09]];
    urban_and_industrial_land_required_per_capita_table = @(x) interp_f(urban_and_industrial_land_required_per_capita_table,x);
%     [coeffs{15},fit{15},fun_text{15},modelFun{15}] = get_fit(urban_and_industrial_land_required_per_capita_table(:,1),urban_and_industrial_land_required_per_capita_table(:,2),false,false,names);
%     urban_and_industrial_land_required_per_capita_table = @(x) modelFun{15}(coeffs{15},x); 
%     urban_and_industrial_land_required_per_capita_table=Function('f',{x_cas},{urban_and_industrial_land_required_per_capita_table(x_cas)}); 
    land_fertility_degredation_rate_table=[[0,0];[10,0.1];[20,0.3];[30,0.5]]; 
    land_fertility_degredation_rate_table = @(x) interp_f(land_fertility_degredation_rate_table,x);
%     [coeffs{16},fit{16},fun_text{16},modelFun{16}] = get_fit(land_fertility_degredation_rate_table(:,1),land_fertility_degredation_rate_table(:,2),false,false,names);
%     coeffs{16}(3)=0; %fixed point at 0, and always positive for positive x
%     land_fertility_degredation_rate_table = @(x) modelFun{16}(coeffs{16},x); 
%     land_fertility_degredation_rate_table=Function('f',{x_cas},{land_fertility_degredation_rate_table(x_cas)}); 
    land_fertility_regeneration_time_table=[[0,20];[0.02,13];[0.04,8];[0.06,4];[0.08,2];[0.1,2]];
    land_fertility_regeneration_time_table = @(x) interp_f(land_fertility_regeneration_time_table,x);
%     [coeffs{17},fit{17},fun_text{17},modelFun{17}] = get_fit(land_fertility_regeneration_time_table(:,1),land_fertility_regeneration_time_table(:,2),false,false,names);
%     land_fertility_regeneration_time_table = @(x) modelFun{17}(coeffs{17},x); 
%     land_fertility_regeneration_time_table=Function('f',{x_cas},{land_fertility_regeneration_time_table(x_cas)}); 
    fraction_of_agricultural_inputs_for_land_maintenance_table=[[0,0];[1,0.04];[2,0.07];[3,0.09];[4,0.1]];
    fraction_of_agricultural_inputs_for_land_maintenance_table = @(x) interp_f(fraction_of_agricultural_inputs_for_land_maintenance_table,x);
%     [coeffs{18},fit{18},fun_text{18},modelFun{18}] = get_fit(fraction_of_agricultural_inputs_for_land_maintenance_table(:,1),fraction_of_agricultural_inputs_for_land_maintenance_table(:,2),false,false,names);
%     fraction_of_agricultural_inputs_for_land_maintenance_table = @(x) modelFun{18}(coeffs{18},x); 
%     fraction_of_agricultural_inputs_for_land_maintenance_table=Function('f',{x_cas},{fraction_of_agricultural_inputs_for_land_maintenance_table(x_cas)}); 
    fraction_of_agricultural_inputs_allocated_to_land_dev_table=[[0,0];[0.25,0.05];[0.5,0.15];[0.75,0.3];[1,0.5];[1.25,0.7];[1.5,0.85];[1.75,0.95];[2,1]];
    fraction_of_agricultural_inputs_allocated_to_land_dev_table = @(x) interp_f(fraction_of_agricultural_inputs_allocated_to_land_dev_table,x);
%     [coeffs{19},fit{19},fun_text{19},modelFun{19}] = get_fit(fraction_of_agricultural_inputs_allocated_to_land_dev_table(:,1),fraction_of_agricultural_inputs_allocated_to_land_dev_table(:,2),false,false,names);
%     fraction_of_agricultural_inputs_allocated_to_land_dev_table = @(x) modelFun{19}(coeffs{19},x); 
%     fraction_of_agricultural_inputs_allocated_to_land_dev_table=Function('f',{x_cas},{fraction_of_agricultural_inputs_allocated_to_land_dev_table(x_cas)}); 
    marginal_land_yield_multiplier_from_capital_table=[[0,0.075];[40,0.03];[80,0.015];[120,0.011];[160,0.009];[200,0.008];[240,0.007];[280,0.006];[320,0.005];[360,0.005];[400,0.005];[440,0.005];[480,0.005];[520,0.005];[560,0.005];[600,0.005]];
    marginal_land_yield_multiplier_from_capital_table = @(x) interp_f(marginal_land_yield_multiplier_from_capital_table,x);
    %     [coeffs{20},fit{20},fun_text{20},modelFun{20}] = get_fit(marginal_land_yield_multiplier_from_capital_table(:,1),marginal_land_yield_multiplier_from_capital_table(:,2),false,false,names);
%     marginal_land_yield_multiplier_from_capital_table = @(x) modelFun{20}(coeffs{20},x); 
%     marginal_land_yield_multiplier_from_capital_table=Function('f',{x_cas},{marginal_land_yield_multiplier_from_capital_table(x_cas)}); 
    industrial_capital_output_ratio_multiplier_from_resource_table=[[0,3.75];[0.1,3.6];[0.2,3.47];[0.3,3.36];[0.4,3.25];[0.5,3.16];[0.6,3.1];[0.7,3.06];[0.8,3.02];[0.9,3.01];[1,3]];
    industrial_capital_output_ratio_multiplier_from_resource_table = @(x) interp_f(industrial_capital_output_ratio_multiplier_from_resource_table,x);
%     [coeffs{21},fit{21},fun_text{21},modelFun{21}] = get_fit(industrial_capital_output_ratio_multiplier_from_resource_table(:,1),industrial_capital_output_ratio_multiplier_from_resource_table(:,2),false,false,names);
%     industrial_capital_output_ratio_multiplier_from_resource_table = @(x) modelFun{21}(coeffs{21},x); 
%     industrial_capital_output_ratio_multiplier_from_resource_table=Function('f',{x_cas},{industrial_capital_output_ratio_multiplier_from_resource_table(x_cas)}); 
    frac_of_industrial_output_allocated_to_consumption_var_table=[[0,0.3];[0.2,0.32];[0.4,0.34];[0.6,0.36];[0.8,0.38];[1,0.43];[1.2,0.73];[1.4,0.77];[1.6,0.81];[1.8,0.82];[2,0.83]];
    frac_of_industrial_output_allocated_to_consumption_var_table = @(x) interp_f(frac_of_industrial_output_allocated_to_consumption_var_table,x);
%     [coeffs{22},fit{22},fun_text{22},modelFun{22}] = get_fit(frac_of_industrial_output_allocated_to_consumption_var_table(:,1),frac_of_industrial_output_allocated_to_consumption_var_table(:,2),false,false,names);
%     frac_of_industrial_output_allocated_to_consumption_var_table = @(x) modelFun{22}(coeffs{22},x); 
%     frac_of_industrial_output_allocated_to_consumption_var_table=Function('f',{x_cas},{frac_of_industrial_output_allocated_to_consumption_var_table(x_cas)}); 
    industrial_capital_output_ratio_multiplier_from_pollution_table=[[0,1.25];[0.1,1.2];[0.2,1.15];[0.3,1.11];[0.4,1.08];[0.5,1.05];[0.6,1.03];[0.7,1.02];[0.8,1.01];[0.9,1];[1,1]];
    industrial_capital_output_ratio_multiplier_from_pollution_table = @(x) interp_f(industrial_capital_output_ratio_multiplier_from_pollution_table,x);
%     [coeffs{23},fit{23},fun_text{23},modelFun{23}] = get_fit(industrial_capital_output_ratio_multiplier_from_pollution_table(:,1),industrial_capital_output_ratio_multiplier_from_pollution_table(:,2),false,false,names);
%     industrial_capital_output_ratio_multiplier_from_pollution_table = @(x) modelFun{23}(coeffs{23},x); 
%     industrial_capital_output_ratio_multiplier_from_pollution_table=Function('f',{x_cas},{industrial_capital_output_ratio_multiplier_from_pollution_table(x_cas)}); 
    industrial_capital_output_ratio_multiplier_table=[[1,1];[1.2,1.05];[1.4,1.12];[1.6,1.25];[1.8,1.35];[2,1.5]];
    industrial_capital_output_ratio_multiplier_table = @(x) interp_f(industrial_capital_output_ratio_multiplier_table,x);
%     [coeffs{24},fit{24},fun_text{24},modelFun{24}] = get_fit(industrial_capital_output_ratio_multiplier_table(:,1),industrial_capital_output_ratio_multiplier_table(:,2),false,false,names);
%     industrial_capital_output_ratio_multiplier_table = @(x) modelFun{24}(coeffs{24},x); 
%     industrial_capital_output_ratio_multiplier_table=Function('f',{x_cas},{industrial_capital_output_ratio_multiplier_table(x_cas)}); 
    capacity_utilization_fraction_table=[[1,1];[3,0.9];[5,0.7];[7,0.3];[9,0.1];[11,0.1]];
    capacity_utilization_fraction_table = @(x) interp_f(capacity_utilization_fraction_table,x);
%     [coeffs{25},fit{25},fun_text{25},modelFun{25}] = get_fit(capacity_utilization_fraction_table(:,1),capacity_utilization_fraction_table(:,2),false,false,names);
%     capacity_utilization_fraction_table = @(x) modelFun{25}(coeffs{25},x); 
%     capacity_utilization_fraction_table=Function('f',{x_cas},{capacity_utilization_fraction_table(x_cas)}); 
    jobs_per_hectare_table=[[2,2];[6,0.5];[10,0.4];[14,0.3];[18,0.27];[22,0.24];[26,0.2];[30,0.2]];
%     jobs_per_hectare_table=[[0,5];[2,2];[6,0.5];[10,0.4];[14,0.3];[18,0.27];[22,0.24];[30,0.2];[50,0.15]];
    jobs_per_hectare_table = @(x) interp_f(jobs_per_hectare_table,x);
%     [coeffs{26},fit{26},fun_text{26},modelFun{26}] = get_fit(jobs_per_hectare_table(:,1),jobs_per_hectare_table(:,2),false,false,names);
%     jobs_per_hectare_table = @(x) modelFun{26}(coeffs{26},x); 
%     jobs_per_hectare_table=Function('f',{x_cas},{jobs_per_hectare_table(x_cas)}); 
    jobs_per_industrial_capital_unit_table=[[50,0.37];[200,0.18];[350,0.12];[500,0.09];[650,0.07];[800,0.06]];
    jobs_per_industrial_capital_unit_table = @(x) interp_f(jobs_per_industrial_capital_unit_table,x);
%     [coeffs{27},fit{27},fun_text{27},modelFun{27}] = get_fit(jobs_per_industrial_capital_unit_table(:,1),jobs_per_industrial_capital_unit_table(:,2),false,false,names);
%     jobs_per_industrial_capital_unit_table = @(x) modelFun{27}(coeffs{27},x); 
%     jobs_per_industrial_capital_unit_table=Function('f',{x_cas},{jobs_per_industrial_capital_unit_table(x_cas)}); 
    jobs_per_service_capital_unit_table=[[50,1.1];[200,0.6];[350,0.35];[500,0.2];[650,0.15];[800,0.15];[950,0.15];[1100,0.15];[1250,0.15];[1400,0.15];[1550,0.15]];
    jobs_per_service_capital_unit_table = @(x) interp_f(jobs_per_service_capital_unit_table,x);
%     [coeffs{28},fit{28},fun_text{28},modelFun{28}] = get_fit(jobs_per_service_capital_unit_table(:,1),jobs_per_service_capital_unit_table(:,2),false,false,names);
%     jobs_per_service_capital_unit_table = @(x) modelFun{28}(coeffs{28},x); 
%     jobs_per_service_capital_unit_table=Function('f',{x_cas},{jobs_per_service_capital_unit_table(x_cas)}); 
    fraction_of_industrial_output_allocated_to_services_table_1=[[0,0.3];[0.5,0.2];[1,0.1];[1.5,0.05];[2,0]];
    fraction_of_industrial_output_allocated_to_services_table_1 = @(x) interp_f(fraction_of_industrial_output_allocated_to_services_table_1,x);
%     [coeffs{29},fit{29},fun_text{29},modelFun{29}] = get_fit(fraction_of_industrial_output_allocated_to_services_table_1(:,1),fraction_of_industrial_output_allocated_to_services_table_1(:,2),false,false,names);
%     fraction_of_industrial_output_allocated_to_services_table_1 = @(x) modelFun{29}(coeffs{29},x); 
%     fraction_of_industrial_output_allocated_to_services_table_1=Function('f',{x_cas},{fraction_of_industrial_output_allocated_to_services_table_1(x_cas)}); 
    fraction_of_industrial_output_allocated_to_services_table_2=[[0,0.3];[0.5,0.2];[1,0.1];[1.5,0.05];[2,0]];
    fraction_of_industrial_output_allocated_to_services_table_2 = @(x) interp_f(fraction_of_industrial_output_allocated_to_services_table_2,x);
%     [coeffs{30},fit{30},fun_text{30},modelFun{30}] = get_fit(fraction_of_industrial_output_allocated_to_services_table_2(:,1),fraction_of_industrial_output_allocated_to_services_table_2(:,2),false,false,names);
%     fraction_of_industrial_output_allocated_to_services_table_2 = @(x) modelFun{30}(coeffs{30},x); 
%     fraction_of_industrial_output_allocated_to_services_table_2=Function('f',{x_cas},{fraction_of_industrial_output_allocated_to_services_table_2(x_cas)}); 
    indicated_services_output_per_capita_table_1=[[0,40];[200,300];[400,640];[600,1000];[800,1220];[1000,1450];[1200,1650];[1400,1800];[1600,2000]];
%     indicated_services_output_per_capita_table_1=[[0,40];[41.5,94];[200,300];[400,640];[600,1000];[800,1220];[1000,1450];[1200,1650];[1400,1800];[1600,2000]];
    indicated_services_output_per_capita_table_1 = @(x) interp_f(indicated_services_output_per_capita_table_1,x);
%     [coeffs{31},fit{31},fun_text{31},modelFun{31}] = get_fit(indicated_services_output_per_capita_table_1(:,1),indicated_services_output_per_capita_table_1(:,2),false,false,names);
%     indicated_services_output_per_capita_table_1 = @(x) modelFun{31}(coeffs{31},x); 
%     indicated_services_output_per_capita_table_1=Function('f',{x_cas},{indicated_services_output_per_capita_table_1(x_cas)}); 
    indicated_services_output_per_capita_table_2=[[0,40];[200,300];[400,640];[600,1000];[800,1220];[1000,1450];[1200,1650];[1400,1800];[1600,2000]];
    indicated_services_output_per_capita_table_2 = @(x) interp_f(indicated_services_output_per_capita_table_2,x);
%     [coeffs{32},fit{32},fun_text{32},modelFun{32}] = get_fit(indicated_services_output_per_capita_table_2(:,1),indicated_services_output_per_capita_table_2(:,2),false,false,names);
%     indicated_services_output_per_capita_table_2 = @(x) modelFun{32}(coeffs{32},x); 
%     indicated_services_output_per_capita_table_2=Function('f',{x_cas},{indicated_services_output_per_capita_table_2(x_cas)}); 
    assimilation_half_life_mult_table=[[1,1];[251,11];[501,21];[751,31];[1001,41]];
%     assimilation_half_life_mult_table=[[0,1];[0.5,1];[1,1];[2.29,1.05];[3.53,1.10];[7.60,1.26];[9.439,1.333];[11,1.4];[12,1.44];[13,1.48];[14,1.52];[15,1.56];[251,11];[501,21];[751,31];[1001,41]];
    assimilation_half_life_mult_table = @(x) interp_f(assimilation_half_life_mult_table,x);
%     [coeffs{33},fit{33},fun_text{33},modelFun{33}] = get_fit(assimilation_half_life_mult_table(:,1),assimilation_half_life_mult_table(:,2),false,false,names);
%     assimilation_half_life_mult_table = @(x) modelFun{33}(coeffs{33},x); 
%     assimilation_half_life_mult_table=Function('f',{x_cas},{assimilation_half_life_mult_table(x_cas)}); 
    persistent_pollution_technology_change_mult_table=[[-1,0];[0,0]];
    persistent_pollution_technology_change_mult_table = @(x) interp_f(persistent_pollution_technology_change_mult_table,x);
%     [coeffs{34},fit{34},fun_text{34},modelFun{34}] = get_fit(persistent_pollution_technology_change_mult_table(:,1),persistent_pollution_technology_change_mult_table(:,2),false,false,names);
%     persistent_pollution_technology_change_mult_table = @(x) modelFun{34}(coeffs{34},x); 
%     persistent_pollution_technology_change_mult_table=Function('f',{x_cas},{persistent_pollution_technology_change_mult_table(x_cas)}); 
    mortality_45_to_64_table=[[20,0.0562];[30,0.0373];[40,0.0252];[50,0.0171];[60,0.0118];[70,0.0083];[80,0.006]];
    mortality_45_to_64_table = @(x) interp_f(mortality_45_to_64_table,x);
%     [coeffs{35},fit{35},fun_text{35},modelFun{35}] = get_fit(mortality_45_to_64_table(:,1),mortality_45_to_64_table(:,2),false,false,names);
%     mortality_45_to_64_table = @(x) modelFun{35}(coeffs{35},x); 
%     mortality_45_to_64_table=Function('f',{x_cas},{mortality_45_to_64_table(x_cas)}); 
    mortality_65_plus_table=[[20,0.13];[30,0.11];[40,0.09];[50,0.07];[60,0.06];[70,0.05];[80,0.04]];
    mortality_65_plus_table = @(x) interp_f(mortality_65_plus_table,x);
%     [coeffs{37},fit{37},fun_text{37},modelFun{37}] = get_fit(mortality_65_plus_table(:,1),mortality_65_plus_table(:,2),false,false,names);
%     mortality_65_plus_table = @(x) modelFun{37}(coeffs{37},x); 
%     mortality_65_plus_table=Function('f',{x_cas},{mortality_65_plus_table(x_cas)}); 
    mortality_0_to_14_table=[[20,0.0567];[30,0.0366];[40,0.0243];[50,0.0155];[60,0.0082];[70,0.0023];[80,0.001]];
    mortality_0_to_14_table = @(x) interp_f(mortality_0_to_14_table,x);
%     [coeffs{39},fit{39},fun_text{39},modelFun{39}] = get_fit(mortality_0_to_14_table(:,1),mortality_0_to_14_table(:,2),false,false,names);
%     mortality_0_to_14_table = @(x) modelFun{39}(coeffs{39},x); 
%     mortality_0_to_14_table=Function('f',{x_cas},{mortality_0_to_14_table(x_cas)}); 
    mortality_15_to_44_table=[[20,0.0266];[30,0.0171];[40,0.011];[50,0.0065];[60,0.004];[70,0.0016];[80,0.0008]];
    mortality_15_to_44_table = @(x) interp_f(mortality_15_to_44_table,x);
%     [coeffs{41},fit{41},fun_text{41},modelFun{41}] = get_fit(mortality_15_to_44_table(:,1),mortality_15_to_44_table(:,2),false,false,names);
%     mortality_15_to_44_table = @(x) modelFun{41}(coeffs{41},x); 
%     mortality_15_to_44_table=Function('f',{x_cas},{mortality_15_to_44_table(x_cas)}); 
    completed_multiplier_from_perceived_lifetime_table=[[0,3];[10,2.1];[20,1.6];[30,1.4];[40,1.3];[50,1.2];[60,1.1];[70,1.05];[80,1]];
    completed_multiplier_from_perceived_lifetime_table = @(x) interp_f(completed_multiplier_from_perceived_lifetime_table,x);
%     [coeffs{43},fit{43},fun_text{43},modelFun{43}] = get_fit(completed_multiplier_from_perceived_lifetime_table(:,1),completed_multiplier_from_perceived_lifetime_table(:,2),false,false,names);
%     completed_multiplier_from_perceived_lifetime_table = @(x) modelFun{43}(coeffs{43},x); 
%     completed_multiplier_from_perceived_lifetime_table=Function('f',{x_cas},{completed_multiplier_from_perceived_lifetime_table(x_cas)}); 
    family_response_to_social_norm_table=[[-0.2,0.5];[-0.1,0.6];[0,0.7];[0.1,0.85];[0.2,1]];
    family_response_to_social_norm_table = @(x) interp_f(family_response_to_social_norm_table,x);
%     [coeffs{44},fit{44},fun_text{44},modelFun{44}] = get_fit(family_response_to_social_norm_table(:,1),family_response_to_social_norm_table(:,2),false,false,names);
%     family_response_to_social_norm_table = @(x) modelFun{44}(coeffs{44},x); 
%     family_response_to_social_norm_table=Function('f',{x_cas},{family_response_to_social_norm_table(x_cas)}); 
    fecundity_multiplier_table=[[0,0];[10,0.2];[20,0.4];[30,0.6];[40,0.7];[50,0.75];[60,0.79];[70,0.84];[80,0.87]];
    fecundity_multiplier_table = @(x) interp_f(fecundity_multiplier_table,x);
%     [coeffs{46},fit{46},fun_text{46},modelFun{46}] = get_fit(fecundity_multiplier_table(:,1),fecundity_multiplier_table(:,2),false,false,names);
%     fecundity_multiplier_table = @(x) modelFun{46}(coeffs{46},x); 
%     fecundity_multiplier_table=Function('f',{x_cas},{fecundity_multiplier_table(x_cas)}); 
    fertility_control_effectiveness_table=[[0,0.75];[0.5,0.85];[1,0.9];[1.5,0.95];[2,0.98];[2.5,0.99];[3,1]];
%     fertility_control_effectiveness_table=[[0,0.75];[0.5,0.85];[1,0.9];[1.5,0.93];[2,0.95];[2.5,0.96];[3,0.97];[4,0.98];[5,0.99];[6,0.993];[7,0.993];[8,0.995];[9,0.997];[10,0.999]];
    fertility_control_effectiveness_table = @(x) interp_f(fertility_control_effectiveness_table,x);
%     [coeffs{47},fit{47},fun_text{47},modelFun{47}] = get_fit(fertility_control_effectiveness_table(:,1),fertility_control_effectiveness_table(:,2),false,false,names);
%     fertility_control_effectiveness_table = @(x) modelFun{47}(coeffs{47},x); 
%     fertility_control_effectiveness_table=Function('f',{x_cas},{fertility_control_effectiveness_table(x_cas)}); 
    fraction_services_allocated_to_fertility_control_table=[[-1,0];[0,0];[2,0.005];[4,0.015];[6,0.025];[8,0.03];[10,0.035];[20,0.04];[30,0.045]];
    fraction_services_allocated_to_fertility_control_table = @(x) interp_f(fraction_services_allocated_to_fertility_control_table,x);
%     [coeffs{49},fit{49},fun_text{49},modelFun{49}] = get_fit(fraction_services_allocated_to_fertility_control_table(:,1),fraction_services_allocated_to_fertility_control_table(:,2),false,false,names);
%     fraction_services_allocated_to_fertility_control_table = @(x) modelFun{49}(coeffs{49},x); 
%     fraction_services_allocated_to_fertility_control_table=Function('f',{x_cas},{fraction_services_allocated_to_fertility_control_table(x_cas)}); 
%     social_family_size_normal_table=[[0,1.25];[200,0.94];[400,0.715];[600,0.59];[800,0.5]];
    social_family_size_normal_table=[[0,1.25];[200,1];[400,0.9];[600,0.8];[800,0.75]];
    social_family_size_normal_table = @(x) interp_f(social_family_size_normal_table,x);
%     [coeffs{50},fit{50},fun_text{50},modelFun{50}] = get_fit(social_family_size_normal_table(:,1),social_family_size_normal_table(:,2),false,false,names);
%     social_family_size_normal_table = @(x) modelFun{50}(coeffs{50},x); 
%     social_family_size_normal_table=Function('f',{x_cas},{social_family_size_normal_table(x_cas)}); 
    crowding_multiplier_from_industry_table=[[0,0.5];[200,0.05];[400,-0.1];[600,-0.08];[800,-0.02];[1000,0.05];[1200,0.1];[1400,0.15];[1600,0.2]];
    crowding_multiplier_from_industry_table = @(x) interp_f(crowding_multiplier_from_industry_table,x);
%     [coeffs{51},fit{51},fun_text{51},modelFun{51}] = get_fit(crowding_multiplier_from_industry_table(:,1),crowding_multiplier_from_industry_table(:,2),false,false,names);
%     crowding_multiplier_from_industry_table = @(x) modelFun{51}(coeffs{51},x); 
%     crowding_multiplier_from_industry_table=Function('f',{x_cas},{crowding_multiplier_from_industry_table(x_cas)}); 
    fraction_of_population_urban_table=[[0,0];[2e+009,0.2];[4e+009,0.4];[6e+009,0.5];[8e+009,0.58];[1e+010,0.65];[1.2e+010,0.72];[1.4e+010,0.78];[1.6e+010,0.8]];
    fraction_of_population_urban_table = @(x) interp_f(fraction_of_population_urban_table,x);
%     [coeffs{52},fit{52},fun_text{52},modelFun{52}] = get_fit(fraction_of_population_urban_table(:,1),fraction_of_population_urban_table(:,2),false,false,names);
%     fraction_of_population_urban_table = @(x) modelFun{52}(coeffs{52},x); 
%     fraction_of_population_urban_table=Function('f',{x_cas},{fraction_of_population_urban_table(x_cas)}); 
%     health_services_per_capita_table=[[0,0];[250,20];[500,50];[750,95];[1000,140];[1250,175];[1500,200];[1750,220];[2000,230]];
    health_services_per_capita_table=[[0,0];[90,7.2];[250,20];[500,50];[750,95];[1000,140];[1250,175];[1500,200];[1750,220];[2000,230]];
    health_services_per_capita_table = @(x) interp_f(health_services_per_capita_table,x);
%     [coeffs{53},fit{53},fun_text{53},modelFun{53}] = get_fit(health_services_per_capita_table(:,1),health_services_per_capita_table(:,2),false,false,names);
%     health_services_per_capita_table = @(x) modelFun{53}(coeffs{53},x); 
%     health_services_per_capita_table=Function('f',{x_cas},{health_services_per_capita_table(x_cas)}); 
%     lifetime_multiplier_from_food_table=[[0,0];[1,1];[2,1.43];[3,1.5];[4,1.5];[5,1.5]];
    lifetime_multiplier_from_food_table=[[0,0];[1,1];[2,1.2];[3,1.3];[4,1.35];[5,1.4]];
    lifetime_multiplier_from_food_table = @(x) interp_f(lifetime_multiplier_from_food_table,x);
%     [coeffs{55},fit{55},fun_text{55},modelFun{55}] = get_fit(lifetime_multiplier_from_food_table(:,1),lifetime_multiplier_from_food_table(:,2),false,false,names);
%     lifetime_multiplier_from_food_table = @(x) modelFun{55}(coeffs{55},x); 
%     lifetime_multiplier_from_food_table=Function('f',{x_cas},{lifetime_multiplier_from_food_table(x_cas)}); 
    lifetime_multiplier_from_health_services_1_table=[[0,1];[20,1.1];[40,1.4];[60,1.6];[80,1.7];[100,1.8]];
    lifetime_multiplier_from_health_services_1_table = @(x) interp_f(lifetime_multiplier_from_health_services_1_table,x);
%     [coeffs{57},fit{57},fun_text{57},modelFun{57}] = get_fit(lifetime_multiplier_from_health_services_1_table(:,1),lifetime_multiplier_from_health_services_1_table(:,2),false,false,names);
%     lifetime_multiplier_from_health_services_1_table = @(x) modelFun{57}(coeffs{57},x); 
%     lifetime_multiplier_from_health_services_1_table=Function('f',{x_cas},{lifetime_multiplier_from_health_services_1_table(x_cas)}); 
%     lifetime_multiplier_from_health_services_2_table=[[0,1];[20,1.5];[40,1.9];[60,2];[80,2];[100,2]];
    lifetime_multiplier_from_health_services_2_table=[[0,1];[20,1.4];[40,1.6];[60,1.8];[80,1.95];[100,2]];
    lifetime_multiplier_from_health_services_2_table = @(x) interp_f(lifetime_multiplier_from_health_services_2_table,x);
%     [coeffs{58},fit{58},fun_text{58},modelFun{58}] = get_fit(lifetime_multiplier_from_health_services_2_table(:,1),lifetime_multiplier_from_health_services_2_table(:,2),false,false,names);
%     lifetime_multiplier_from_health_services_2_table = @(x) modelFun{58}(coeffs{58},x); 
%     lifetime_multiplier_from_health_services_2_table=Function('f',{x_cas},{lifetime_multiplier_from_health_services_2_table(x_cas)}); 
    lifetime_multiplier_from_persistent_pollution_table=[[0,1];[10,0.99];[20,0.97];[30,0.95];[40,0.9];[50,0.85];[60,0.75];[70,0.65];[80,0.55];[90,0.4];[100,0.2]];
%     lifetime_multiplier_from_persistent_pollution_table=[[0,1];[2,0.999];[4,0.998];[6,0.997];[8,0.996];[10,0.99];[20,0.97];[30,0.95];[40,0.9];[50,0.85];[60,0.75];[70,0.65];[80,0.55];[90,0.4];[100,0.2];[200,0.01];[300,0.01];[400,0.001]];
    lifetime_multiplier_from_persistent_pollution_table = @(x) interp_f(lifetime_multiplier_from_persistent_pollution_table,x);
    %     [coeffs{59},fit{59},fun_text{59},modelFun{59}] = get_fit(lifetime_multiplier_from_persistent_pollution_table(:,1),lifetime_multiplier_from_persistent_pollution_table(:,2),false,false,names);
%     lifetime_multiplier_from_persistent_pollution_table = @(x) modelFun{59}(coeffs{59},x); 
%     lifetime_multiplier_from_persistent_pollution_table=Function('f',{x_cas},{lifetime_multiplier_from_persistent_pollution_table(x_cas)}); 
    fraction_of_capital_allocated_to_obtaining_resources_1_table=[[0,1];[0.1,0.9];[0.2,0.7];[0.3,0.5];[0.4,0.2];[0.5,0.1];[0.6,0.05];[0.7,0.05];[0.8,0.05];[0.9,0.05];[1,0.05]];
    fraction_of_capital_allocated_to_obtaining_resources_1_table = @(x) interp_f(fraction_of_capital_allocated_to_obtaining_resources_1_table,x);
%     [coeffs{60},fit{60},fun_text{60},modelFun{60}] = get_fit(fraction_of_capital_allocated_to_obtaining_resources_1_table(:,1),fraction_of_capital_allocated_to_obtaining_resources_1_table(:,2),false,false,names);
%     fraction_of_capital_allocated_to_obtaining_resources_1_table = @(x) modelFun{60}(coeffs{60},x); 
%     fraction_of_capital_allocated_to_obtaining_resources_1_table=Function('f',{x_cas},{fraction_of_capital_allocated_to_obtaining_resources_1_table(x_cas)}); 
    fraction_of_capital_allocated_to_obtaining_resources_2_table=[[0,1];[0.1,0.2];[0.2,0.1];[0.3,0.05];[0.4,0.05];[0.5,0.05];[0.6,0.05];[0.7,0.05];[0.8,0.05];[0.9,0.05];[1,0.05]];
    fraction_of_capital_allocated_to_obtaining_resources_2_table = @(x) interp_f(fraction_of_capital_allocated_to_obtaining_resources_2_table,x);
%     [coeffs{61},fit{61},fun_text{61},modelFun{61}] = get_fit(fraction_of_capital_allocated_to_obtaining_resources_2_table(:,1),fraction_of_capital_allocated_to_obtaining_resources_2_table(:,2),false,false,names);
%     fraction_of_capital_allocated_to_obtaining_resources_2_table = @(x) modelFun{61}(coeffs{61},x); 
%     fraction_of_capital_allocated_to_obtaining_resources_2_table=Function('f',{x_cas},{fraction_of_capital_allocated_to_obtaining_resources_2_table(x_cas)}); 
    resource_technology_change_mult_table=[[-1,0];[0,0]];
    resource_technology_change_mult_table = @(x) interp_f(resource_technology_change_mult_table,x);
%     [coeffs{62},fit{62},fun_text{62},modelFun{62}] = get_fit(resource_technology_change_mult_table(:,1),resource_technology_change_mult_table(:,2),false,false,names);
%     resource_technology_change_mult_table = @(x) modelFun{62}(coeffs{62},x); 
%     resource_technology_change_mult_table=Function('f',{x_cas},{resource_technology_change_mult_table(x_cas)}); 
%     per_capita_resource_use_mult_table=[[0,0];[200,0.85];[400,2.6];[600,3.4];[800,3.8];[1000,4.1];[1200,4.4];[1400,4.7];[1600,5]];
    per_capita_resource_use_mult_table=[[0,0];[200,0.85];[400,2.6];[600,4.4];[800,5.4];[1000,6.2];[1200,6.8];[1400,7.0];[1600,7.0]];
%     per_capita_resource_use_mult_table=[[0,0];[20,0.085];[40,0.17];[100,0.43];[200,0.85];[400,2.6];[600,4.4];[800,5.4];[1000,6.2];[1200,6.8];[1400,7.0];[1600,7.0]];
    per_capita_resource_use_mult_table = @(x) interp_f(per_capita_resource_use_mult_table,x);
%     [coeffs{63},fit{63},fun_text{63},modelFun{63}] = get_fit(per_capita_resource_use_mult_table(:,1),per_capita_resource_use_mult_table(:,2),false,false,names);
%     per_capita_resource_use_mult_table = @(x) modelFun{63}(coeffs{63},x); 
%     per_capita_resource_use_mult_table=Function('f',{x_cas},{per_capita_resource_use_mult_table(x_cas)}); 
end

 %% Definitions:
persistent_pollution_transmission_delay=20;
% initial_perceived_life_expectancy=28.04366986;%57.94;
% perceived_life_expectancy(1)=initial_perceived_life_expectancy;
% initial_delayed_industrial_output_per_capita=41.5625;%250.5;
% delayed_industrial_output_per_capita(1)=initial_delayed_industrial_output_per_capita;
% initial_fertility_control_facilities_per_capita=0.0886879;%1.364;
% fertility_control_facilities_per_capita(1)=initial_fertility_control_facilities_per_capita;
initial_persistent_pollution_appearance_rate=1567875;%0;
persistent_pollution_appearance_rate(1)=initial_persistent_pollution_appearance_rate;
initial_effective_health_services_per_capita=7.2;%27.7327;
effective_health_services_per_capita(1)=initial_effective_health_services_per_capita;
% arable_land_erosion_factor=0.92;
w3_real_exhange_rate=7.18783;
LIFE_TIME_MULTIPLIER_FROM_SERVICES=1;%0.557;
investment_into_services=1;%2.07;
% initial_nonrenewable_resources_1900=2e+012;
% nonrenewable_resources_1900(1)=initial_nonrenewable_resources_1900;
% Nonrenewable_Resources(1)=initial_nonrenewable_resources_1900;
initial_delayed_labor_utilization_fraction=1.33617978;%0.73954;
Delayed_Labor_Utilization_Fraction(1)=initial_delayed_labor_utilization_fraction;
initial_current_agricultural_inputs=6.21013235e+09;%1.17e+011;
current_agricultural_inputs(1)=initial_current_agricultural_inputs;
% initial_food_ratio=1;%2;
% food_ratio(1)=initial_food_ratio;
GDP_pc_unit=1;
unit_agricultural_input=1;
unit_population=1;
ha_per_Gha=1e+009;
% ha_per_unit_of_pollution=4;
one_year=1;
% Ref_Hi_GDP=9508;
% Ref_Lo_GDP=24;
% Total_Land=1.91;
initial_arable_land=900000000;%2.05102e+009;
Arable_Land(1)=initial_arable_land;
land_fraction_harvested=0.7;%0.68;
potentially_arable_land_total=3.2e+009;
processing_loss=0.1;%0.35;
desired_food_ratio=2;
IND_OUT_IN_1970=7.9e+011;
average_life_of_agricultural_inputs_1=2;
average_life_of_agricultural_inputs_2=2;
land_yield_factor_1=1;%1.634;
% air_pollution_policy_implementation_time=4000;
average_life_of_land_normal=6000;%1000;
% land_life_policy_implementation_time=4000;
urban_and_industrial_land_development_time=10;
initial_urban_and_industrial_land=8200000;%4.73818e+007;
Urban_and_Industrial_Land(1)=initial_urban_and_industrial_land;
initial_potentially_arable_land=2.3e9;%potentially_arable_land_total-initial_arable_land-initial_urban_and_industrial_land;
Potentially_Arable_Land(1)=initial_potentially_arable_land;
initial_land_fertility=600;
Land_Fertility(1)=initial_land_fertility;
inherent_land_fertility=600;
food_shortage_perception_delay=2;
subsistence_food_per_capita=230;
social_discount=0.07;
industrial_output_per_capita_desired=400;
initial_industrial_capital=2.1e11;%5.4564e+012;
Industrial_Capital(1)=initial_industrial_capital;
average_life_of_industrial_capital_1=14;
average_life_of_industrial_capital_2=14;
fraction_of_industrial_output_allocated_to_consumption_const_1=0.43;
fraction_of_industrial_output_allocated_to_consumption_const_2=0.43;
industrial_capital_output_ratio_1=3;%3.64;
% industrial_equilibrium_time=4000;
labor_force_participation_fraction=0.75;
labor_utilization_fraction_delay_time=2;
average_life_of_service_capital_1=24.07;
average_life_of_service_capital_2=20;
service_capital_output_ratio_1=1;%0.579;
service_capital_output_ratio_2=1;
initial_service_capital=144000000000;%1.739e+012;
Service_Capital(1)=initial_service_capital;
% FINAL_TIME=2100;
% INITIAL_TIME=1995;
% SAVEPER=1;
% POLICY_YEAR=2101;
% TIME_STEP=0.0078125;
agricultural_material_toxicity_index=1;
assimilation_half_life_in_1970=1.5;%0.95;
desired_persistent_pollution_index=1.2;
fraction_of_agricultural_inputs_from_persistent_materials=0.001;
fraction_of_resources_from_persistent_materials=0.02;
industrial_material_toxicity_index=10;
industrial_material_emissions_factor=0.1;
persistent_pollution_generation_factor_1=1;%0;
initial_persistent_pollution=2.5e+07;%0;
Persistent_Pollution(1)=initial_persistent_pollution;
persistent_pollution_in_1970=1.36e+008;%2.5e7;
initial_population_54_to_64=190000000;%8.644e+008;
Population_45_To_64(1)=initial_population_54_to_64;
initial_population_0_to_14=650000000;%1.83211e+009;
Population_0_To_14(1)=initial_population_0_to_14;
initial_population_15_to_44=700000000;%2.604e+009;
Population_15_To_44(1)=initial_population_15_to_44;
initial_population_65_plus=60000000;%3.76387e+008;
Population_65_Plus(1)=initial_population_65_plus;
desired_completed_family_size_normal=4;%3.412;
income_expectation_averaging_time=3;%3.572;
lifetime_perception_delay=20;%23.54;
maximum_total_fertility_normal=12;
reproductive_lifetime=30;
% social_adjustment_delay=20;%26;
% fertility_control_effectiveness_time=4000;
% population_equilibrium_time=4000;
% zero_population_growth_time=4000;
% THOUSAND=1000;
health_services_impact_delay=20;%24.977;
life_expectancy_normal=30;%28;
desired_resource_use_rate=4.8e+009;
initial_nonrenewable_resources=1000000000000;%1.7659e+012;
Nonrenewable_Resources(1)=initial_nonrenewable_resources;
resource_use_factor_1=1;%0;
% frac_of_ind_capital_allocated_to_obtaining_res_switch_time=1990;
technology_development_delay=20;
% PRICE_OF_FOOD=0.22;
dt=0.5;
Land_Yield_Technology(1)=1;
land_yield_factor_2(1)=Land_Yield_Technology(1);
Persistent_Pollution_Technology(1)=1;
persistent_pollution_generation_factor_2(1)=Persistent_Pollution_Technology(1);
Resource_Conservation_Technology(1)=1;
resource_use_fact_2(1)=Resource_Conservation_Technology(1);
Perceived_Food_Ratio(1)=1.17097826;%food_ratio(1);
Agricultural_Inputs(1)=current_agricultural_inputs(1);
initial_average_industrial_output_per_capita=41.5625;
average_industrial_output_per_capita(1)=initial_average_industrial_output_per_capita;

% initial conditions are for 1900. If dt = 0.5, a shift=80 implies a shift in 1940, 150=1975
shift_all = T+1;
shift_fraction_of_industrial_output_allocated_to_agriculture=shift_all;
shift_indicated_food_per_capita=shift_all;
shift_average_life_agricultural_inputs=shift_all;
shift_resource_technology_change_rate=150;%shift_all;
shift_fraction_of_industrial_capital_for_obtaining_resources=shift_all;
shift_resource_use_factor=shift_all;
shift_lifetime_multiplier_from_health_services=80;
shift_fertility_control_effectiveness=T*10;%shift_all;
shift_births=T*10;%shift_all;
shift_desired_completed_family_size=T*10;%shift_all;
shift_persistent_pollution_technology_change_rate=shift_all;
shift_persistent_pollution_generation_factor=shift_all;
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

%% Cheat

fertility_control_facilities_per_capita = [0.0886879,0.0886879,0.0886879,0.0886879,0.08868839,...
0.08868377,0.08866563,0.08862472,0.08855218,0.08844018,...
0.08828231,0.08807371,0.08781108,0.08749259,0.08711785,...
0.08668769,0.08620398,0.08566941,0.08508734,0.08446168,...
0.08379671,0.08309699,0.08236725,0.08161233,0.08083704,...
0.0800462,0.07924448,0.07843645,0.07762651,0.07681885,...
0.07601747,0.07522618,0.07444853,0.07368787,0.07294729,...
0.07222969,0.07153771,0.07087379,0.07024017,0.06963885,...
0.06907169,0.06854035,0.06804632,0.06759095,0.06717546,...
0.06680092,0.06646831,0.06617849,0.06593223,0.06573023,...
0.06557311,0.06546142,0.06539567,0.06537632,0.06540379,...
0.06547849,0.06560079,0.06577103,0.06598959,0.06625679,...
0.06657298,0.06693854,0.0673538,0.06781917,0.06833504,...
0.06890182,0.06951996,0.07018992,0.07091217,0.07168723,...
0.07251565,0.07339801,0.07433492,0.07532705,0.07637511,...
0.07747985,0.07864209,0.07986269,0.08114258,0.08248275,...
0.08388424,0.08534816,0.08687571,0.08846812,0.09016694,...
0.09200694,0.09401677,0.09621957,0.09863347,0.10127227,...
0.10414593,0.10726113,0.11062178,0.11422946,0.11808385,...
0.12218301,0.12652356,0.13110099,0.13590995,0.14094454,...
0.14619845,0.15166523,0.15733838,0.1632115,0.1692784,...
0.17553318,0.18197028,0.18858459,0.19537141,0.20232654,...
0.20944627,0.21672739,0.22416721,0.23176355,0.23951416,...
0.2474164,0.25546738,0.26366405,0.2720033,0.28048209,...
0.28909746,0.29784666,0.30672718,0.31573681,0.32487368,...
0.33413631,0.34352362,0.35303495,0.36267007,0.37242919,...
0.38231297,0.3923225,0.40245899,0.41272387,0.42311892,...
0.43364628,0.44430856,0.45510864,0.46604944,0.47713422,...
0.48836668,0.49975097,0.51129174,0.52299401,0.53486322,...
0.54690509,0.55912564,0.57153115,0.58412809,0.59692302,...
0.60992231,0.62313163,0.63655606,0.65020014,0.66406796,...
0.67816324,0.69248939,0.7070496,0.72184687,0.73688407,...
0.75216396,0.76768925,0.78346259,0.79948665,0.81576412,...
0.83229771,0.84909022,0.8661445,0.8834635,0.90105027,...
0.91890771,0.93703731,0.95543948,0.97411379,0.99305921,...
1.01227429,1.0317573,1.05150636,1.07151949,1.0917947,...
1.11233003,1.13312364,1.15417381,1.17547903,1.197038,...
1.21884969,1.24091333,1.26322847,1.28579498,1.30861306,...
1.33168327,1.35500647,1.37858627,1.40243266,1.42656086,...
1.45099023,1.47574329,1.50084491,1.5263216,1.55220102,...
1.57851144,1.60528149,1.63254008,1.66031626,1.68863913,...
1.71753776,1.74704106,1.7771777,1.80797607,1.83946416,...
1.87166953,1.9046193,1.93834004,1.97285782,2.00819811,...
2.04438588,2.08144558,2.11943323,2.15842351,2.1985005,...
2.23975088,2.28225929,2.32610497,2.37135963,2.41808615,...
2.4663379,2.51615846,2.56758173,2.62062833,2.67532438,...
2.73172534,2.78989996,2.84991074,2.91180249,2.97560107,...
3.04131414,3.10893201,3.17842886,3.24976391,3.32288281,...
3.39771904,3.47425478,3.55260616,3.63296656,3.71556294,...
3.80062257,3.88834899,3.97890233,4.07237958,4.16880392,...
4.26812357,4.37021352,4.47487889,4.58186,4.69083864,...
4.80144511,4.91326571,5.02584783,5.1386389,5.25102799,...
5.36237737,5.47204617,5.57940804,5.68386398,5.78485153,...
5.88184623,5.97436223,6.06195963,6.14424878,6.22089229,...
6.29160547,6.35615546,6.41435935,6.46608167,6.51123151,...
6.54975941,6.5816542,6.60693977,6.6256719,6.63793522,...
6.64384118,6.64352453,6.63714019,6.62486033,6.60687184,...
6.58337392,6.55457596,6.52069555,6.48195659,6.43858747,...
6.3908196,6.33888602,6.2830202,6.22345504,6.16042189,...
6.09414975,6.02486456,5.95278856,5.87813974,5.80113008,...
5.72195884,5.64081283,5.55786883,5.47329527,5.38725345,...
5.29989848,5.21137993,5.12184236,5.03142412,4.94025518,...
4.84845862,4.75615181,4.66344741,4.57045395,4.47727629,...
4.38402046,4.29079625,4.19771521,4.10488902,4.01242812,...
3.92044052,3.82903083,3.73829953,3.64834235,3.55924979,...
3.47110682,3.38399262,3.29798047,3.21313764,3.12952545,...
3.04719847,2.96620487,2.88658682,2.80838084,2.73161813,...
2.65632494,2.58252283,2.51022898,2.43945653,2.37021481,...
2.30250962,2.23634343,2.17171564,2.10862281,2.04705884,...
1.98701522,1.92848118,1.87144394,1.81588883,1.76179953,...
1.70915818,1.65794552,1.60814105,1.55972315,1.51266917,...
1.4669556,1.42255814,1.37945187,1.33761126,1.29701035,...
1.25762256,1.21942062,1.18237674,1.14646281,1.11165055,...
1.07791162,1.04521774,1.01354079,0.98285291,0.95312652,...
0.92433443,0.89644992,0.86944691,0.84330002,0.81798454,...
0.79347638,0.76975206,0.7467886,0.72456353,0.70305484,...
0.68224095,0.66210073,0.64261344,0.62375877,0.60551684,...
0.58786819,0.57079379,0.55427506,0.53829388,0.52283258,...
0.50787394,0.49340119,0.47939784,0.46584774,0.45273514,...
0.44004467,0.4277614,0.41587083,0.40435895,0.39321216,...
0.38241736];

perceived_life_expectancy=[28.04366986,28.04366986,28.04366986,28.04366986,28.04379658,...
28.0441284,28.044715,28.04558877,28.04677147,28.04827796,...
28.05011849,28.05230007,28.05482728,28.05770291,28.06092829,...
28.06450362,28.06842829,28.07270117,28.07732086,28.08228595,...
28.08759517,28.09324757,28.09924266,28.10558047,28.11226167,...
28.11928758,28.12666025,28.13438244,28.14245763,28.15089026,...
28.15968616,28.1688526,28.17839817,28.18833249,28.19866601,...
28.20940977,28.22057517,28.23217374,28.24421694,28.25671608,...
28.26968223,28.28312628,28.29705883,28.31149029,28.3264308,...
28.34189032,28.3578786,28.3744052,28.39147955,28.40911089,...
28.42730838,28.44608104,28.46543783,28.48538761,28.5059392,...
28.52710138,28.54888288,28.57129245,28.59433879,28.61803065,...
28.64237676,28.66738591,28.69306688,28.71942854,28.74647978,...
28.77422968,28.80268749,28.83186266,28.86176494,28.8924043,...
28.923791,28.95593561,28.98884894,29.02254213,29.0570266,...
29.09231405,29.12841647,29.16534614,29.20311559,29.24173765,...
29.2812254,29.3215922,29.36285166,29.40501763,29.45008879,...
29.49962063,29.55479455,29.61647665,29.68526816,29.76154894,...
29.84551513,29.93721181,30.03656136,30.14338782,30.25743788,...
30.37839887,30.50591397,30.63959518,30.77903415,30.92381128,...
31.07350328,31.22768942,31.38595661,31.54790346,31.71314351,...
31.88130769,32.05204619,32.22502975,32.39995048,32.57652236,...
32.75448136,32.93358534,33.11361365,33.29436729,33.47567007,...
33.65736791,33.83932754,34.02143511,34.20359473,34.38572716,...
34.56776855,34.74966914,34.93139283,35.11291645,35.29422914,...
35.47533164,35.65623548,35.83696228,36.01754298,36.19801705,...
36.37843176,36.55884146,36.73929032,36.91981253,37.10043456,...
37.28117728,37.46205789,37.64308421,37.82424068,38.00549976,...
38.18682879,38.36819412,38.54956384,38.73090953,38.91220746,...
39.09343939,39.27459292,39.45566162,39.63664357,39.81753918,...
39.99834041,40.17901237,40.35950039,40.53973586,40.71964114,...
40.89913358,41.07812932,41.25654608,41.43430509,41.61133262,...
41.78756101,41.96292945,42.13738453,42.31088056,42.48337967,...
42.65485189,42.82527495,42.99463419,43.1629222,43.33013854,...
43.49628937,43.661387,43.82544946,43.98849994,44.15056632,...
44.31168075,44.47187915,44.63120081,44.78968812,44.9473862,...
45.10434263,45.26060712,45.41623121,45.57126804,45.72577202,...
45.87979866,46.03340425,46.18664573,46.33958079,46.49226792,...
46.64476616,46.79713424,46.94942766,47.10170151,47.25401152,...
47.40641422,47.55896676,47.71172656,47.86475095,48.01809691,...
48.17182074,48.32597873,48.4806275,48.63582424,48.79162682,...
48.94809393,49.10528506,49.26326048,49.42208117,49.58180873,...
49.74250524,49.90423316,50.06705517,50.23103401,50.3962317,...
50.56271055,50.73053343,50.89974999,51.07039653,51.24249681,...
51.41606323,51.59109788,51.76759349,51.94553412,52.12489578,...
52.30564686,52.48774847,52.67115474,52.85581307,53.0416576,...
53.22859875,53.41652405,53.60530194,53.7947847,53.98481078,...
54.17520647,54.36578733,54.55635967,54.74672176,54.9366649,...
55.12597426,55.3144016,55.50162089,55.68723934,55.87081057,...
56.05184497,56.22982489,56.40418685,56.57431805,56.73957318,...
56.89928939,57.05280062,57.19944714,57.33858451,57.46959174,...
57.59187836,57.70489044,57.80811616,57.90110492,57.98346684,...
58.05487025,58.11503895,58.1637494,58.20082815,58.2261499,...
58.23959713,58.2410174,58.23024199,58.20710065,58.1714336,...
58.12310128,58.06199222,57.98802959,57.90117662,57.8014405,...
57.68887454,57.56357901,57.42570141,57.27543594,57.11302227,...
56.93874257,56.75291958,56.55591421,56.34812286,56.12997453,...
55.90192758,55.66446648,55.41809722,55.16334162,54.90073234,...
54.63080869,54.3541132,54.07118856,53.78257507,53.48880826,...
53.19041689,52.88792111,52.58183088,52.27264456,51.96082756,...
51.64679446,51.33092323,51.0135638,50.69504337,50.37566983,...
50.05573418,49.73551223,49.41526593,49.09524438,48.77568502,...
48.45681432,48.13884914,47.82199828,47.5064625,47.19243442,...
46.88009857,46.56963133,46.26120087,45.95496705,45.65108136,...
45.3496869,45.0509184,44.75490229,44.46175677,44.17159196,...
43.88451002,43.60060528,43.31996448,43.04266693,42.76878472,...
42.49835753,42.23139991,41.96790805,41.7078653,41.45124676,...
41.1980224,40.9481592,40.70162299,40.45837983,40.21839703,...
39.98164402,39.74809296,39.5177192,39.29050154,39.06642241,...
38.84546781,38.62762727,38.4128937,38.20126309,37.99273408,...
37.78730703,37.58498348,37.38576559,37.18965584,36.99665672,...
36.80677052,36.61999911,36.43634382,36.25580528,36.07838302,...
35.90406266,35.73280626,35.56455819,35.39924985,35.23680373,...
35.07713671,34.92016274,34.76579506,34.61394792,34.46453805,...
34.31748601,34.17271707,34.03016152,33.88975455,33.75143612,...
33.61515077,33.48084759,33.34848021,33.21800679,33.08939011,...
32.96259756,32.83760111,32.71437732,32.59290716,32.47317596,...
32.35517311,32.23889194,32.12432933,32.01148549,31.90036354,...
31.79096928,31.68330616,31.57736459,31.47312479,31.37055925,...
31.2696347,31.17031383,31.07255659,30.97632141,30.88156608,...
30.78824857];

delayed_industrial_output_per_capita=[41.5625,41.5625,41.5625,41.5625,...
41.56251198,41.56293101,41.5644176,41.56780876,...
41.57405082,41.58414885,41.59912861,41.62000843,...
41.6477785,41.68338382,41.7277069,41.78156434,...
41.84570533,41.92081152,42.00749811,42.10631577,...
42.21775323,42.34224034,42.48015147,42.63180916,...
42.79748778,42.97741738,43.17178738,43.38075026,...
43.60442513,43.84290118,44.09624098,44.3644837,...
44.64764824,44.94573606,45.25873382,45.58661576,...
45.92934595,46.28688017,46.65916775,47.04615312,...
47.44777718,47.86397861,48.29469495,48.73986366,...
49.19942293,49.67331255,50.16147452,50.6638537,...
51.18039828,51.71106026,52.2557958,52.81456551,...
53.38733472,53.97407366,54.57475762,55.18936706,...
55.81788766,56.46031034,57.1166313,57.78685197,...
58.47097895,59.16902397,59.88100374,60.60693991,...
61.34685913,62.1007935,62.86878088,63.65086512,...
64.44709615,65.2575301,66.08222925,66.92126202,...
67.7747029,68.64263227,69.52513634,70.42230695,...
71.33424139,72.2610422,73.20281703,74.15967836,...
75.13174332,76.11913351,77.12197472,78.14039677,...
79.17453325,80.22434664,81.28966622,82.37022012,...
83.46566191,84.57559248,85.69957796,86.83716418,...
87.9878884,89.15128869,90.32691141,91.51431704,...
92.7130845,93.92281404,95.14312916,96.37367798,...
97.61413396,98.86419615,100.12358909,101.39206235,...
102.66938987,103.95536911,105.24981997,106.5525837,...
107.8635217,109.18251416,110.50945885,111.84426974,...
113.18687568,114.53721908,115.89525482,117.26095123,...
118.63429173,120.01527565,121.4039186,122.80025231,...
124.20432407,125.616196,127.035944,128.46365663,...
129.8994338,131.34338538,132.7956298,134.2562926,...
135.72550502,137.20340266,138.69012407,140.1858095,...
141.69059971,143.20463234,144.72803908,146.26094379,...
147.80346145,149.35569769,150.91774648,152.48968327,...
154.07156219,155.66341546,157.26525396,158.87706845,...
160.49883115,162.13049739,163.77200524,165.42327538,...
167.08421149,168.75470092,170.43461581,172.12381548,...
173.82215078,175.52946778,177.24561081,178.9704249,...
180.70375783,182.44546178,184.1953948,185.95342196,...
187.71941625,189.49325918,191.27484116,193.06406168,...
194.86082931,196.66506169,198.47668529,200.2956352,...
202.12185483,203.9552956,205.79591658,207.64368386,...
209.49856833,211.36054393,213.22958628,215.10567158,...
216.98877581,218.87887493,220.77594667,222.67997204,...
224.59093651,226.5088309,228.43365206,230.36540346,...
232.3040955,234.24974581,236.2023794,238.16202875,...
240.12873385,242.10254243,244.08351033,246.07170177,...
248.06718896,250.07004956,252.08036666,254.09822964,...
256.12373516,258.15698798,260.19810149,262.24719803,...
264.304409,266.36987471,268.44374024,270.52615203,...
272.61725515,274.71719106,276.82609589,278.94409919,...
281.07132292,283.20788094,285.35387859,287.50941269,...
289.67457159,291.8494355,294.03407698,296.22856156,...
298.43294935,300.6466528,302.86857873,305.09724016,...
307.33084691,309.56737909,311.80464701,314.04033987,...
316.27206541,318.49738212,320.71382533,322.91892838,...
325.11023963,327.2850357,329.43992735,331.57104324,...
333.67417739,335.74490643,337.77868062,339.77088731,...
341.71690546,343.61215253,345.45212455,347.23242619,...
348.94879396,350.59592822,352.16579043,353.64842335,...
355.03262747,356.30651856,357.45798393,358.47505586,...
359.34621547,360.06063656,360.60837537,360.9805131,...
361.16925835,361.16801487,360.97141992,360.57535802,...
359.97695388,359.17457659,358.16855588,356.96088402,...
355.55495634,353.95534494,352.16760102,350.19808214,...
348.05380112,345.74229392,343.2714921,340.64959982,...
337.88499042,334.98611966,331.96145332,328.81940701,...
325.56829938,322.21631648,318.77148225,315.24163398,...
311.63440234,307.95719536,304.2171857,300.42130013,...
296.57619241,292.6882458,288.76357599,284.80803458,...
280.82721288,276.82644612,272.81081775,268.78516265,...
264.7540715,260.72189611,256.69275505,252.67053972,...
248.65892053,244.66135326,240.6810855,236.72116316,...
232.78443697,228.873569,224.99103913,221.13915157,...
217.32004042,213.53567554,209.78786919,206.07828254,...
202.40843216,198.77969632,195.19332112,191.65042651,...
188.15201209,184.69896256,181.29205236,177.93195058,...
174.61922577,171.35435084,168.13770785,164.96959289,...
161.85022082,158.77972943,155.75818231,152.78557268,...
149.8618277,146.98681298,144.1603372,141.38215661,...
138.65197916,135.96946872,133.33424912,130.74590812,...
128.20400101,125.70805408,123.25756781,120.85202059,...
118.49087188,116.17356502,113.89952991,111.66818514,...
109.47893949,107.33119294,105.22433607,103.15775178,...
101.13081665,99.14290246,97.19337742,95.28160744,...
93.40695727,91.56879153,89.76647573,87.99937715,...
86.26686491,84.5683097,82.90308445,81.2705651,...
79.67013133,78.10116737,76.56306272,75.05521283,...
73.57701981,72.12789297,70.70724939,69.31451418,...
67.94912065,66.61051077,65.29813576,64.01145652,...
62.74994402,61.51307958,60.30035499,59.11127269,...
57.94534582,56.80209821,55.68106458,54.58178774,...
53.50381189,52.44667985,51.40993259,50.39311026,...
49.39575392,48.4174076,47.45762052,46.51594906,...
45.59195869,44.68522547,43.79533742,42.92189552,...
42.06451444,41.22282306,40.39646476,39.58509745,...
38.78839351,38.00603953,37.23773595,36.48319662,...
35.74214827,35.01433019,34.29949361,33.59740115,...
32.90782609,32.23055165,31.56537028,30.91208298,...
30.27049862];

% initialize using a non-default point
if T0 == 1950
    % overwrite init states
    World3_init_guesses = World3_init2();
    var_names = fields(World3_init_guesses);
    n_var = length(var_names);
    for var = 1:n_var
        eval([var_names{var} '(1) = World3_init_guesses.(''' var_names{var} ''');' ])
    end
end
delayed_industrial_output_per_capita = delayed_industrial_output_per_capita((T0-1900)*2+1:end);
perceived_life_expectancy = perceived_life_expectancy((T0-1900)*2+1:end);
fertility_control_facilities_per_capita = fertility_control_facilities_per_capita((T0-1900)*2+1:end);

 %% Dynamics:
 % TO DO: concatenate all variables into a vector. Create a vector function from that, then evaluate using the values from the previous timestep
 % TO DO: add forestry and desertification, perceived vs actual NRR
 disp('Simulating...')
 for t = 1:T 
%      population(t)=1.65e9*exp(0.18*t);
%      industrial_output(t)=0.67e11*exp(0.036*t);
%      industrial_output_per_capita(t)=industrial_output(t)/population(t);
%      persistent_pollution_index(t)=0.12*exp(0.03*t);

    % Population
    if t>1
       Population_0_To_14(t)=Population_0_To_14(t-1)+dt*((births(t-1)-deaths_0_to_14(t-1)-maturation_14_to_15(t-1)));
       Population_15_To_44(t)=Population_15_To_44(t-1)+dt*((maturation_14_to_15(t-1)-deaths_15_to_44(t-1)-maturation_44_to_45(t-1)));
       Population_45_To_64(t)=Population_45_To_64(t-1)+dt*((maturation_44_to_45(t-1)-deaths_45_to_64(t-1)-maturation_64_to_65(t-1)));
       Population_65_Plus(t)=Population_65_Plus(t-1)+dt*((maturation_64_to_65(t-1)-deaths_65_plus(t-1))); 
    end
    population(t)=Population_0_To_14(t)+Population_15_To_44(t)+Population_45_To_64(t)+Population_65_Plus(t);

    % Resources 1
    if t>1
        Nonrenewable_Resources(t)=Nonrenewable_Resources(t-1)+dt*((-resource_usage_rate(t-1)));
        Resource_Conservation_Technology(t)=Resource_Conservation_Technology(t-1)+dt*(resource_technology_change_rate(t-1)); 
        resource_use_fact_2(t)=(resource_use_fact_2(t-1)+dt*sum(Resource_Conservation_Technology(max(1,t-technology_development_delay):t-1))/min(t-1,technology_development_delay))/2; 
    end
    resource_use_factor(t)=resource_use_fact_2(t)/(1+exp(-40*(t-shift_resource_use_factor)))-resource_use_factor_1/(1+exp(-40*(t-shift_resource_use_factor)))+resource_use_factor_1;
    fraction_of_resources_remaining(t)=Nonrenewable_Resources(t)/initial_nonrenewable_resources;%initial_nonrenewable_resources_1900;
    
    % Agriculture 1
    if t>1
        land_yield_factor_2(t)=(land_yield_factor_2(t-1)+dt*sum(Land_Yield_Technology(max(1,t-technology_development_delay):t-1))/min(t-1,technology_development_delay))/2;
    end
    land_yield_multiplier_from_technology(t)=land_yield_factor_2(t)/(1+exp(-40*(t-shift_land_yield_multiplier_from_technology)))-land_yield_factor_1/(1+exp(-40*(t-shift_land_yield_multiplier_from_technology)))+land_yield_factor_1;
    
    % Pollution 1
    if t>1
        Persistent_Pollution_Technology(t)=Persistent_Pollution_Technology(t-1)+dt*(persistent_pollution_technology_change_rate(t-1));
        persistent_pollution_generation_factor_2(t)=(persistent_pollution_generation_factor_2(t-1)+dt*sum(Persistent_Pollution_Technology(max(1,t-technology_development_delay):t-1))/min(t-1,technology_development_delay))/2;
        Persistent_Pollution(t)=Persistent_Pollution(t-1)+dt*((persistent_pollution_appearance_rate(t-1)-persistent_pollution_assimilation_rate(t-1)));
    end
    persistent_pollution_generation_factor(t)=persistent_pollution_generation_factor_2(t)/(1+exp(-40*(t-shift_persistent_pollution_generation_factor)))-persistent_pollution_generation_factor_1/(1+exp(-40*(t-shift_persistent_pollution_generation_factor)))+persistent_pollution_generation_factor_1;
    persistent_pollution_index(t)=Persistent_Pollution(t)/persistent_pollution_in_1970;
    
    % Industry 1
    if t>1
         Industrial_Capital(t)=Industrial_Capital(t-1)+dt*((industrial_capital_investment(t-1)-industrial_capital_depreciation(t-1)));
         Delayed_Labor_Utilization_Fraction(t)=Delayed_Labor_Utilization_Fraction(t-1)+dt*(labor_utilization_fraction(t-1)-Delayed_Labor_Utilization_Fraction(t-1))/labor_utilization_fraction_delay_time;
         Service_Capital(t)=Service_Capital(t-1)+dt*((service_capital_investment(t-1)-service_capital_depreciation(t-1))); 
    end
    industrial_capital_output_ratio_mult_from_pollution_tech(t)=industrial_capital_output_ratio_multiplier_from_pollution_table(persistent_pollution_generation_factor(t));
	industrial_capital_output_ratio_mult_from_land_yield_tech(t)=industrial_capital_output_ratio_multiplier_table(land_yield_multiplier_from_technology(t));
    industrial_capital_output_ratio_mult_from_res_conserv_tech(t)=industrial_capital_output_ratio_multiplier_from_resource_table(resource_use_factor(t));
    capacity_utilization_fraction(t)=capacity_utilization_fraction_table(Delayed_Labor_Utilization_Fraction(t));
    industrial_capital_output_ratio_2(t)=industrial_capital_output_ratio_mult_from_res_conserv_tech(t)*industrial_capital_output_ratio_mult_from_land_yield_tech(t)*industrial_capital_output_ratio_mult_from_pollution_tech(t);
	industrial_capital_output_ratio(t)=industrial_capital_output_ratio_2(t)/(1+exp(-40*(t-shift_industrial_capital_output_ratio)))-industrial_capital_output_ratio_1/(1+exp(-40*(t-shift_industrial_capital_output_ratio)))+industrial_capital_output_ratio_1;
 	fraction_of_capital_allocated_to_obtaining_resources_1(t)=fraction_of_capital_allocated_to_obtaining_resources_1_table(fraction_of_resources_remaining(t));
	fraction_of_capital_allocated_to_obtaining_resources_2(t)=fraction_of_capital_allocated_to_obtaining_resources_2_table(fraction_of_resources_remaining(t));
    fraction_of_industrial_capital_alloc_to_obtaining_res(t)=fraction_of_capital_allocated_to_obtaining_resources_2(t)/(1+exp(-40*(t-shift_fraction_of_industrial_capital_for_obtaining_resources)))-fraction_of_capital_allocated_to_obtaining_resources_1(t)/(1+exp(-40*(t-shift_fraction_of_industrial_capital_for_obtaining_resources)))+fraction_of_capital_allocated_to_obtaining_resources_1(t);
    if t>1
        industrial_output(t)=(((Industrial_Capital(t)))*(1-fraction_of_industrial_capital_alloc_to_obtaining_res(t)))*(capacity_utilization_fraction(t))/industrial_capital_output_ratio(t);
    else
        industrial_output(1)=66500000000;
    end
    industrial_output_2005_value(t)=industrial_output(t)*w3_real_exhange_rate;
    industrial_output_per_capita(t)=industrial_output(t)/population(t);
    
    % Resources 2
    per_capita_resource_use_multiplier(t)=per_capita_resource_use_mult_table(industrial_output_per_capita(t)/GDP_pc_unit);
    resource_usage_rate(t)=population(t)*per_capita_resource_use_multiplier(t)*resource_use_factor(t);
    resource_technology_change_rate_multiplier(t)=resource_technology_change_mult_table(1-resource_usage_rate(t)/desired_resource_use_rate);
	resource_technology_change_rate(t)=Resource_Conservation_Technology(t)*resource_technology_change_rate_multiplier(t)/(1+exp(-40*(t-shift_resource_technology_change_rate)));

    % Agriculture 2
     if t>1
         Arable_Land(t)=Arable_Land(t-1)+dt*(land_development_rate(t-1)-land_erosion_rate(t-1)-land_removal_for_urban_and_industrial_use(t-1));
         Potentially_Arable_Land(t)=Potentially_Arable_Land(t-1)+dt*((-land_development_rate(t-1)));
         Agricultural_Inputs(t)=Agricultural_Inputs(t-1)+dt*(current_agricultural_inputs(t-1)-Agricultural_Inputs(t-1))/average_life_agricultural_inputs(t-1);
         Urban_and_Industrial_Land(t)=Urban_and_Industrial_Land(t-1)+dt*((land_removal_for_urban_and_industrial_use(t-1)));
         Land_Yield_Technology(t)=Land_Yield_Technology(t-1)+dt*(land_yield_technology_change_rate(t-1));
         Land_Fertility(t)=Land_Fertility(t-1)+dt*((land_fertility_regeneration(t-1)-land_fertility_degredation(t-1)));
         Perceived_Food_Ratio(t)=Perceived_Food_Ratio(t-1)+dt*(food_ratio(t-1)-Perceived_Food_Ratio(t-1))/food_shortage_perception_delay;
     end
    urban_and_industrial_land_required_per_capita(t)=urban_and_industrial_land_required_per_capita_table(industrial_output_per_capita(t)/GDP_pc_unit);
	urban_and_industrial_land_required(t)=urban_and_industrial_land_required_per_capita(t)*population(t);
    average_life_agricultural_inputs(t)=average_life_of_agricultural_inputs_2/(1+exp(-40*(t-shift_average_life_agricultural_inputs)))-average_life_of_agricultural_inputs_1/(1+exp(-40*(t-shift_average_life_agricultural_inputs)))+average_life_of_agricultural_inputs_1;
    land_fertility_degredation_rate(t)=land_fertility_degredation_rate_table(persistent_pollution_index(t)); % add deforestation. Should also be a function of arable land
    land_fertility_degredation(t)=Land_Fertility(t)*land_fertility_degredation_rate(t); 
    Arable_Land_in_Gigahectares(t)=Arable_Land(t)/ha_per_Gha;
    land_yield_multipler_from_air_pollution_1(t)=land_yield_multipler_from_air_pollution_table_1(industrial_output(t)/IND_OUT_IN_1970);
	land_yield_multiplier_from_air_pollution_2(t)=land_yield_multipler_from_air_pollution_table_2(industrial_output(t)/IND_OUT_IN_1970);
	land_yield_multiplier_from_air_pollution(t)=land_yield_multiplier_from_air_pollution_2(t)/(1+exp(-40*(t-shift_land_yield_multiplier_from_air_pollution)))-land_yield_multipler_from_air_pollution_1(t)/(1+exp(-40*(t-shift_land_yield_multiplier_from_air_pollution)))+land_yield_multipler_from_air_pollution_1(t);
    if t>1
        fraction_of_agricultural_inputs_for_land_maintenance(t)=fraction_of_agricultural_inputs_for_land_maintenance_table(Perceived_Food_Ratio(t));
    else
        fraction_of_agricultural_inputs_for_land_maintenance(t)=0.04;
    end  
    if t>1
        agricultural_input_per_hectare(t)=Agricultural_Inputs(t)*(1-fraction_of_agricultural_inputs_for_land_maintenance(t))/Arable_Land(t);
    else
        agricultural_input_per_hectare(t)=16/3;
    end
    land_yield_multiplier_from_capital(t)=land_yield_multiplier_from_capital_table(agricultural_input_per_hectare(t)/unit_agricultural_input);
    land_yield(t)=land_yield_multiplier_from_technology(t)*Land_Fertility(t)*land_yield_multiplier_from_capital(t)*land_yield_multiplier_from_air_pollution(t); % land yield should be function of potentially arable land (most efficient land developed first)!
    land_fr_cult(t)=Arable_Land(t)/potentially_arable_land_total; 
    land_life_multiplier_from_land_yield_1(t)=land_life_multiplier_from_land_yield_table_1(land_yield(t)/inherent_land_fertility);
	land_life_multiplier_from_land_yield_2(t)=land_life_multiplier_from_land_yield_table_2(land_yield(t)/inherent_land_fertility);
%     land_life_multiplier_from_land_yield(t)=land_life_multiplier_from_land_yield_1(t)+(land_life_multiplier_from_land_yield_2(t)-land_life_multiplier_from_land_yield_1(t))*arable_land_erosion_factor;
	land_life_multiplier_from_land_yield(t)=land_life_multiplier_from_land_yield_2(t)/(1+exp(-40*(t-shift_land_life_multiplier_from_land_yield)))-land_life_multiplier_from_land_yield_1(t)/(1+exp(-40*(t-shift_land_life_multiplier_from_land_yield)))+land_life_multiplier_from_land_yield_1(t);
    average_life_of_land(t)=average_life_of_land_normal*land_life_multiplier_from_land_yield(t);
	land_erosion_rate(t)=Arable_Land(t)/average_life_of_land(t);
	land_removal_for_urban_and_industrial_use(t)=max(0,urban_and_industrial_land_required(t)-Urban_and_Industrial_Land(t))/urban_and_industrial_land_development_time;
    food(t)=land_yield(t)*Arable_Land(t)*land_fraction_harvested*(1-processing_loss);
    food_per_capita(t)=food(t)/population(t);
	arable_land_harvested(t)=Arable_Land(t)*land_fraction_harvested;
    development_cost_per_hectare(t)=development_cost_per_hectare_table(Potentially_Arable_Land(t)/potentially_arable_land_total);
    indicated_food_per_capita_1(t)=indicated_food_per_capita_table_1(industrial_output_per_capita(t)/GDP_pc_unit);
	indicated_food_per_capita_2(t)=indicated_food_per_capita_table_2(industrial_output_per_capita(t)/GDP_pc_unit);
	indicated_food_per_capita(t)=indicated_food_per_capita_2(t)/(1+exp(-40*(t-shift_indicated_food_per_capita)))-indicated_food_per_capita_1(t)/(1+exp(-40*(t-shift_indicated_food_per_capita)))+indicated_food_per_capita_1(t);
    fraction_of_industrial_output_allocated_to_agriculture_1(t)=fraction_industrial_output_allocated_to_agriculture_table_1(food_per_capita(t)/indicated_food_per_capita(t));
	fraction_of_industrial_output_allocated_to_agriculture_2(t)=fraction_industrial_output_allocated_to_agriculture_table_2(food_per_capita(t)/indicated_food_per_capita(t));
	fraction_of_industrial_output_allocated_to_agriculture(t)=fraction_of_industrial_output_allocated_to_agriculture_2(t)/(1+exp(-40*(t-shift_fraction_of_industrial_output_allocated_to_agriculture)))-fraction_of_industrial_output_allocated_to_agriculture_1(t)/(1+exp(-40*(t-shift_fraction_of_industrial_output_allocated_to_agriculture)))+fraction_of_industrial_output_allocated_to_agriculture_1(t);
    total_agricultural_investment(t)=industrial_output(t)*fraction_of_industrial_output_allocated_to_agriculture(t);
    marginal_land_yield_multiplier_from_capital(t)=marginal_land_yield_multiplier_from_capital_table(agricultural_input_per_hectare(t)/unit_agricultural_input);
    marginal_productivity_of_agricultural_inputs(t)=average_life_agricultural_inputs(t)*land_yield(t)*marginal_land_yield_multiplier_from_capital(t)/land_yield_multiplier_from_capital(t);
    marginal_productivity_of_land_development(t)=land_yield(t)/(development_cost_per_hectare(t)*social_discount);
    fraction_of_agricultural_inputs_allocated_to_land_development(t)=fraction_of_agricultural_inputs_allocated_to_land_dev_table((marginal_productivity_of_land_development(t)/marginal_productivity_of_agricultural_inputs(t)));
    land_development_rate(t)=total_agricultural_investment(t)*fraction_of_agricultural_inputs_allocated_to_land_development(t)/development_cost_per_hectare(t);
    food_ratio(t)=(food_per_capita(t)/subsistence_food_per_capita);
    current_agricultural_inputs(t)=(total_agricultural_investment(t)*(1-fraction_of_agricultural_inputs_allocated_to_land_development(t)));
    land_yield_technology_change_rate_multiplier(t)=land_yield_technology_change_rate_multiplier_table(desired_food_ratio-food_ratio(t));
    land_yield_technology_change_rate(t)=Land_Yield_Technology(t)*land_yield_technology_change_rate_multiplier(t)/(1+exp(-40*(t-shift_land_yield_technology_change_rate)));
 	land_fertility_regeneration_time(t)=land_fertility_regeneration_time_table(fraction_of_agricultural_inputs_for_land_maintenance(t));
    land_fertility_regeneration(t)=(inherent_land_fertility-Land_Fertility(t))/land_fertility_regeneration_time(t);
    
    % Pollution 2   
    persistent_pollution_generation_agriculture(t)=agricultural_input_per_hectare(t)*Arable_Land(t)*fraction_of_agricultural_inputs_from_persistent_materials*agricultural_material_toxicity_index;
    persistent_pollution_generation_industry(t)=per_capita_resource_use_multiplier(t)*population(t)*fraction_of_resources_from_persistent_materials*industrial_material_emissions_factor*industrial_material_toxicity_index;
    persistent_pollution_generation_rate(t)=(persistent_pollution_generation_industry(t)+persistent_pollution_generation_agriculture(t))*(persistent_pollution_generation_factor(t));
    if t<4
        persistent_pollution_appearance_rate(t)=persistent_pollution_appearance_rate(1);
    else
        % note: these coefficients were estimated using smooth3_test and were not analyticaly derived!
        persistent_pollution_appearance_rate(t)=(dt*3/persistent_pollution_transmission_delay)^3*persistent_pollution_generation_rate(t-3)+(1 + 1/(-5 + 1/(5 + 1/(-8 - 1/3))))*persistent_pollution_appearance_rate(t-3)+(-3 + 1/(2 + 1/(3 + 1/(4 + 1/(5 + 1/10)))))*persistent_pollution_appearance_rate(t-2)+(0.5*3*(1+3*12)/20)*persistent_pollution_appearance_rate(t-1);
    end
   
    assimilation_half_life_multiplier(t)=assimilation_half_life_mult_table(persistent_pollution_index(t));
    assimilation_half_life(t)=assimilation_half_life_in_1970*assimilation_half_life_multiplier(t);
    persistent_pollution_technology_change_multiplier(t)=persistent_pollution_technology_change_mult_table(1-persistent_pollution_index(t)/desired_persistent_pollution_index);
    persistent_pollution_assimilation_rate(t)=Persistent_Pollution(t)/(assimilation_half_life(t)*1.4);
    persistent_pollution_technology_change_rate(t)=Persistent_Pollution_Technology(t)*persistent_pollution_technology_change_multiplier(t)/(1+exp(-40*(t-shift_persistent_pollution_technology_change_rate)))-0/(1+exp(-40*(t-shift_persistent_pollution_technology_change_rate)))+0;
    
    % Industry 2
    service_capital_output_ratio(t)=service_capital_output_ratio_2/(1+exp(-40*(t-shift_service_capital_output_ratio)))-service_capital_output_ratio_1/(1+exp(-40*(t-shift_service_capital_output_ratio)))+service_capital_output_ratio_1;
    if t>1
        service_output(t)=((Service_Capital(t)))*(capacity_utilization_fraction(t))/service_capital_output_ratio(t);
    else
        service_output(t)=population(t)*90;
    end
    service_output_per_capita(t)=service_output(t)/population(t);
    jobs_per_industrial_capital_unit(t)=(jobs_per_industrial_capital_unit_table(industrial_output_per_capita(t)/GDP_pc_unit))*0.001;
    jobs_per_service_capital_unit(t)=(jobs_per_service_capital_unit_table(service_output_per_capita(t)/GDP_pc_unit))*0.001;
    jobs_per_hectare(t)=jobs_per_hectare_table(agricultural_input_per_hectare(t)/unit_agricultural_input);
    potential_jobs_agricultural_sector(t)=((jobs_per_hectare(t)))*(Arable_Land(t));
    potential_jobs_industrial_sector(t)=Industrial_Capital(t)*jobs_per_industrial_capital_unit(t);
    potential_jobs_service_sector(t)=((Service_Capital(t)))*(jobs_per_service_capital_unit(t));
	jobs(t)=potential_jobs_industrial_sector(t)+potential_jobs_agricultural_sector(t)+potential_jobs_service_sector(t);
	labor_force(t)=(Population_15_To_44(t)+Population_45_To_64(t))*labor_force_participation_fraction;
	labor_utilization_fraction(t)=jobs(t)/labor_force(t);
	indicated_services_output_per_capita_1(t)=indicated_services_output_per_capita_table_1(industrial_output_per_capita(t)/GDP_pc_unit);
	indicated_services_output_per_capita_2(t)=indicated_services_output_per_capita_table_2(industrial_output_per_capita(t)/GDP_pc_unit);
	average_life_of_service_capital(t)=average_life_of_service_capital_2/(1+exp(-40*(t-shift_average_life_of_service_capital)))-average_life_of_service_capital_1/(1+exp(-40*(t-shift_average_life_of_service_capital)))+average_life_of_service_capital_1;
	indicated_services_output_per_capita(t)=indicated_services_output_per_capita_2(t)/(1+exp(-40*(t-shift_indicated_services_output_per_capita)))-indicated_services_output_per_capita_1(t)/(1+exp(-40*(t-shift_indicated_services_output_per_capita)))+indicated_services_output_per_capita_1(t);
	service_capital_depreciation(t)=Service_Capital(t)/average_life_of_service_capital(t);
    average_life_of_industrial_capital(t)=average_life_of_industrial_capital_2/(1+exp(-40*(t-shift_average_life_of_industrial_capital)))-average_life_of_industrial_capital_1/(1+exp(-40*(t-shift_average_life_of_industrial_capital)))+average_life_of_industrial_capital_1;
	
	industrial_capital_depreciation(t)=Industrial_Capital(t)/average_life_of_industrial_capital(t);
    fraction_of_industrial_output_alloc_to_consumption_const(t)=fraction_of_industrial_output_allocated_to_consumption_const_2/(1+exp(-40*(t-shift_fraction_of_industrial_output_for_consumption_const)))-fraction_of_industrial_output_allocated_to_consumption_const_1/(1+exp(-40*(t-shift_fraction_of_industrial_output_for_consumption_const)))+fraction_of_industrial_output_allocated_to_consumption_const_1;
	fraction_of_industrial_output_alloc_to_consumption_var(t)=frac_of_industrial_output_allocated_to_consumption_var_table(industrial_output_per_capita(t)/industrial_output_per_capita_desired);
    fraction_of_industrial_output_allocated_to_services_1(t)=fraction_of_industrial_output_allocated_to_services_table_1(service_output_per_capita(t)/indicated_services_output_per_capita(t))*investment_into_services;
	fraction_of_industrial_output_allocated_to_services_2(t)=fraction_of_industrial_output_allocated_to_services_table_2(service_output_per_capita(t)/indicated_services_output_per_capita(t));
    fraction_of_industrial_output_allocated_to_consumption(t)=fraction_of_industrial_output_alloc_to_consumption_var(t)/(1+exp(-40*(t-shift_fraction_of_industrial_output_allocated_to_consumption)))-fraction_of_industrial_output_alloc_to_consumption_const(t)/(1+exp(-40*(t-shift_fraction_of_industrial_output_allocated_to_consumption)))+fraction_of_industrial_output_alloc_to_consumption_const(t);
    fraction_of_industrial_output_allocated_to_services(t)=fraction_of_industrial_output_allocated_to_services_2(t)/(1+exp(-40*(t-shift_fraction_of_industrial_output_allocated_to_services)))-fraction_of_industrial_output_allocated_to_services_1(t)/(1+exp(-40*(t-shift_fraction_of_industrial_output_allocated_to_services)))+fraction_of_industrial_output_allocated_to_services_1(t);
    fraction_of_industrial_output_allocated_to_investment(t)=(1-fraction_of_industrial_output_allocated_to_agriculture(t)-fraction_of_industrial_output_allocated_to_services(t)-fraction_of_industrial_output_allocated_to_consumption(t));
    industrial_capital_investment(t)=((industrial_output(t)))*(fraction_of_industrial_output_allocated_to_investment(t));
    service_capital_investment(t)=((industrial_output(t)))*(fraction_of_industrial_output_allocated_to_services(t));
    if t>1
       average_industrial_output_per_capita(t)=average_industrial_output_per_capita(t-1)+dt*(industrial_output_per_capita(t-1)-average_industrial_output_per_capita(t-1))/income_expectation_averaging_time;
%         delayed_industrial_output_per_capita(t)=(delayed_industrial_output_per_capita(t-1)+dt*sum(industrial_output_per_capita(max(1,t-social_adjustment_delay):t-1))/min(t-1,social_adjustment_delay))/2; 
    end
    
    % Fertility
    if t>1
% % % %        fertility_control_facilities_per_capita(t)=(fertility_control_facilities_per_capita(t-1)+dt*sum(fertility_control_allocation_per_capita(max(1,t-health_services_impact_delay):t-1))/min(t-1,health_services_impact_delay))/2;
% % % %        perceived_life_expectancy(t)=life_expectancy(t-1)/lifetime_perception_delay+(1-1/lifetime_perception_delay)*perceived_life_expectancy(t-1);%dt*sum(life_expectancy(max(1,t-lifetime_perception_delay):t-1))/min(t-1,lifetime_perception_delay))/2;
       effective_health_services_per_capita(t)=effective_health_services_per_capita(t-1)+dt*(health_services_per_capita(t-1)-effective_health_services_per_capita(t-1))/health_services_impact_delay; 
    end
    crowding_multiplier_from_industry(t)=crowding_multiplier_from_industry_table(industrial_output_per_capita(t)/GDP_pc_unit);
    fraction_of_population_urban(t)=fraction_of_population_urban_table(population(t)/unit_population);
    lifetime_multiplier_from_crowding(t)=1-(crowding_multiplier_from_industry(t)*fraction_of_population_urban(t));
    family_income_expectation(t)=(industrial_output_per_capita(t)-average_industrial_output_per_capita(t))/average_industrial_output_per_capita(t);
    social_family_size_normal(t)=social_family_size_normal_table(delayed_industrial_output_per_capita(t)/GDP_pc_unit);
    family_response_to_social_norm(t)=family_response_to_social_norm_table(family_income_expectation(t));
    lifetime_multiplier_from_food(t)=lifetime_multiplier_from_food_table(food_per_capita(t)/subsistence_food_per_capita);
    lifetime_multiplier_from_health_services_1(t)=lifetime_multiplier_from_health_services_1_table(effective_health_services_per_capita(t)/GDP_pc_unit);
	lifetime_multiplier_from_health_services_2(t)=lifetime_multiplier_from_health_services_2_table(effective_health_services_per_capita(t)/GDP_pc_unit);
	lifetime_multiplier_from_health_services(t)=lifetime_multiplier_from_health_services_2(t)/(1+exp(-40*(t-shift_lifetime_multiplier_from_health_services)))-lifetime_multiplier_from_health_services_1(t)/(1+exp(-40*(t-shift_lifetime_multiplier_from_health_services)))+lifetime_multiplier_from_health_services_1(t);
	lifetime_multiplier_from_persistent_pollution(t)=lifetime_multiplier_from_persistent_pollution_table(persistent_pollution_index(t));
    life_expectancy(t)=life_expectancy_normal*lifetime_multiplier_from_food(t)*lifetime_multiplier_from_health_services(t)*lifetime_multiplier_from_persistent_pollution(t)*lifetime_multiplier_from_crowding(t);
    mortality_45_to_64(t)=mortality_45_to_64_table(life_expectancy(t)/one_year);
	mortality_65_plus(t)=mortality_65_plus_table(life_expectancy(t)/one_year);
	mortality_0_to_14(t)=mortality_0_to_14_table(life_expectancy(t)/one_year);
	mortality_15_to_44(t)=mortality_15_to_44_table(life_expectancy(t)/one_year);
    deaths_0_to_14(t)=Population_0_To_14(t)*mortality_0_to_14(t);
	deaths_15_to_44(t)=Population_15_To_44(t)*mortality_15_to_44(t);
	deaths_45_to_64(t)=Population_45_To_64(t)*mortality_45_to_64(t);
	deaths_65_plus(t)=Population_65_Plus(t)*mortality_65_plus(t);
    deaths(t)=deaths_0_to_14(t)+deaths_15_to_44(t)+deaths_45_to_64(t)+deaths_65_plus(t);
	maturation_14_to_15(t)=((Population_0_To_14(t)))*(1-mortality_0_to_14(t))/15;
	maturation_44_to_45(t)=((Population_15_To_44(t)))*(1-mortality_15_to_44(t))/30;
	maturation_64_to_65(t)=((Population_45_To_64(t)))*(1-mortality_45_to_64(t))/20;	
    completed_multiplier_from_perceived_lifetime(t)=completed_multiplier_from_perceived_lifetime_table(perceived_life_expectancy(t)/one_year);
	desired_completed_family_size(t)=2/(1+exp(-40*(t-shift_desired_completed_family_size)))-desired_completed_family_size_normal*family_response_to_social_norm(t)*social_family_size_normal(t)/(1+exp(-40*(t-shift_desired_completed_family_size)))+desired_completed_family_size_normal*family_response_to_social_norm(t)*social_family_size_normal(t);
	desired_total_fertility(t)=desired_completed_family_size(t)*completed_multiplier_from_perceived_lifetime(t);
	fecundity_multiplier(t)=fecundity_multiplier_table(life_expectancy(t)/one_year);
	maximum_total_fertility(t)=maximum_total_fertility_normal*fecundity_multiplier(t);
	need_for_fertility_control(t)=(maximum_total_fertility(t)/desired_total_fertility(t))-1;
    fertility_control_effectiveness(t)=1/(1+exp(-40*(t-shift_fertility_control_effectiveness)))-(fertility_control_effectiveness_table(fertility_control_facilities_per_capita(t)/GDP_pc_unit))/(1+exp(-40*(t-shift_fertility_control_effectiveness)))+(fertility_control_effectiveness_table(fertility_control_facilities_per_capita(t)/GDP_pc_unit));
	fraction_services_allocated_to_fertility_control(t)=fraction_services_allocated_to_fertility_control_table(need_for_fertility_control(t));
	fertility_control_allocation_per_capita(t)=fraction_services_allocated_to_fertility_control(t)*service_output_per_capita(t);
	total_fertility(t)=min(maximum_total_fertility(t),(maximum_total_fertility(t)*(1-fertility_control_effectiveness(t))+desired_total_fertility(t)*fertility_control_effectiveness(t)));
	health_services_per_capita(t)=health_services_per_capita_table(service_output_per_capita(t)/GDP_pc_unit*LIFE_TIME_MULTIPLIER_FROM_SERVICES);
    births(t)=deaths(t)/(1+exp(-40*(t-shift_births)))-(total_fertility(t)*Population_15_To_44(t)*0.5/reproductive_lifetime)/(1+exp(-40*(t-shift_births)))+(total_fertility(t)*Population_15_To_44(t)*0.5/reproductive_lifetime);
	

    % outputs
%     birth_rate(t)=THOUSAND*births(t)/population(t);
%     death_rate(t)=THOUSAND*deaths(t)/population(t);
% 	service_output_2005_value(t)=service_output(t)*w3_real_exhange_rate;
% 	Absorption_Land(t)=persistent_pollution_generation_rate(t)*ha_per_unit_of_pollution/ha_per_Gha;
%     Urban_Land(t)=Urban_and_Industrial_Land(t)/ha_per_Gha;
%     Human_Ecological_Footprint(t)=(Arable_Land_in_Gigahectares(t)+Urban_Land(t)+Absorption_Land(t))/Total_Land;
%     GDP_per_capita(t)=GDP_per_capita_LOOKUP(industrial_output_per_capita(t)/GDP_pc_unit);
% 	Education_Index(t)=Education_Index_LOOKUP(GDP_per_capita(t)/GDP_pc_unit);
% 	GDP_Index(t)=log(GDP_per_capita(t)/Ref_Lo_GDP)/log(Ref_Hi_GDP/Ref_Lo_GDP);
% 	Life_Expectancy_Index(t)=Life_Expectancy_Index_LOOKUP(life_expectancy(t)/one_year);
% 	Human_Welfare_Index(t)=(Life_Expectancy_Index(t)+Education_Index(t)+GDP_Index(t))/3;
%     resource_use_intensity(t)=resource_usage_rate(t)/industrial_output(t);
%     persistent_pollution_intensity_industry(t)=persistent_pollution_generation_industry(t)*persistent_pollution_generation_factor(t)/industrial_output(t);
%     consumed_industrial_output(t)=industrial_output(t)*fraction_of_industrial_output_allocated_to_consumption(t);
% 	consumed_industrial_output_per_capita(t)=consumed_industrial_output(t)/population(t);
% 	fraction_of_output_in_agriculture(t)=(PRICE_OF_FOOD*food(t))/(PRICE_OF_FOOD*food(t)+service_output(t)+industrial_output(t));
% 	fraction_of_output_in_industry(t)=industrial_output(t)/(PRICE_OF_FOOD*food(t)+service_output(t)+industrial_output(t));
% 	fraction_of_output_in_services(t)=service_output(t)/(PRICE_OF_FOOD*food(t)+service_output(t)+industrial_output(t));
 end 
disp('Done!')
%% create plots
labels = cell(5,1);
for label = 1:5
   labels{label} = string(T0 + (label-1)*T*dt/5);
end
grid on
figure(1)
hold on
tt=1:T;
plot(tt,full(evalf(population(tt)))/10^9,'r')
plot(tt,full(evalf(food_per_capita(tt)))/10^2,'g')
plot(tt,full(evalf(industrial_output_per_capita(tt)))/10^2,'y')
plot(tt,full(evalf(persistent_pollution_index(tt))),'m')
plot(tt,full(evalf(Nonrenewable_Resources(tt)))/10^11,'b')
legend('population','food per capita','industrial output per capita','Persistent Pollution Index','Nonrenewable Resources')
xticks(0:floor(T/5):T)
xticklabels(labels)

% figure(2)
% grid on
% hold on
% tt=1:T;
% plot(tt,full(evalf(fraction_of_industrial_output_allocated_to_agriculture(tt)))/10^-3,'m')
% plot(tt,full(evalf(agricultural_input_per_hectare(tt))),'r')
% plot(tt,full(evalf(total_agricultural_investment(tt)))/10^9,'g')
% plot(tt,full(evalf(industrial_output(tt)))/10^10,'y')
% plot(tt,full(evalf(fraction_of_industrial_capital_alloc_to_obtaining_res(tt)))/10^-3,'b')
% legend('fraction of industrial output allocated to agriculture','Agricultural Inputs per hectare','total agricultural investment','industrial output','fraction of industrial capital allocated to obtaining resources')
% xticks(0:100:T)
% xticklabels(labels)
% hold off
% hold off
% 
% figure(3)
% grid on
% hold on
% tt=1:T;
% plot(tt,full(evalf(lifetime_multiplier_from_food(tt)))/10^-1,'r')
% plot(tt,full(evalf(food_per_capita(tt)))/10^2,'g')
% plot(tt,full(evalf(land_yield(tt)))/10^2,'b')
% plot(tt,full(evalf(Arable_Land(tt)))/10^8,'y')
% plot(tt,full(evalf(population(tt)))/10^9,'m')
% legend('lifetime multiplier from food','food per capita','land yield','Arable Land','population')
% xticks(0:100:T)
% xticklabels(labels)
% hold off

grid on
figure(4)
hold on
tt=1:T;
plot(tt,full(evalf(persistent_pollution_generation_industry(tt)))/10^9,'r')
plot(tt,full(evalf(persistent_pollution_assimilation_rate(tt)))/10^9,'g')
plot(tt,full(evalf(persistent_pollution_generation_agriculture(tt)))/10^9,'y')
plot(tt,full(evalf(persistent_pollution_appearance_rate(tt)))/10^9,'m')
plot(tt,full(evalf(Persistent_Pollution(tt)))/10^9,'b')
legend('persistent pollution generation industry','persistent pollution assimilation rate','persistent pollution generation agriculture','persistent pollution appearance rate','Persistent Pollution')
xticks(0:floor(T/5):T)
xticklabels(labels)


%% Model validation
raw_data = readtable('Estimation/World3_data.csv');
% real_data = table2array(raw_data(1:2:end,10:end)); % start at column 10 since the first columns aren't real data. Skip by 2 since it is quarterly data
real_data = table2array(raw_data((T0-1900)*4+1:1/dt:end,10:end)); % start at column 10 since the first columns aren't real data. Skip by 2 since it is quarterly data
figure(1)
hold on
plot(1:size(real_data,1),real_data(:,1)/10^9,'*','MarkerFaceColor','r','MarkerEdgeColor','r');
plot(1:size(real_data,1),real_data(:,8)./(real_data(:,1)*10^2),'*','MarkerFaceColor','g','MarkerEdgeColor','g');
plot(1:size(real_data,1),real_data(:,9)./(real_data(:,1)*10^2),'*','MarkerFaceColor','y','MarkerEdgeColor','y');
plot(1:size(real_data,1),real_data(:,11)/persistent_pollution_in_1970,'*','MarkerFaceColor','m','MarkerEdgeColor','m')
plot(1:size(real_data,1),real_data(:,12)/10^11,'*','MarkerFaceColor','b','MarkerEdgeColor','b')
hold off
legend('population','food per capita','industrial output per capita','Persistent Pollution Index','Nonrenewable Resources')
