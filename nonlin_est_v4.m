function [est_params,traj,shock_vals,flag] = nonlin_est_v4(data,eqns,ineqns,obs_var_inds,shocks,params,param_init_guess,param_lb,param_ub,est_opts)
% Assumes that CasADi has already been added to the path since this code
% relies on casadi-cased functions and variables as input. If it is not on
% the path then add it and import it via the following two commands:
%     addpath(genpath('/home/mrra/CasADi_v3.5.5_linux'));

% same as version 2, but adjusted to the low var model version.
% this means that the obs_vars and state_vars are not represented as
% variables in the estimation process. Rather, they are the LHS of the
% equation x(t) = f(x(t-1)|p), where p are the parameters

problem_debug = 0;

    import casadi.*
    
    sim_opts = est_opts.sim_opts;

    non_nan_data = fill_nan_vals(data);
    normalization_factor = max(max(abs(non_nan_data)),0.0001);%non_nan_data(1,:);
%     normalization_factor = max(mean(abs(non_nan_data)),0.0001);
    
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
          
    T = size(data,1); % number of datapoints
    n_params = length(params);
    n_shocks = length(vertcat(shocks{:}));
    
    shock_init = cell(T,1);
    vec = [params];
    x0 = [param_init_guess];
%     init_traj = nan(length(eqns{1}),T);
    for t = 1:T
        
        if est_opts.use_shocks
            vec = [vec;shocks{t}];
%             vec_lb = [param_lb;-10^4*ones(n_shocks,1)];
%             vec_ub = [param_ub;10^4*ones(n_shocks,1)];
            vec_lb = [param_lb;-repmat(normalization_factor',T,1)]; % this assumes each shock corresponds with an obs var
            vec_ub = [param_ub;repmat(normalization_factor',T,1)]; % this assumes each shock corresponds with an obs var

            shock_init{t} = zeros(length(shocks{t}),1);
            if est_opts.try_fancy_shock_initialization 
                sim_traj{t} = nonlin_sim4b({eqns{t}},{[]},{vertcat(shocks{1:t})},{[vertcat(shock_init{1:t-1});shock_init{t}]},params,param_init_guess);
                sim_traj{t}(obs_var_inds(data2est)) = data(t,data2est)';
                sim_fun = Function('f',{shocks{t},vertcat(shocks{1:t-1}),params},{[sim_traj{t}(obs_var_inds)-eqns{t}(obs_var_inds)]});
                cas =   rootfinder('solver','nlpsol',sim_fun, sim_opts);
                shock_init{t} = cas(shock_init{t},vertcat(shock_init{1:t-1}),param_init_guess);
            end
            x0 = [x0;shock_init{t}]; 
            eqns_temp{t} = eqns{t};
        else
            vec_lb = [param_lb];
            vec_ub = [param_ub];
            eqn_fun_temp = Function('f',{params,vertcat(shocks{1:t})},{eqns{t}});
            eqns_temp{t} = eqn_fun_temp(params,vertcat(shock_init{1:t}));
        end
        obs_vars = eqns_temp{t}(obs_var_inds); % assumes equations are constructed in the form: x(t) = f(x(t-1)|p), where p are the parameters 
        data2est = find(~isnan(data(t,:)));% only fit to existing data. Don't care about states at unobserved timesteps
        obj = obj + sum(((obs_vars(data2est)-data(t,data2est)')./normalization_factor(data2est)').^2);
        
%         init_traj(:,t) = nonlin_sim4b({eqns{t}},{[]},{vertcat(shocks{1:t})},{vertcat(shock_init{1:t})},params,param_init_guess);
    end
    % plot the initial guess trajectory
%     hold on
%     plot(1:T,full(init_traj(obs_var_inds,:)));
%     plot(1:T,data','*')
%     hold off
    
    
%     traj_fun = Function('f',{vec},{[vertcat(eqns{:});vertcat(ineqns{:})]});

    cons_fun = Function('f',{vec},{vertcat(ineqns{:})});
    obj_fun = Function('f',{vec},{obj});
    
%     nEQ = size(vertcat(eqns{:}));
    nINEQ = size(vertcat(ineqns{:}));
    
        %% check that initial trajectory is feasible (if not then the solver may fail to converge)
%     eqn_viols = traj_fun(x0,sigmoid_factor);
%     if ~isempty(find(full(abs(eqn_viols(1:nEQ)))>=0.0001))
%        warning('Infeasible initial guess provided. Solver may fail to converge') 
%     end
%     if ~isempty(find(full(eqn_viols(1+nEQ:nEQ+nINEQ))>=0.0001))
%        warning('Infeasible initial guess provided. Solver may fail to converge') 
%     end

    %% check edge cases
    if problem_debug
        n_vec = length(vec);
        jac_fun=Function('f',{vec},{jacobian(cons_fun(vec),vec)});
        problematic_inds = find(isnan(full(evalf(jac_fun(x0)))));
        if ~isempty(problematic_inds)
           warning('problem detected in Jacobian for x0 at equations:')
           for i = 1:length(problematic_inds)
               warning(['Jacobian of constraint ' num2str(mod((problematic_inds(i)-1),nINEQ(1)/T)+1) ' at x0 wrt variable ' num2str(ceil((problematic_inds(i))/nINEQ(1))) ' is NaN'])
           end
        end
        
        problematic_inds2 = find(isnan(full(evalf(jac_fun(vec_lb)))));
        if ~isempty(problematic_inds2)
           warning('problem detected in Jacobian for lb at equations:')
           for i = 1:length(problematic_inds2)
               warning(['Jacobian of constraint ' num2str(mod((problematic_inds2(i)-1),nINEQ(1)/T)+1) ' at lb wrt variable ' num2str(ceil((problematic_inds2(i))/nINEQ(1))) ' is NaN'])
           end
        end
        problematic_inds3 = find(isnan(full(evalf(jac_fun(vec_ub)))));
        if ~isempty(problematic_inds3)
           warning('problem detected in Jacobian for ub at equations:')
           for i = 1:length(problematic_inds3)
               warning(['Jacobian of constraint ' num2str(mod((problematic_inds3(i)-1),nINEQ(1)/T)+1) ' at ub wrt variable ' num2str(ceil((problematic_inds3(i))/nINEQ(1))) ' is NaN'])
           end
        end
    end

    %% start estimation
    opts = est_opts.est_opts;
    
    tic
    if isempty(ineqns)
        if est_opts.use_shocks
            nlp =   struct('x',vec,'f',obj_fun(vec));
            cas =   nlpsol('solver',est_opts.solver,nlp,opts);
            sol =   cas('x0', x0,...
                    'lbx', vec_lb,...
                    'ubx', vec_ub);

        else
            nlp =   struct('x',vec,'f',obj_fun(vec));%,'g',traj_fun(vec,sigmoid_factor));
            cas =   nlpsol('solver',est_opts.solver,nlp,opts);
            sol =   cas('x0', x0,...
                    'lbx', vec_lb,...
                    'ubx', vec_ub);
        end
    else
        if est_opts.use_shocks
            ineq_lb = -10*min(abs(obj_fun(x0)))*ones(nINEQ);
            nlp =   struct('x',vec,'f',obj_fun(vec),'g',cons_fun(vec));
            cas =   nlpsol('solver',est_opts.solver,nlp,opts);
            sol =   cas('x0', x0,...
                    'lbx', vec_lb,...
                    'ubx', vec_ub,...
                    'lbg', [ineq_lb],... % was -inf(nINEQ) but that lead to problems with dual infeasibility
                    'ubg', [zeros(nINEQ)]);

        else
            nlp =   struct('x',vec,'f',obj_fun(vec),'g',cons_fun(vec));
            cas =   nlpsol('solver',est_opts.solver,nlp,opts);
            sol =   cas('x0', x0,...
                    'lbx', vec_lb,...
                    'ubx', vec_ub,...
                    'lbg', [-inf(nINEQ)],...
                    'ubg', [zeros(nINEQ)]);
        end
    end

%     nlp =   struct('x',vec,'f',obj_fun(vec),'g',traj_fun(vec,sigmoid_factor));
%     cas =   nlpsol('solver',solver,nlp,opts);
%     sol =   cas('x0', x0,...
%             'lbx', [param_lb;-10^4*ones(n_shocks,1)],...
%             'ubx', [param_ub;10^4*ones(n_shocks,1)],...
%             'lbg', [zeros(nEQ);-inf(nINEQ)],...
%             'ubg', [inf(nEQ);zeros(nINEQ)]);%,...
% %             'lbg', [zeros(nEQ);-inf(nINEQ)],...
% %             'ubg', [zeros(nEQ);zeros(nINEQ)]);
%                 
            
    %% output results
    est_params = full(sol.x(1:n_params));
    if est_opts.use_shocks
        shock_vals = reshape(full(sol.x(1+n_params:end)),length(shocks{1}),T);
    else
        shock_vals = zeros(length(shocks{1}),T);
    end
    
    [traj] = full(nonlin_sim4b(eqns,ineqns,shocks,num2cell(shock_vals,1),params,est_params));
    
    disp("runtime: "+num2str(toc))

    flag = cas.stats.return_status;
    
end