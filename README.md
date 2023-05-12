# World3

World3e: A simulation using the parameters calibrated to what they were in the original paper.

World3_init: initial state values when starting at 1900 (generating using World3e)

World3_init2: initial state values when starting at 1950 (generating using World3e)

World3_init2b: initial state values when starting at 1950 (generating using World3e and World3_data.csv)

World3_data.csv: data for estimating the model in est_World3_low_var_version4

my_world3_data.csv: data for estimating the model in my_World3_low_var_version

fill_nan_vals: a very basic imputation script. If a nan value is encountered, the last non-nan value is used instead

get_fit: tries fitting a linear, quadratic, cubic, exponential, negative exponential, and logistic function to the input data. Selects the one that has the best AIC and BIC

interp_f: creates a linear interpolation between the input points

est_World3_low_var_version4: the script for setting up parameter estimation for the World3 model. Includes both a centralized and distributed approach (distributed code can be found here: https://github.com/Alexander-Murray/Mixed-Integer-ALADIN)

my_World3_low_var_version: same as est_World3_low_var_version4 but with some tweaks to the World3 model (ie. inflation and GDP per capita added)

nonlin_est_v4: script for estimating the provided model (requires: https://web.casadi.org/)

nonlin_sim4: script for simulating the provided model (requires: https://web.casadi.org/)

nonlin_sim4b: script for simulating the provided model assuming it has the form x(t) = f(x(t-1)|p) where f represents the model dynamics, x are the variables, and p are the parameters (requires: https://web.casadi.org/)

partition_problem: parititions the problem for input into a distributed optimization algorithm
