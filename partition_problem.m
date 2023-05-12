function [obj_funs,cons_funs,x0,lb,ub,A_mats,b,lam0,discrete] = partition_problem(partitions,data,obs_var_inds,init_vars,init_traj,eqns,ineqns,params,param_init_guess,param_lb,param_ub,shocks,est_opts)
% takes in timeseries data and creates a paritioned regression problem
% suitable for distributed optimization. The partition is made time-wise
% N: number of partitions

%%% TO DO: partition problem with shocks
N = length(partitions);
if N==1
    error("N must be greater than 1")
end

import casadi.*

non_nan_data = fill_nan_vals(data);
normalization_factor = max(max(abs(non_nan_data)),0.0001);%non_nan_data(1,:);

T = size(data,1); % number of datapoints


% initialize problem info
cons_funs = cell(1,N);
obj_funs = cell(1,N);
x0 = cell(1,N);
lb = cell(1,N);
ub = cell(1,N);
A_mats = cell(1,N);
discrete = cell(1,N);

n_params = length(params);
n_vars = length(init_vars);
n_opt_vars = n_params+n_vars;
NC = (N-1)*n_params; % number of coupling constraints (here, there is one between each partition)

t = 1;
for i = 1:N
    %% set up lasso/ridge regression
    if ~est_opts.use_shocks
        est_opts.lambda2 = 0;
    end
    if strcmp(est_opts.regression_type,'ridge')
        obj = est_opts.lambda1*sum(params.^2) + est_opts.lambda2*sum(vertcat(shocks{:}).^2); % add ridge regression term
    elseif strcmp(est_opts.regression_type,'lasso')
        obj = est_opts.lambda1*sum(abs(params)) + est_opts.lambda2*sum(abs(vertcat(shocks{:}))); % add lasso term
    elseif strcmp(est_opts.regression_type,'OLS')
        obj = 0;
    else
        error('invalid regression type provided. options are: ridge, lasso, OLS');
    end
    
    % set up initial guess for optimizer
    if i==1
        x0{i} = [param_init_guess;init_traj(:,1)];
    else
        x0{i} = [param_init_guess;init_traj(:,partitions(i-1))];
    end
    % set up list of optimzation variables
    vec = [params;init_vars];
    % set up constraints for local subproblems
    if isempty(ineqns)
        cons = [params-param_ub; -params+param_lb]; % empty constraints can cause problems
    else
        cons = [];
    end 
    
    % set up objective and constraints functions of local subproblems
    while t < partitions(i)
        shock_init{t} = zeros(length(shocks{t}),1);
        eqns_temp{t} = eqns{t}(params,vertcat(shock_init{1:t}),init_vars);
        obs_vars = eqns_temp{t}(obs_var_inds); % assumes equations are constructed in the form: x(t) = f(x(t-1)|p), where p are the parameters
        data2est = find(~isnan(data(t,:)));% only fit to existing data. Don't care about states at unobserved timesteps
        obj = obj + sum(((obs_vars(data2est)-data(t,data2est)')./normalization_factor(data2est)').^2);
        %             x0{i} = [x0{i};zeros(length(shocks{t}),1)];
        %             vec = [vec;shocks{t}];
        cons = [cons;ineqns{t}(params,vertcat(shock_init{1:t}),init_vars)];
        t = t+1;
    end
    
    obj_funs{i} = Function('f',{vec},{obj});
    cons_funs{i} = Function('f',{vec},{cons});
    
    % consensus constraint matrices
    % all params must be in consensus. init conds can be different though
    if i == 1
        A_mats{i} = [eye(n_params,n_opt_vars);zeros((N-2)*n_params,n_opt_vars)];
    elseif i == N
        A_mats{i} = [zeros((N-2)*n_params,n_opt_vars);-eye(n_params,n_opt_vars)];
    else
        A_mats{i} = [zeros((i-2)*n_params,n_opt_vars);-eye(n_params,n_opt_vars);eye(n_params,n_opt_vars);zeros((N-1-i)*n_params,n_opt_vars)];
    end
    
    % box constraints
    lb{i} = [param_lb;zeros(n_vars,1)];
    ub{i} = [param_ub;inf(n_vars,1)];
    
    % vector denoting which variables are integer valued
    discrete{i}=[zeros(1,n_opt_vars)];
end
b = zeros(NC,1); % RHS of consensus constraints
lam0 = zeros(NC,1); % initial guess of Lagrange multiplier of consensus constraints
end