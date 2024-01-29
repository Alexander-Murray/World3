% target is what is being modelled. Assumed to be a unviariate series.
% model = a_1*target(t-1) + ... +a_lags*target(t-lags) + a_lags+1*input_series_1 + ... + a_{lags+n}*input_series_n
function est_params = AR_est_world3(target,input_series,lags)
    import casadi.*
    
    input_series = lin_interp(input_series);
    
    % TO DO: check if the input series need to be normalized. Currently assumes that they are already normalized
    
    n_input_series = size(input_series,2);
    T = size(target,1);
    
    if size(input_series,1)~=T
       error('Mismatch between sizes of target and input_series.') 
    end
    
    n_params = lags+n_input_series;
    params=SX.sym('p',[n_params,1]);
    lbx=-2*ones(n_params,1);
    ubx=2*ones(n_params,1);
    
    model = 0;
    for i = 1:lags
       model = model + params(i)*target(lags-i+1:T-i);
    end
    for i = lags+1:lags+n_input_series
       model = model + params(i)*input_series(lags+1:T,i-lags);
    end
    obj = sum((target(lags+1:T) - model).^2);
    obj_fun = Function('f',{params},{obj});
    
    x0 = zeros(n_params,1);
    
    opts.ipopt.max_iter = 30000; % default is 3000
    opts.ipopt.hessian_approximation='limited-memory';
    nlp =   struct('x',params,'f',obj_fun(params));
    cas =   nlpsol('solver','ipopt',nlp,opts);
    sol =   cas('x0', x0,...
        'lbx', lbx,...
        'ubx', ubx);
    
    est_params = full(evalf(sol.x));
end