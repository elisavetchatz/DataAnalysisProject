% Exercise 6.6 
% The exercise is about dimension reduction in regression (discards 
% unnecessary predictors) on data from Mass and Physical Measurements for 
% Male Subjects. 
d = 2; % The dimension reduction.
datdir = 'D:\MyFiles\Teach\DataAnalysisTHMMY\Data\';
dattxt = 'physical';
varnameC = {'Mass';'Fore';'Bicep';'Chest';'Neck';'Shoulder';'Waist';'Height';'Calf';'Thigh';'Head'};

datM = load([datdir,dattxt,'.dat']);
yV = datM(:,1);
xM = datM(:,2:end);
p = size(xM,2);
n = length(yV);

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

%% Stepwise regression
[bV,sdbV,pvalV,inmodel,stats]=stepwisefit(xM,yV);
b0 = stats.intercept;
bSTEPV = [b0;bV].*[1 inmodel]';
% indxV = find(inmodel==1);
yfitSTEPV = [ones(n,1) xM] * bSTEPV;
resSTEPV = yV-yfitSTEPV;
RSSSTEP = sum(resSTEPV.^2);
rsquaredSTEP = 1 - RSSSTEP/TSS;
figure(11)
clf
plot(yV,yfitSTEPV,'.')
hold on
xlabel('y')
ylabel('$\hat{y}$','Interpreter','Latex')
title(sprintf('STEP R^2=%1.4f',rsquaredSTEP))
figure(12)
clf
plot(yV,resSTEPV/std(resSTEPV),'.','Markersize',10)
hold on
plot(xlim,1.96*[1 1],'--c')
plot(xlim,-1.96*[1 1],'--c')
xlabel('y')
ylabel('e^*')
title('STEP')

%% (c) The coefficients from all models
fprintf('\t OLS \t PCR \t PLS \t RR \t LASSO \t STEP \n');
fprintf('Const \t %1.3f \t %1.3f \t %1.3f \t %1.3f \t %1.3f \t %1.3f \n',...
    bOLSV(1),bPCRV(1),bPLSV(1),bRRV(1),bLASSOV(1),bSTEPV(1));
for i=2:p+1
    stringlength = min(length(varnameC{i-1}),5);
    fprintf('%s \t %1.3f \t %1.3f \t %1.3f \t %1.3f \t %1.3f \t %1.3f \n',...
        varnameC{i-1}(1:stringlength),bOLSV(i),bPCRV(i),bPLSV(i),bRRV(i),bLASSOV(i),bSTEPV(i));
end
