
clc
clear all
close all

% load the data
startdate = '01/01/1994';
enddate = '01/01/2019';
f = fred
Y = fetch(f,'JPNRGDPEXP',startdate,enddate)
C = fetch(f,'RGDPNAMNA666NRUG',startdate,enddate)
y = log(Y.Data(:,2));
c = log(C.Data(:,2));
q = Y.Data(:,1);
z = C.Data(:,1);

load y.mat
load c.mat
load q.mat

T = size(y,1);
M = size(c,1);

% Hodrick-Prescott filter
lam = 1600;
A = zeros(T,T);
B = zeros(M,M);

% unusual rows
A(1,1)= lam+1; A(1,2)= -2*lam; A(1,3)= lam;
A(2,1)= -2*lam; A(2,2)= 5*lam+1; A(2,3)= -4*lam; A(2,4)= lam;

A(T-1,T)= -2*lam; A(T-1,T-1)= 5*lam+1; A(T-1,T-2)= -4*lam; A(T-1,T-3)= lam;
A(T,T)= lam+1; A(T,T-1)= -2*lam; A(T,T-2)= lam;

B(1,1)= lam+1; B(1,2)= -2*lam; B(1,3)= lam;
B(2,1)= -2*lam; B(2,2)= 5*lam+1; B(2,3)= -4*lam; B(2,4)= lam;

B(T-1,T)= -2*lam; B(T-1,T-1)= 5*lam+1; B(T-1,T-2)= -4*lam; B(T-1,T-3)= lam;
B(T,T)= lam+1; B(T,T-1)= -2*lam; B(T,T-2)= lam;


% generic rows
for i=3:T-2
    A(i,i-2) = lam; A(i,i-1) = -4*lam; A(i,i) = 6*lam+1;
    A(i,i+1) = -4*lam; A(i,i+2) = lam;
end

for i=3:M-2
   B(i,i-2) = lam; B(i,i-1) = -4*lam; B(i,i) = 6*lam+1;
   B(i,i+1) = -4*lam; B(i,i+2) = lam;
end

tauGDPforJ = A\y;
tauGDPforM = B\c;


% detrended GDP
ytilde = y-tauGDPforJ;
ctilde = c-tauGDPforM;

% plot detrended GDP
dates = 1994:1/4:2019.1/4; zerovec = zeros(size(y));
figure
plot(q, ytilde,'b', q, ctilde,'r');
title('Detrended log(real GDP) 1994Q1-2019Q1');
legend("Japan","Mongol");
xlabel("Year");
ylabel("GDP");
datetick('x', 'yyyy-qq');


% compute sd(y), sd(c), rho(y), rho(c), corr(y,c) (from detrended series)
ysd = std(ytilde)*100;
yrho = corrcoef(ytilde(2:T),ytilde(1:T-1)); yrho = yrho(1,2);
corryc = corrcoef(ytilde(1:T),ctilde(1:T)); corryc = corryc(1,2);

disp(['Percent standard deviation of detrended log real GDP: ', num2str(ysd),'.']); disp(' ')
disp(['Serial correlation of detrended log real GDP: ', num2str(yrho),'.']); disp(' ')
disp(['Contemporaneous correlation between detrended log real GDP and PCE: ', num2str(corryc),'.']);



