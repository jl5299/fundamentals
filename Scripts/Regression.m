%% Import Fundamentals Data
% Setup the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 51);

% Specify range and delimiter
opts.DataLines = [2, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["PERMNO", "Date", "GVKEY", "DATADATE", "qtrsback", "conm", "exchg", "sic", "tic", "datacqtr", "ACOQh", "AOQh", "APQh", "ATQh", "CEQQh", "CHEQh", "DLTTQh", "DOQh", "DVPQh", "DVQh", "IBADJQh", "IBCOMQh", "IBQh", "ICAPTQh", "LCOQh", "LOQh", "LTQh", "NIQh", "NOPIQh", "PIQh", "PPENTQh", "PSTKQh", "PSTKRQh", "SALEQh", "SEQQh", "TEQQh", "TXTQh", "XIDOQh", "LINKPRIM", "LINKTYPE", "LPERMCO", "LINKDT", "TICKER", "PRC", "SHROUT", "vwretd", "vwretx", "ewretd", "ewretx", "sprtrn", "capital"];
opts.VariableTypes = ["double", "datetime", "double", "double", "double", "string", "double", "double", "string", "categorical", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "categorical", "categorical", "double", "double", "string", "double", "double", "double", "double", "double", "double", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, ["conm", "tic", "TICKER"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["conm", "tic", "datacqtr", "LINKPRIM", "LINKTYPE", "TICKER"], "EmptyFieldRule", "auto");
opts = setvaropts(opts, "Date", "InputFormat", "yyyyMMdd");

% Import the data
Fundamentals = readtable("C:\Users\Justin Law\Documents\Projects\Gillen - FA Optimization\fundamentals\Data\OrganizedData\1987Fundamentals.csv", opts);

% Clear temporary variables
clear opts
%% Import Benchmarks Data
% Setup the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 3);

% Specify range and delimiter
opts.DataLines = [2, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["SMB", "HML", "RF"];
opts.VariableTypes = ["double", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Import the data
Benchmarks = readtable("C:\Users\Justin Law\Documents\Projects\Gillen - FA Optimization\fundamentals\Data\OrganizedData\1987FamaData.csv", opts);

Benchmarks = table2array(Benchmarks)

% Clear temporary variables
clear opts

%% Import Returns Table
opts = detectImportOptions("C:\Users\Justin Law\Documents\Projects\Gillen - FA Optimization\fundamentals\Data\OrganizedData\1987returns.csv");
numVariables = length(opts.VariableNames);
opts.VariableTypes = repmat("double", 1, numVariables);
Returns = readtable("C:\Users\Justin Law\Documents\Projects\Gillen - FA Optimization\fundamentals\Data\OrganizedData\1987returns.csv",opts);

Returns = table2array(Returns)

clear opts
clear numVariables
%% Part I:  Estimate Fundamental Values and Mispricing 
% This block of code simulates fundamental values and market
%   capitalizations, estimates the fitted fundamental values and degree of
%   mispricing in order to parameterize the prior expected alpha in terms
%   of reversion in current market caps to fundamental values.  

% L = 27; % Number of Fundamental Factors
% N = 500; % Number of Assets in Universe

% Simulate Fundamental Factors.  The distribution used here is arbitrary,
% but you'll have real data so it's just a placeholder.  
% FundamentalFactors = randn(N, L)+7;
FundamentalFactors = Fundamentals{:,(11:38)};

% Assume the log Fundamental value is just the Mean of the Assets' 
%    Fundamental Factors.  This is dumb, but you'll have real data so it's
%    really just here as a placeholder.
% logFundamentalValue = mean(FundamentalFactors, 2);
% @@@@@@@@ THIS AINT EVEN USED HERE.... @@@@

% Simulating real market capitalizations as perturbed versions of their log
%   Fundamental Values.  It probably makes sense to have your y variable be
%   logged market capitalizations so they're more normally distributed.
%   Again, the simulation specificaton is arbitrary because you'll actually
%   be using real data.
% logMarketCaps = logFundamentalValue + randn(N, 1)*0.25; 
logMarketCaps = log(Fundamentals{:,51});

% Estimate Regression of log Market Caps on Fundamental Factors, including
%   a constant term for the intercept.  All of the previous simulation is
%   only necessary to set up this example.
FundamentalX = [ones(length(FundamentalFactors), 1), FundamentalFactors];
FundamentalBetas = FundamentalX \ logMarketCaps;

% Calculate Fitted Fundamental Values using estimated coefficients
logMarketCapHat = FundamentalX*FundamentalBetas;

% Recover Residuals Characterizing Mispricing
logResid = logMarketCaps - logMarketCapHat;

% Set Prior Expectation for (annualized) Alpha as the logResid / 3, since
%   the logResid already states the mispricing in percentage terms, this
%   postulates that market caps will revert to estimated fundamental values
%   in 3 years.
priorAlpha = logResid/3;

%% Part 2:  Estimate Bayesian CAPM Regression to Estimate Parameters for 
%           Means and Variances
%monthly returns of stocks returned on monthly benchmarks

K = 3; % Number of Benchmark Factors in Asset Pricing Model

%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ BELOW ONLY SIM
% T = 120; % Number of Months of Data $$$$$$$$$$$$$$$$$ SHOULDNT THIS BE 12? WHY 120?

% Begin Generating Simulated Return Series

%Assume Factors are uncorrelated with volatility 20% and annualized mean 5%
%  Note:  These will be the Fama French Factors, taken from Ken French's 
%  website, so you won't need to simulate them
% system

% Benchmarks = randn(T, K)*(0.2/sqrt(12)) + 0.05/12;


%Generate Random Betas: These are used to simulate returns, so again, you
%   won't need to do this, it's just for the illustration
% Betas = [randn(length(FundamentalFactors), 1) + 1, randn(length(FundamentalFactors), K-1)]';
% Alphas = randn(length(FundamentalFactors), 1)*0.02;
% SigmaEs = randn(length(FundamentalFactors), 1)*0.03+0.2;

% Simulate Return Residuals
% Epsys = randn(T, length(FundamentalFactors)).*repmat(SigmaEs', T, 1);

% Simulate Returns
% Returns = repmat(Alphas', T, 1) + Benchmarks*Betas + Epsys; % $###$#$@$@#$ returns = part 1 esitmated resid

%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ ABOVE ONLY SIM


% End Generating Simulated Return Series, essentially none of the above
%   will be necessary, as you'll be working with real return data

% Begin Estimating Return Generating Process

% Estimate Mean and Covariance Matrix for Benchmarks, calibrating the
%   benchmark return generating process
BenchmarkRiskPremium = mean(Benchmarks);
BenchmarkCovMat = cov(Benchmarks);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Step 1) Compute cross-sectional average residual squared error, this is
%           a shortcut for approximating a full conditional conjugate prior
%           model.  
s2=zeros(length(FundamentalFactors),1);
for i=1:length(FundamentalFactors)
    % trimming data to exclude missing (nan) data
    temp=logical(1-isnan(Returns(:,i)));
    Ri=Returns(temp,i);
    Fi=Benchmarks(temp,:);
    clear temp;
    Ti = size(Ri,1);             
    
    % Regress Returns on Benchmarks, Recover Resids
    Xi = [ones(Ti,1) Fi]; 
    Betahati = (Xi \ Ri);
    Resids_i = Ri - Xi*Betahati;
    
    % Compute Mean Squared Residual for asset i's returns
    s2(i) = sum(Resids_i.^2)/(Ti-K-1);
end

% Average Mean Squared Residual Across Assets
s2bar = mean(s2);

% Specify the prior variance for the alpha of an asset's returns.
%   sigma_alpha is a tuning parameter that characterizes the standard
%   deviation of an asset's alpha relative to its prior expectation.  A
%   "tight" prior is around 1% (annualized), while a relatively loose one
%   would be around 10%.  Think of the posterior alpha as lying in a range
%   of the prior alpha +/- 2 sigma_alphas.  
sigma_alpha = 0.01/12; 
PriorAlphaVar = (sigma_alpha^2)/s2bar;

%Step 2:  Compute Posterior RGP Parameters

% Create placeholders for parameters
PostTheta = zeros(length(FundamentalFactors), 1 + K);
Psi   = zeros(length(FundamentalFactors), 1);

for i = 1:length(FundamentalFactors) %on each column (returns) Yvars

    % trim data to exclude missing (nan) data ---> organizing fama french
    % data
    temp = logical(1-isnan(Returns(:,i)));
    Ti = sum(temp);
    Ri = Returns(temp, i);
    Xi = [ones(Ti,1) Benchmarks(temp,:)]; 

    % Construct Prior Matrices
    PriorV = eye(K+1)*1000000;
    PriorV(1, 1) = PriorAlphaVar;
    PriorB = [priorAlpha(i)/12; zeros(K, 1)];

    % Calculate Sample Regression Statistics
    XprimeX = Xi'*Xi;
    thetahat = Xi\Ri;
    sigmai_sq = sum((Ri - Xi*thetahat).^2)/(Ti-K-1);
    
    % Calculate Posterior Expectations and Variances
    PostV = inv(inv(PriorV) + XprimeX);
    PostThetai = PostV*(PriorV\PriorB + XprimeX*thetahat); %theta is vector - coefficient for asset i that takes A,B into acc
    %posttheta should have 1500 rows (all 1500 assets, with fama french)
    ParamUncertaintyAdj = (thetahat - PriorB)'*... % Vector update formula
                                inv(PriorV+inv(XprimeX))*...
                                  (thetahat - PriorB)/(Ti-K-1);
    PostSigmaSq = sigmai_sq  + ParamUncertaintyAdj;
    
    PostTheta(i, :) = PostThetai';
    Psi(i) = PostSigmaSq;
    
end

% This line tells you how far the posterior alpha varies from the prior
% alpha to demonstrate how different values for sigma_alpha affects the
% results.
disp('Maximum Annualized Alpha Deviation from Calibrated Prior:')
disp(12*max(abs(PostTheta(:, 1) - priorAlpha/12)))

%% Part 3:  Estimate Means and Covariance Matrix for Returns to use in 
%             Portfolio optimization exercise

% Posterior Mean Returns from the Factor Model
mu = PostTheta*[1; BenchmarkRiskPremium']; %1500 x1 

% Posterior Covariance Matrix of Returns from the Factor Model
PostBeta = PostTheta(:, 2:end);
Sigma = PostBeta*BenchmarkCovMat*PostBeta'+diag(Psi); %1500 x1500 

% Quadratic Programming Exercise

% Constrain weights to be non-negative (lower bound/upper bound)
lb = zeros(N, 1);
ub = ones(N, 1); 

% Constrain weights to sum to unity
Aeq = ones(1, N);
beq = 1;

% Optimize weights with Utility:  U = E - (gamma/2)*V
gamma = 2;
[w_opt, UStar, ExitFlag, Output] = ...
    quadprog(gamma*Sigma/2,-mu, [], [], Aeq, beq, lb, ub);
%w_opt is portfolio from June (year) to June (year+1)
