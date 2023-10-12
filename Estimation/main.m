diary results.log;

close all
clear
clc
delete *.asv
path('Mfiles',path);
path('Optimization Routines',path);
path('LRE',path);
path('toolbox_ss',path);
warning('off','all');

%=========================================================================
%                            Load data
%=========================================================================
data = load('usdata_1960Q11979Q2.txt');
%data = load('usdata_1985Q12007Q4.txt');
%data = load('usdata_1960Q12007Q4.txt');
%data = load('usdata_1988Q12007Q4.txt');




%=========================================================================
%                     Specify parameters of prior
%=========================================================================
prio= load('prior_dsge.txt');

pshape   = prio(:,1);
pmean    = prio(:,2);
pstdd    = prio(:,3);
pmask    = prio(:,4);
pfix     = prio(:,5);
pmaskinv = 1- pmask;
pshape   = pshape.*pmaskinv;

bounds   = load('bound_dsge.txt');

%=========================================================================
%                       Set Parameters of Algorithm
%=========================================================================

% General
tune.npara = size(prio,1);       % # of parameters
tune.nphi  = 100;                 % # of stages
tune.npart = 5000;              % # of particles
tune.lam   = 2;                  % # bending coeff, lam = 1 means linear cooling schedule

hpdpercent = 0.90;   % pecentage WITHIN bands

% Tuning for MH algorithms
%tune.nblock = 1;                   % Number of random blocks
tune.c      = 0.25;                 % initial scale cov
tune.acpt   = 0.25;                 % initial acpt rate
tune.trgt   = 0.25;                 % target acpt rate
tune.alp    = 0.9;                  % Mixture weight for mixture proposal

% Create the tempering schedule
tune.phi = (1:1:tune.nphi)';
tune.phi = ((tune.phi-1)/(tune.nphi-1)).^tune.lam;

% Define a function handle for Posterior evaluation
f = @(x1,x2) objfcn_dsge(x1,x2,prio,bounds,data);
 
% Matrices for storing
parasim = zeros(tune.nphi, tune.npart, tune.npara); % parameter draws
wtsim   = zeros(tune.npart, tune.nphi);        % weights
zhat    = zeros(tune.nphi,1);                  % normalization constant
nresamp = 0; % record # of iteration resampled

csim    = zeros(tune.nphi,1); % scale parameter
ESSsim  = zeros(tune.nphi,1); % ESS
acptsim = zeros(tune.nphi,1); % average acceptance rate
rsmpsim = zeros(tune.nphi,1); % 1 if re-sampled

%=========================================================================
%             Initialize Algorithm: Draws from prior
%=========================================================================

disp('                                                                  ');
disp('          SMC starts....         ');
disp('                                                                  ');

priorsim       = priodraws(prio, bounds, tune.npart);
parasim(1,:,:) = priorsim;        % from prior
wtsim(:, 1)    = 1/tune.npart;    % initial weight is equal weights
zhat(1)        = sum(wtsim(:,1));

% Posterior values at prior draws
loglh   = zeros(tune.npart,1); %log-likelihood
logpost = zeros(tune.npart,1); %log-posterior

for i=1:1:tune.npart
    p0                     = priorsim(i,:)';
    [logpost(i), loglh(i), lnprior(i)] = f(p0,tune.phi(1)); % likelihood
end

% ------------------------------------------------------------------------
% Recursion: For n=2,...,N_{\phi}
% ------------------------------------------------------------------------
smctime   = tic;
totaltime = 0;
disp('SMC recursion starts ... ');

for i=2:1:tune.nphi
    %-----------------------------------
    % (a) Correction
    %-----------------------------------
    % incremental weights - HS denote this \tilde{w}_{n}^{i}
    incwt = exp((tune.phi(i)-tune.phi(i-1))*loglh); % eq. 5.4 in HS
    undefined = sum(incwt==0);
    % update weights
    unwtsim(:, i) = wtsim(:, i-1).*incwt; % numerator of normalization
    zhat(i)     = sum(unwtsim(:, i)); % denominator of normalization
    %zhat(i) % display normalizing factor
    % finally normalize the weights
    wtsim(:, i) = unwtsim(:, i)/zhat(i); % eq. 5.5 in HS
    
    %-----------------------------------
    % (b) Selection
    %-----------------------------------
    ESS = 1/sum(wtsim(:, i).^2); % Effective sample size 
    if (ESS < tune.npart/2) 
        %[id, m] = systematic_resampling(wtsim(:,i)'); %systematic resampling
        [id, m] = multinomial_resampling(wtsim(:,i)');
        parasim(i-1, :, :) = squeeze(parasim(i-1, id, :));
        loglh              = loglh(id);
        logpost            = logpost(id);
        wtsim(:, i)        = 1/tune.npart; % resampled weights are equal weights
        nresamp            = nresamp + 1;
        rsmpsim(i)         = 1;
    end
    
    %--------------------------------------------------------
    % (c) Mutuation
    %--------------------------------------------------------
    % Adapting the transition kernel
    tune.c = tune.c*(0.95 + 0.10*exp(16*(tune.acpt-tune.trgt))/(1 + exp(16*(tune.acpt-tune.trgt))));
    % Calculate estimates of mean and variance
    para      = squeeze(parasim(i-1, :, :));
    wght      = repmat(wtsim(:, i), 1, tune.npara);
    tune.mu      = sum(para.*wght); % mean
    z            = (para - repmat(tune.mu, tune.npart, 1));
    %tune.R       = (z.*wght)'*z;
    tune.R       = nearestSPD((z.*wght)'*z);
    tune.Rdiag   = diag(diag(tune.R)); % covariance with diag elements
    tune.Rchol   = chol(tune.R, 'lower');
    tune.Rchol2  = sqrt(tune.Rdiag);
 
    % Particle mutation (RWMH 2)
    temp_acpt = zeros(tune.npart,1); %initialize accpetance indicator
    parfor j = 1:tune.npart %iteration over particles
    [ind_para, ind_loglh, ind_post, ind_acpt] = mutation_RWMH(para(j,:)', loglh(j), logpost(j), tune, i, f); 
         parasim(i,j,:) = ind_para;
         loglh(j)       = ind_loglh;
         logpost(j)     = ind_post;
         temp_acpt(j,1) = ind_acpt;
    end
    
    tune.acpt = mean(temp_acpt); % update average acceptance rate
    % store
    csim(i,:)    = tune.c; % scale parameter
    ESSsim(i,:)  = ESS; % ESS
    acptsim(i,:) = tune.acpt; % average acceptance rate
    
    % print some information
    if mod(i, 1) == 0
        para = squeeze(parasim(i, :, :));
        wght = repmat(wtsim(:, i), 1, size(prio,1));
        mu  = sum(para.*wght);
        sig = sum((para - repmat(mu, tune.npart, 1)).^2 .*wght);
        sig = (sqrt(sig));
        
        % Draws for histogram and HPD interval
        %[id, m] = systematic_resampling(wtsim(:,i)'); % systematic resampling
        [id, m] = multinomial_resampling(wtsim(:,i)'); %multinomial resampling
        parapost = squeeze(parasim(i, id, :));  % posterior draws after resampling
        paraint = hpdint(parapost,hpdpercent,1);  % posterior probability intervals

        % time calculation
        totaltime = totaltime + toc(smctime);
        avgtime   = totaltime/i;
        remtime   = avgtime*(tune.nphi-i);
         % print
        fprintf('-----------------------------------------------\n')
        fprintf(' Iteration = %10.0f / %10.0f \n', i, tune.nphi);
        fprintf('-----------------------------------------------\n')
        fprintf(' phi  = %5.4f    \n', tune.phi(i));
        fprintf('-----------------------------------------------\n')
        fprintf('  c    = %5.4f\n', tune.c);
        fprintf('  acpt = %5.4f\n', tune.acpt);
        fprintf('  ESS  = %5.1f  (%d total resamples.)\n', ESS, nresamp);
        fprintf('-----------------------------------------------\n')
        fprintf('  time elapsed   = %5.2f\n', totaltime);
        fprintf('  time average   = %5.2f\n', avgtime);
        fprintf('  time remained  = %5.2f\n', remtime);
        fprintf('-----------------------------------------------\n')
        fprintf('para      mean    std     90int\n')
        fprintf('------    ----    ----    ---------\n')
        fprintf('h      %4.3f   %4.3f   %4.3f   %4.3f\n', mu(1), sig(1), paraint(1,1), paraint(2,1))
        fprintf('xip    %4.3f   %4.3f   %4.3f   %4.3f\n', mu(2), sig(2), paraint(1,2), paraint(2,2))
        fprintf('psipi  %4.3f   %4.3f   %4.3f   %4.3f\n', mu(3), sig(3), paraint(1,3), paraint(2,3))
        fprintf('phiy   %4.3f   %4.3f   %4.3f   %4.3f\n', mu(4), sig(4), paraint(1,4), paraint(2,4))
        fprintf('psidy  %4.3f   %4.3f   %4.3f   %4.3f\n', mu(5), sig(5), paraint(1,5), paraint(2,5))
        fprintf('psir_1 %4.3f   %4.3f   %4.3f   %4.3f\n', mu(6), sig(6), paraint(1,6), paraint(2,6))
        fprintf('psir_2 %4.3f   %4.3f   %4.3f   %4.3f\n', mu(7), sig(7), paraint(1,7), paraint(2,7))
        fprintf('abar   %4.3f   %4.3f   %4.3f   %4.3f\n', mu(8), sig(8), paraint(1,8), paraint(2,8))
        fprintf('pibar  %4.3f   %4.3f   %4.3f   %4.3f\n', mu(9), sig(9), paraint(1,9), paraint(2,9))
        fprintf('rbar   %4.3f   %4.3f   %4.3f   %4.3f\n', mu(10), sig(10), paraint(1,10), paraint(2,10))
        fprintf('rhob   %4.3f   %4.3f   %4.3f   %4.3f\n', mu(11), sig(11), paraint(1,11), paraint(2,11))
        fprintf('rhoz   %4.3f    %4.3f   %4.3f  %4.3f\n', mu(12), sig(12), paraint(1,12), paraint(2,12))
        fprintf('rhor   %4.3f   %4.3f   %4.3f   %4.3f\n', mu(13), sig(13), paraint(1,13), paraint(2,13))
        fprintf('sigmab %4.3f   %4.3f   %4.3f   %4.3f\n', mu(14), sig(14), paraint(1,14), paraint(2,14))
        fprintf('sigmaz %4.3f   %4.3f   %4.3f   %4.3f\n', mu(15), sig(15), paraint(1,15), paraint(2,15))
        fprintf('sigmai %4.3f   %4.3f   %4.3f   %4.3f\n', mu(16), sig(16), paraint(1,16), paraint(2,16))
        fprintf('sigmas %4.3f  %4.3f   %4.3f   %4.3f\n', mu(17), sig(17), paraint(1,17), paraint(2,17))
        fprintf('alphaBN %4.3f    %4.3f   %4.3f   %4.3f\n', mu(18), sig(18), paraint(1,18), paraint(2,18))
        fprintf('rho_bs    %4.3f    %4.3f   %4.3f   %4.3f\n', mu(19), sig(19), paraint(1,19), paraint(2,19))
        fprintf('rho_zs    %4.3f    %4.3f   %4.3f   %4.3f\n', mu(20), sig(20), paraint(1,20), paraint(2,20))
        fprintf('rho_is    %4.3f    %4.3f   %4.3f   %4.3f\n', mu(21), sig(21), paraint(1,21), paraint(2,21))
        fprintf('rho_pi    %4.3f    %4.3f   %4.3f   %4.3f\n', mu(22), sig(22), paraint(1,22), paraint(2,22))
        fprintf('sigma_pi    %4.3f    %4.3f   %4.3f   %4.3f\n', mu(23), sig(23), paraint(1,23), paraint(2,23))
        fprintf('rho_ps    %4.3f    %4.3f   %4.3f   %4.3f\n', mu(24), sig(24), paraint(1,24), paraint(2,24))

        smctime = tic; % re-start clock
    end
end


% Log marginal data density approximation
logmdd = sum(log(sum(unwtsim(:,2:tune.nphi))));
fprintf('-----------------------------------------------\n')
fprintf(' Log marginal data density = %5.4f\n', logmdd);
fprintf('-----------------------------------------------\n')

% Number of determinacy draws at posterior draws
ndetpost = zeros(tune.npart,1);

for i=1:1:tune.npart
    p1 = parapost(i,18)';
    if p1>1
        ndetpost(i) = 1;
    elseif p1<1
        ndetpost(i) = 0;
    end
end

pdetpost = sum(ndetpost)/tune.npart;

fprintf('-----------------------------------------------\n')
fprintf(' Posterior prob. of determinacy = %5.4f\n', pdetpost);
fprintf('-----------------------------------------------\n')

diary off;
save('results.mat');

mean(parapost)'
%uncond_vardec



