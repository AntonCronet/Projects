% ===============================================
% Example 5.1:
% General Equilibrium in the Two-Period Model
% This version: 09.11.2024
% Original Author: Oliver Holtemoeller

% Modified: 23.11.2024 - Digimops: xXDUrt

% Tested: Octave 6.4, Matlab R2023b, and Octave 9.2
% ===============================================

clear all;
close all;

% Check for Matlab/Octave
% -----------------------
MyEnv.Octave = exist('OCTAVE_VERSION', 'builtin') ~= 0;
MyEnv.Matlab = ~MyEnv.Octave;

disp(' ');
disp('******************************************');
disp('*** Two-Period Model                   ***');
disp('******************************************');
if MyEnv.Octave
    disp(['Start: ', strftime("%Y-%m-%d %H:%M", localtime(time()))]);
else
    disp(datetime('now','TimeZone','local','Format','yyyy-MM-dd HH:mm'));
end
disp('');

% Parameters
params.alpha = 0.3; % production function parameters
params.rho   = 0.05;
params.theta = 1;
params.tax = 0.38; % Added tax according to assigned value

% Exogenous variables
exog.k1 = 1;
exog.n1 = 1;
exog.n2 = 1;
exog.A1 = 1;
exog.A2 = 1;

% Initial values (now including g1 and g2)
initval = [ 1; 1; 10.5; 1; 0.7; 0.5; 0.3; 0.1; 0.5; 0.1; 0.1 ]; % Initial values for g1 and g2 added

% Solve nonlinear system
options = optimset('MaxIter', 10000, 'MaxFunEvals', 90000);
[ fsopt, fval, efl ] = fsolve(@(x)twoperiodequilibrium_tax(x, exog, params), initval, options);
%renamed the called function to the two period equilibrium with tax

% Display results
disp('Endogenous variables:');
disp(['y1: ', num2str(fsopt(1))]);
disp(['y2: ', num2str(fsopt(2))]);
disp(['c1: ', num2str(fsopt(3))]);
disp(['c2: ', num2str(fsopt(4))]);
disp(['w1: ', num2str(fsopt(5))]);
disp(['w2: ', num2str(fsopt(6))]);
disp(['r1: ', num2str(fsopt(7))]);
disp(['r2: ', num2str(fsopt(8))]);
disp(['k2: ', num2str(fsopt(9))]);
disp(['g1: ', num2str(fsopt(10))]); %Added to display g1, 10th place in output array
disp(['g2: ', num2str(fsopt(11))]); %Added to display g2, 11th place in output array
disp(' ');
disp(['Checksum: ', num2str(sum(fval))]);
disp(['Exit flag: ', num2str(efl)]);
if MyEnv.Octave
    disp(['End: ', strftime("%Y-%m-%d %H:%M", localtime(time()))]);
else
    disp(datetime('now','TimeZone','local','Format','yyyy-MM-dd HH:mm'));
end
disp('******************************************');
