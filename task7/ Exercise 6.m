% Exercise 6.5
% The exercise is about dimension reduction in regression (discards
% unnecessary predictors). The p predictor variables in X are generated
% from exponential distributions with various means.
n = 200; % The number of observations
p = 5; % The number of predictors
betaV = [0;2;0;-3;0]; % The true regression coefficients
d = 2; % The dimension reduction.
nsd = 5; % The noise SD
rng(3,'twister') % For reproducibility

xM = zeros(n,p);
for ii = 1:p
    xM(:,ii) = exprnd(ii,n,1);
end
%% Generate response data Y = X * beta + eps
yV = xM*betaV + nsd*randn(n,1);

TSS = sum((yV-mean(yV)).^2);
% Centering the predictor and response data
mxV = mean(xM);
xcM = xM - repmat(mxV,n,1); % centered data matrix
my = mean(yV);
ycV = yV - my;

[uM,sigmaM,vM] = svd(xcM,'econ');
%% (a) Estimation of the model and (b) plots for fitting and residuals
%% OLS  
bOLSV = vM * inv(sigmaM) * uM'* ycV;
bOLSV = [my - mxV*bOLSV; bOLSV];
yfitOLSV = [ones(n,1) xM] * bOLSV; 
resOLSV = yV-yfitOLSV;
RSSOLS = sum(resOLSV.^2);
rsquaredOLS = 1 - RSSOLS/TSS;
figure(1)
clf
plot(yV,yfitOLSV,'.')
hold on
xlabel('y')
ylabel('$\hat{y}$','Interpreter','Latex')
title(sprintf('OLS R^2=%1.4f',rsquaredOLS))
figure(2)
clf
plot(yV,resOLSV/std(resOLSV),'.','Markersize',10)
hold on
plot(xlim,1.96*[1 1],'--c')
plot(xlim,-1.96*[1 1],'--c')
xlabel('y')
ylabel('e^*')
title('OLS')

%% PCR
lambdaV = zeros(p,1);
lambdaV(1:d) = 1;
bPCRV = vM * diag(lambdaV) * inv(sigmaM) * uM'* ycV;
bPCRV = [my - mxV*bPCRV; bPCRV];
yfitPCRV = [ones(n,1) xM] * bPCRV; 
resPCRV = yfitPCRV - yV;     % Calculate residuals
RSSPCR = sum(resPCRV.^2);
rsquaredPCR = 1 - RSSPCR/TSS;
figure(3)
clf
plot(yV,yfitPCRV,'.')
hold on
xlabel('y')
ylabel('$\hat{y}$','Interpreter','Latex')
title(sprintf('PCR R^2=%1.4f',rsquaredPCR))
figure(4)
clf
plot(yV,resPCRV/std(resPCRV),'.','Markersize',10)
hold on
plot(xlim,1.96*[1 1],'--c')
plot(xlim,-1.96*[1 1],'--c')
xlabel('y')
ylabel('e^*')
title('PCR')

%% PLS
[Xloadings,Yloadings,Xscores,Yscores,bPLSV] = plsregress(xM,yV,d);
yfitPLSV = [ones(n,1) xM]*bPLSV;
resPLSV = yfitPLSV - yV;     % Calculate residuals
RSSPLS = sum(resPLSV.^2);
rsquaredPLS = 1 - RSSPLS/TSS;
figure(5)
clf
plot(yV,yfitPLSV,'.')
hold on
xlabel('y')
ylabel('$\hat{y}$','Interpreter','Latex')
title(sprintf('PLS R^2=%1.4f',rsquaredPLS))
figure(6)
clf
plot(yV,resPLSV/std(resPLSV),'.','Markersize',10)
hold on
plot(xlim,1.96*[1 1],'--c')
plot(xlim,-1.96*[1 1],'--c')
xlabel('y')
ylabel('e^*')
title('PLS')

%% Ridge regression
% [u2M,sigma2M,v2M] = svd(xcM);
% mu = (1/(n-p)) * sum((u2M(:,p+1:n)'*ycV).^2);
mu = RSSOLS/(n-p);
sigmaV = diag(sigmaM);
lambdaV = sigmaV.^2 ./ (sigmaV.^2 + mu);
bRRV = vM * diag(lambdaV) * inv(sigmaM) * uM'* ycV;
bRRV = [my - mxV*bRRV; bRRV];
% bRRV = ridge(yV,xM,mu,0);
yfitRRV = [ones(n,1) xM] * bRRV; 
resRRV = yfitRRV - yV;     % Calculate residuals
RSSRR = sum(resRRV.^2);
rsquaredRR = 1 - RSSRR/TSS;
figure(7)
clf
plot(yV,yfitRRV,'.')
hold on
xlabel('y')
ylabel('$\hat{y}$','Interpreter','Latex')
title(sprintf('RR R^2=%1.4f',rsquaredRR))
figure(8)
clf
plot(yV,resRRV/std(resRRV),'.','Markersize',10)
hold on
plot(xlim,1.96*[1 1],'--c')
plot(xlim,-1.96*[1 1],'--c')
xlabel('y')
ylabel('e^*')
title('RR')

%% LASSO 
[bM,fitinfo] = lasso(xcM,ycV);
lassoPlot(bM,fitinfo,'PlotType','Lambda','XScale','log');
lambda = input('Give lambda > ');
[lmin, ilmin] = min(abs(fitinfo.Lambda - lambda));
bLASSOV = bM(:,ilmin);
bLASSOV = [my - mxV*bLASSOV; bLASSOV];
yfitLASSOV = [ones(n,1) xM] * bLASSOV; 
resLASSOV = yfitLASSOV - yV;     % Calculate residuals
RSSLASSO = sum(resLASSOV.^2);
rsquaredLASSO = 1 - RSSLASSO/TSS;
figure(9)
clf
plot(yV,yfitLASSOV,'.')
hold on
xlabel('y')
ylabel('$\hat{y}$','Interpreter','Latex')
title(sprintf('LASSO R^2=%1.4f',rsquaredLASSO))
figure(10)
clf
plot(yV,resLASSOV/std(resLASSOV),'.','Markersize',10)
hold on
plot(xlim,1.96*[1 1],'--c')
plot(xlim,-1.96*[1 1],'--c')
xlabel('y')
ylabel('e^*')
title('LASSO')

%% (c) The coefficients from all models
fprintf('\t OLS \t PCR \t PLS \t RR \t LASSO \n');
disp([bOLSV bPCRV bPLSV bRRV bLASSOV])
