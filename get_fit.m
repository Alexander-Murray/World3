% author: Alexander Murray, Jan, 2021
% input: data vectors x and y, booleans display_fun and plot_fun, and cell
% array names where names{1}=sector, names{2}=x values name, names{3} = y values name
% output: coefficients of fitted function, type of fitted function, the
% fitted function as a string, the fitted function as a callable MATLAB math function

% TO DO: reindex variables

function [coeffs_winner,fit,fun_text,modelFun_winner] = get_fit(x,y,display_fun,plot_fun,names)
    LL = NaN(6,1); % Log-Likelihood
    numParam = [2;3;4;3;3;4]; % number of params estimated in each model;
    
    weights = ones(1,length(x));
    weights(find(y==min(y)))=5;
    weights(find(y==max(y)))=2;
    
    x_norm = max(abs(x));
    y_norm = max(abs(y));
    if y_norm == 0
        y_norm = 1;
    end
    
    x_new = x/x_norm;
    y_new = y/y_norm;
    
    %% linear
    start = [(y_new(end)-y_new(1))/(x_new(end)-x_new(1));y_new(1)]; % initial guesses for model params
    modelFun{1} = @(b,x) b(1).*x + b(2); %decaying growth/decay
    try
       coeffs{1} = fitnlm(x_new,y_new,modelFun{1},start,'Weights',weights);
    catch
        try 
            start = zeros(2,1); % initial guesses for model params
            coeffs{1} = fitnlm(x_new,y_new,modelFun{1},start,'Weights',weights);
        catch
            keyboard 
        end
    end
    f{1} = predict(coeffs{1},x_new);
    LL(1) = coeffs{1}.LogLikelihood;
    
    %% quadratic
    start = [-(y_new(end)-y_new(1))/(4*x_new(end)^2);(y_new(end)-y_new(1))/(2*x_new(end));y_new(1)]; % initial guesses for model params
    modelFun{2} = @(b,x) b(1).*x.^2 + b(2).*x + b(3); %decaying growth/decay
    try
       coeffs{2} = fitnlm(x_new,y_new,modelFun{2},start,'Weights',weights);
    catch
        try 
            start = zeros(3,1); % initial guesses for model params
            coeffs{2} = fitnlm(x_new,y_new,modelFun{2},start,'Weights',weights);
        catch
            keyboard 
        end
    end
    f{2} = predict(coeffs{2},x_new);
    LL(2) = coeffs{2}.LogLikelihood;
    
    %% cubic
    start = [0;-(y_new(end)-y_new(1))/(4*x_new(end)^2);(y_new(end)-y_new(1))/(2*x_new(end));y_new(1)]; % initial guesses for model params
    modelFun{3} = @(b,x) b(1).*x.^3 + b(2).*x.^2 + b(3).*x + b(4); %decaying growth/decay
    try
       coeffs{3} = fitnlm(x_new,y_new,modelFun{3},start,'Weights',weights);
    catch
        try 
            start = zeros(4,1); % initial guesses for model params
            coeffs{3} = fitnlm(x_new,y_new,modelFun{3},start,'Weights',weights);
        catch
            keyboard 
        end
    end
    f{3} = predict(coeffs{3},x_new);
    LL(3) = coeffs{3}.LogLikelihood;
    
    %% negative exponential
    start = [max(y_new); .0005; 0]; % initial guesses for model params
    modelFun{4} = @(b,x) b(1).*(1-exp(-b(2).*x)) + b(3); %decaying growth/decay
    try
       coeffs{4} = fitnlm(x_new,y_new,modelFun{4},start,'Weights',weights);
    catch
        try 
            start = [max(y_new); -0.0005; 0]; % initial guesses for model params
            coeffs{4} = fitnlm(x_new,y_new,modelFun{4},start,'Weights',weights);
        catch
            keyboard 
        end
    end
    f{4} = predict(coeffs{4},x_new);
    LL(4) = coeffs{4}.LogLikelihood;
    
    %% exponential
    start = [1; .0005; min(y_new)]; % initial guesses for model params
    modelFun{5} = @(b,x) b(1).*(exp(-b(2).*x)) + b(3); %exponential growth/decay
    try
       coeffs{5} = fitnlm(x_new,y_new,modelFun{5},start,'Weights',weights);
    catch
        try
            start = [1; -0.0005; min(y_new)]; % initial guesses for model params
            coeffs{5} = fitnlm(x_new,y_new,modelFun{5},start,'Weights',weights);
        catch
            keyboard 
        end
    end
    f{5} = predict(coeffs{5},x_new);
    LL(5) = coeffs{5}.LogLikelihood;

    
    %% logistic
%     start = [0;(y_new(ceil(length(y_new)/2))-y_new(1))/(x_new(ceil(length(x_new)/2))-x_new(1)); 20; y_new(1)]; % initial guesses for model params
%     modelFun{6} = @(b,x) b(1).*(x) + b(2).*tanh(x-b(3)) + b(4); % better to use max(y)/(1+exp(-2*k*(x-shift))) instead of tanh(k*(x-shift))?

    start = [max(y_new);20; 0; -min(y_new)]; % initial guesses for model params
    modelFun{6} = @(b,x) b(1)./(1+exp(-b(2)*(x-b(3)))) + b(4); % better to use max(y)/(1+exp(-2*k*(x-shift))) instead of tanh(k*(x-shift))!
    try
       coeffs{6} = fitnlm(x_new,y_new,modelFun{6},start,'Weights',weights);
    catch
        try
            start = [0; 1; 20; 0]; % initial guesses for model params
            coeffs{6} = fitnlm(x_new,y_new,modelFun{6},start,'Weights',weights);
        catch
            keyboard 
        end
    end
    f{6} = predict(coeffs{6},x_new);
    LL(6) = coeffs{6}.LogLikelihood;
    
    %% Information criteria for model selection
    [aic,bic] = aicbic(LL,numParam,length(x)); % Akaike information criteria and Bayesian information criteria
%     winner = find(RMSE==min(RMSE));
    winner1 = find(aic==min(aic)); 
    winner2 = find(bic==min(bic));
    if winner1~=winner2 % break ties
       aic2=sort(aic);
       place1 = find(aic2==aic(winner2));
       bic2=sort(bic);
       place2 = find(bic2==bic(winner1));
       if place1==place2 % break ties... again
          if (aic(winner2)-aic(winner1))/aic(winner2) < (bic(winner1)-bic(winner2))/bic(winner1)
             winner = winner2; 
          else
              winner = winner1;
          end
       elseif place1<place2
           winner = winner1;
       else
           winner = winner2;
       end
    else
        winner = winner1;
    end
    if length(winner)>1
       disp('More than one winner. Selecting simpler model...') 
       winner = winner(1);
    end
    coeffs_winner = table2array(coeffs{winner}.Coefficients(:,1));
    
    
    %% display winning model
    if winner == 1
        fit = 'linear';
        fun_text=[names{3} ' = ' num2str(y_norm) '*(' num2str(coeffs_winner(2)) ' + ' num2str(coeffs_winner(1)) '*' names{2} '/' num2str(x_norm) ')'];
        coeffs_winner(1)=coeffs_winner(1)/x_norm;
        coeffs_winner = coeffs_winner*y_norm; % add the normalization factor back in
    elseif winner == 2
        fit = 'quadratic';
        fun_text=[names{3} ' = ' num2str(y_norm) '*(' num2str(coeffs_winner(3)) ' + ' num2str(coeffs_winner(2)) '*(' names{2} '/' num2str(x_norm) ') + ' num2str(coeffs_winner(1)) '*(' names{2} '/' num2str(x_norm) ')^2 )'];
        coeffs_winner(2)=coeffs_winner(2)/x_norm;
        coeffs_winner(1)=coeffs_winner(1)/x_norm^2;
        coeffs_winner = coeffs_winner*y_norm; % add the normalization factor back in
    elseif winner == 3
        fit = 'cubic';
        fun_text=[names{3} ' = ' num2str(y_norm) '*(' num2str(coeffs_winner(4)) ' + ' num2str(coeffs_winner(3)) '*(' names{2} '/' num2str(x_norm) ') + ' num2str(coeffs_winner(2)) '*(' names{2} '/' num2str(x_norm) ')^2 + ' num2str(coeffs_winner(1)) '*(' names{2} '/' num2str(x_norm) ')^3 )'];
        coeffs_winner(3)=coeffs_winner(3)/x_norm;
        coeffs_winner(2)=coeffs_winner(2)/x_norm^2;
        coeffs_winner(1)=coeffs_winner(1)/x_norm^3;
        coeffs_winner = coeffs_winner*y_norm; % add the normalization factor back in
    elseif winner == 4
        fit = 'negative exponential';
        fun_text=[names{3} ' = ' num2str(y_norm) '*(' num2str(coeffs_winner(1)) '*(1-exp(' num2str(-coeffs_winner(2)) '*' names{2} '/' num2str(x_norm) ')) + ' num2str(coeffs_winner(3)) ')'];
        coeffs_winner(2) = coeffs_winner(2)/x_norm;
        coeffs_winner(1) = coeffs_winner(1)*y_norm; % add the normalization factor back in
        coeffs_winner(3) = coeffs_winner(3)*y_norm; % add the normalization factor back in
    elseif winner == 5
        fit = 'exponential';
        fun_text=[names{3} ' = ' num2str(y_norm) '*(' num2str(coeffs_winner(1)) '*(exp(' num2str(-coeffs_winner(2)) '*' names{2} '/' num2str(x_norm) ')) + '  num2str(coeffs_winner(3)) ')'];
        coeffs_winner(2) = coeffs_winner(2)/x_norm;
        coeffs_winner(1) = coeffs_winner(1)*y_norm; % add the normalization factor back in
        coeffs_winner(3) = coeffs_winner(3)*y_norm; % add the normalization factor back in
    elseif winner == 6
        fit = 'logistic';
%         fun_text=[names{3} ' = ' num2str(y_norm) '*(' num2str(coeffs_winner(1)) '*' num2str(names{2}) ' + ' num2str(coeffs_winner(2)) '*tanh('   names{2} '/' num2str(x_norm) ' - ' num2str(coeffs_winner(3))   ') + ' num2str(coeffs_winner(4)) ')'];
%         coeffs_winner(2) = coeffs_winner(2)*y_norm; % add the normalization factor back in
%         coeffs_winner(1) = coeffs_winner(1)*y_norm/x_norm; % add the normalization factor back in
%         coeffs_winner(4) = coeffs_winner(4)*y_norm; % add the normalization factor back in
% %         coeffs_winner(3) = coeffs_winner(3)/x_norm;
        fun_text=[names{3} ' = ' num2str(y_norm) '*(' num2str(coeffs_winner(1)) '/( 1 + exp(-' num2str(coeffs_winner(2)) '*('   names{2} '/' num2str(x_norm) ' - ' num2str(coeffs_winner(3))   '))) + ' num2str(coeffs_winner(4)) ')'];
        coeffs_winner(1) = coeffs_winner(1)*y_norm; % add the normalization factor back in
%         coeffs_winner(2) = coeffs_winner(2)/x_norm; % add the normalization factor back in
        coeffs_winner(3) = coeffs_winner(3)/x_norm; % add the normalization factor back in
        coeffs_winner(4) = coeffs_winner(4)*y_norm; % add the normalization factor back in
        
    else
        keyboard % this shouldn't happen...
    end
    if display_fun
        disp(fun_text)
    end
    modelFun_winner = modelFun{winner};
    
    
    %% plot winning model
    xx = min(x):(max(x)-min(x))/100:max(x);
    if plot_fun
        try
            figure(get(gcf,'Number')+1)
        catch
            figure(1);
        end
        disp(['plot#: ' num2str(get(gcf,'Number'))])
        hold on
        plot(x,y,'*')
        plot(xx,y_norm*predict(coeffs{winner},xx'/x_norm))
        xlabel(names{2});
        ylabel(names{3});
        hold off
    end
%     disp(['RMSE = ' num2str(sqrt(mean((f{winner}-y_new).^2)))])

% test function
%     if sum(y<0)==0
%         if sum(modelFun_winner(coeffs_winner,xx')<-10^-6)>0
%             keyboard % non-zero output data (y) should yield a function with non-zero values for the range of input data (x)
%         end
%     end
end