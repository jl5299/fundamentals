%% Set variables
year = 1987;
% sigmaAlphaInput = 0.03;
% gamma = 4;
for sigmaAlphaInput = [0.01,0.1] % sigmaalpha (0.01 - 0.1)
% for sigmaAlphaInput = [0.01,0.02,0.03,0.04,0.05,0.06,0.07,0.08,0.09,0.1] % sigmaalpha (0.01 - 0.1)
    for gamma = [2,16] % gamma (2 - 16)
%     for gamma = [2,3,4,5,6,7,8,9,10,11,12,13,14,15,16] % gamma (2 - 16)
        
        % ------------------------ DATA IMPORTS -------------------------
        % Import Fundamentals Data
        % Setup the Import Options and import the data
        opts = delimitedTextImportOptions("NumVariables", 51);

        % Specify range and delimiter
        opts.DataLines = [2, Inf];
        opts.Delimiter = ",";

        % Specify column names and types
        opts.VariableNames = ["PERMNO", "Date", "GVKEY", "DATADATE", "qtrsback", "conm", "exchg", "sic", "tic", "datacqtr", "ACOQh", "AOQh", "APQh", "ATQh", "CEQQh", "CHEQh", "DLTTQh", "DOQh", "DVPQh", "DVQh", "IBADJQh", "IBCOMQh", "IBQh", "ICAPTQh", "LCOQh", "LOQh", "LTQh", "NIQh", "NOPIQh", "PIQh", "PPENTQh", "PSTKQh", "PSTKRQh", "SALEQh", "SEQQh", "TEQQh", "TXTQh", "XIDOQh", "LINKPRIM", "LINKTYPE", "LPERMCO", "LINKDT", "TICKER", "PRC", "SHROUT", "vwretd", "vwretx", "ewretd", "ewretx", "sprtrn", "capital"];
        opts.VariableTypes = ["double", "double", "double", "double", "double", "string", "double", "double", "string", "categorical", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "categorical", "categorical", "double", "double", "string", "double", "double", "double", "double", "double", "double", "double", "double"];

        % Specify file level properties
        opts.ExtraColumnsRule = "ignore";
        opts.EmptyLineRule = "read";

        % Specify variable properties
        opts = setvaropts(opts, ["conm", "tic", "TICKER"], "WhitespaceRule", "preserve");
        opts = setvaropts(opts, ["conm", "tic", "datacqtr", "LINKPRIM", "LINKTYPE", "TICKER"], "EmptyFieldRule", "auto");

        % Import the data
        Fundamentals = readtable("C:\Users\Justin Law\Documents\Projects\Gillen - FA Optimization\fundamentals\Data\OrganizedData\Fundamentals.csv", opts);

        % Clear temporary variables
        clear opts 
        % Import Benchmarks Data (Fama French Factors)
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
        Benchmarks = readtable("C:\Users\Justin Law\Documents\Projects\Gillen - FA Optimization\fundamentals\Data\OrganizedData\FamaData.csv", opts);

        Benchmarks = table2array(Benchmarks);

        % Clear temporary variables
        clear opts

        % Import Returns Table
        opts = detectImportOptions("C:\Users\Justin Law\Documents\Projects\Gillen - FA Optimization\fundamentals\Data\OrganizedData\returns.csv");
        numVariables = length(opts.VariableNames);
        opts.VariableTypes = repmat("double", 1, numVariables);
        Returns = readtable("C:\Users\Justin Law\Documents\Projects\Gillen - FA Optimization\fundamentals\Data\OrganizedData\returns.csv",opts);

        Returns = table2array(Returns);

        clear opts
        clear numVariables
        
        % -------------------- END DATA IMPORTS -------------------------

        % Part I:  Estimate Fundamental Values and Mispricing 
        % This block of code estimates the fitted fundamental values and degree of
        %   mispricing in order to parameterize the prior expected alpha in terms
        %   of reversion in current market caps to fundamental values.  

        % L = 27 = Number of Fundamental Factors

        FundamentalFactors = Fundamentals{:,(11:38)};

        logMarketCaps = log(Fundamentals{:,51});

        % Estimate Regression of log Market Caps on Fundamental Factors, including a constant term for the intercept.
        FundamentalX = [ones(length(FundamentalFactors), 1), FundamentalFactors];
        
        FundamentalBetas = FundamentalX \ logMarketCaps;  % \ --> Solve systems of linear equations Ax = B for x

        % Calculate Fitted Fundamental Values using estimated coefficients
        logMarketCapHat = FundamentalX*FundamentalBetas;

        % Recover Residuals Characterizing Mispricing
        logResid = logMarketCaps - logMarketCapHat;

        % Set Prior Expectation for (annualized) Alpha as the logResid / 3, since
        %   the logResid already states the mispricing in percentage terms, this
        %   postulates that market caps will revert to estimated fundamental values
        %   in 3 years.
        priorAlpha = -logResid/300;

    
        % Part 2:  Estimate Bayesian CAPM Regression to Estimate Parameters for 
        %           Means and Variances
        % monthly returns of stocks returned on monthly benchmarks

        K = 3; % Number of Benchmark Factors in Asset Pricing Model
        % T = Number of Months of Data

        % Begin Estimating Return Generating Process

        % Estimate Mean and Covariance Matrix for Benchmarks, calibrating the
        %   benchmark return generating process
        BenchmarkRiskPremium = mean(Benchmarks);
        BenchmarkCovMat = cov(Benchmarks);

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
        sigma_alpha = sigmaAlphaInput/12; 
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

        % This was to find the max row that was throwing everything off (max alpha
        % deviation)
        disp(find((abs(PostTheta(:,1)-priorAlpha/12)== max(abs(PostTheta(:,1)-priorAlpha/12)))))

        % Part 3:  Estimate Means and Covariance Matrix for Returns to use in 
        %             Portfolio optimization exercise

        % Posterior Mean Returns from the Factor Model
        mu = PostTheta*[1; BenchmarkRiskPremium']; %1500 x1 

        % Posterior Covariance Matrix of Returns from the Factor Model
        PostBeta = PostTheta(:, 2:end);
        Sigma = PostBeta*BenchmarkCovMat*PostBeta'+diag(Psi); %1500 x1500 

        % Quadratic Programming Exercise

        % Constrain weights to be non-negative (lower bound/upper bound)
        lb = zeros(length(FundamentalFactors), 1);
        ub = ones(length(FundamentalFactors), 1); 

        % Constrain weights to sum to unity
        Aeq = ones(1, length(FundamentalFactors));
        beq = 1;

        % Optimize weights with Utility:  U = E - (gamma/2)*V (built into
        % quadprog)
        % Gamma at 10 or 20 gives good vals (risk aversion) 
        % gamma 1 or 2 ~ risk tolerant, higher is risk averse 
        [w_opt, UStar, ExitFlag, Output] = ...
            quadprog(gamma*Sigma/2,-mu, [], [], Aeq, beq, lb, ub);
        %w_opt is portfolio from June (year) to June (year+1)

        SR = mu./sqrt(diag(Sigma)); % Sharpe ratio 

        % Part 3.5: Find top 5 and bottom 5 assets and relevant stats
        alphaDeviation = 12*(abs(PostTheta(:, 1) - priorAlpha/12));

        [sortedpriorAlpha, sortedInds] = sort(priorAlpha(:),'descend');
        [sortedCalibratedAlpha, sortedIndsCal] = sort(alphaDeviation,'descend');
 
       
        % My method of finding winners/losers
%         topCal = sortedIndsCal(1:5);
%         botCal = sortedIndsCal(end-4:end);

%         top5 = sortedInds(1:5);
%         bot5 = sortedInds(end-4:end);

        % Gillen's way of finding winners/losers
        quantile(priorAlpha, [5/length(priorAlpha), (length(priorAlpha)-5)/length(priorAlpha)]);
        
        MinA = quantile(priorAlpha, 5/length(priorAlpha));
        MaxA = quantile(priorAlpha, (length(priorAlpha)-5)/length(priorAlpha));
        bot5 = find(priorAlpha <= MinA);
        top5 = find(priorAlpha >= MaxA);
        topCal = sortedIndsCal(1:length(top5));
        botCal = sortedIndsCal(end-length(bot5)+1:end);
        
        resultsTop = Fundamentals(top5, "TICKER");
        resultsTop.year = ones(height(resultsTop),1)*year;
        resultsTop.gamma = ones(height(resultsTop),1)*gamma;
        resultsTop.sigmaAlpha = ones(height(resultsTop),1)*sigmaAlphaInput;
        resultsTop.Pior_Alpha = priorAlpha(top5);
        resultsTop.Weights = w_opt(top5);
        % resultsTop.index = top5;
        resultsTop.Annualized_Alpha_Deviation_from_Calibrated_Prior = alphaDeviation(topCal);


        resultsBot = Fundamentals(bot5, "TICKER");
        resultsBot.year = ones(height(resultsBot),1)*year;
        resultsBot.gamma = ones(height(resultsBot),1)*gamma;
        resultsBot.sigmaAlpha = ones(height(resultsBot),1)*sigmaAlphaInput;
        resultsBot.PriorAlpha = priorAlpha(bot5);
        resultsBot.Weights = w_opt(bot5);
        % resultsBot.index = bot5;
        resultsBot.Annualized_Alpha_Deviation_from_Calibrated_Prior = alphaDeviation(botCal);

        disp(resultsTop)
        disp(resultsBot)

        writetable(resultsTop,'../../resultstop.csv','WriteVariableNames',false,'WriteMode','Append');
        writetable(resultsBot,'../../resultsbot.csv','WriteVariableNames',false,'WriteMode','Append');
    end
end


% Part 4: Portfolio Optimization Backtesting

% --------------------------- DATA IMPORTS -------------------------
%Import next year returns data
opts = delimitedTextImportOptions("NumVariables", 13);

% Specify range and delimiter
opts.DataLines = [2, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["PERMNO", "DATE", "n", "RET", "alpha", "b_mkt", "b_smb", "b_hml", "ivol", "tvol", "R2", "exret", "TICKER"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "categorical"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, "TICKER", "EmptyFieldRule", "auto");
opts = setvaropts(opts, ["RET", "ivol", "tvol", "R2", "exret"], "TrimNonNumeric", true);
opts = setvaropts(opts, ["RET", "ivol", "tvol", "R2", "exret"], "ThousandsSeparator", ",");

% Import the data
nextReturns = readtable("C:\Users\Justin Law\Documents\Projects\Gillen - FA Optimization\fundamentals\Data\OrganizedData\nextReturns.csv", opts);

% Clear temporary variables
clear opts
% ------------------------ END DATA IMPORTS -------------------------
top5Permno = Fundamentals(top5, {'PERMNO'});
bot5Permno = Fundamentals(bot5, {'PERMNO'});

idxTop = ismember(nextReturns(:,1), top5Permno);

topNextReturns = nextReturns(idxTop,:);

idxBot = ismember(nextReturns(:,1), bot5Permno);
botNextReturns = nextReturns(idxBot,:);

topNextReturns = topNextReturns(all(~isnan(topNextReturns.RET),2),:);
botNextReturns = botNextReturns(all(~isnan(botNextReturns.RET),2),:);

topNextSumReturns = sum(topNextReturns.RET)/length(topNextReturns.RET);
botNextSumReturns = sum(botNextReturns.RET)/length(topNextReturns.RET);

totalReturns = topNextSumReturns - botNextSumReturns;
disp("Total Returns by financing top quartile prior alpha assets (winners) by shorting bottom quartile prior alpha assets(losers):");
disp(totalReturns);
