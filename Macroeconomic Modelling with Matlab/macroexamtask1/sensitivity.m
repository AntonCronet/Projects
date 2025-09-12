% ===============================================
% Example 5.2:
% General Equilibrium in the Two-Period Model
% Variation of Parameters (Sensitivity Analysis)
% This version: 09.11.2024 (Octave 6.4)
% Original Author: Oliver Holtemoeller

% Modified 23.11.2024 - Octave 9.2 - Digimops: xXDUrt

% ===============================================

close all;
clear all;

% Check for Matlab/Octave
% -----------------------
MyEnv.Octave = exist('OCTAVE_VERSION', 'builtin') ~= 0;
MyEnv.Matlab = ~MyEnv.Octave;

DoSavePlots = 0;

disp(' ');
disp('******************************************');
disp('*** Two-Period Model: Sensitivity      ***');
disp('******************************************');
if MyEnv.Octave
    disp(['Start: ', strftime("%Y-%m-%d %H:%M", localtime(time()))]);
else
    disp(datetime('now','TimeZone','local','Format','yyyy-MM-dd HH:mm'));
end
disp('');

% Colorblind barrier-free color pallet
BfBlack        = [   0,   0,   0 ]/255;
BfOrange       = [ 230, 159,   0 ]/255;
BfSkyBlue      = [  86, 180, 233 ]/255;
BfBluishGreen  = [   0, 158, 115 ]/255;
BfYellow       = [ 240, 228,  66 ]/255;
BfBlue         = [   0, 114, 178 ]/255;
BfVermillon    = [ 213,  94,   0 ]/255;
BfRedishPurple = [ 204, 121, 167 ]/255;

% Baseline parameters
params.alpha = 0.3;
params.rho   = 0.02;
params.theta = 1;
params.tax = 0.38; % Added tax according to assigned value
BaselineParams = params;

% Exogenous variables
exog.k1 = 1;
exog.n1 = 1;
exog.n2 = 1;
exog.A1 = 1;
exog.A2 = 1;

% Specify initial variables
initval = [ 1; 1; 10.5; 1; 0.7; 0.5; 0.3; 0.1; 0.5; 0.1; 0.1 ]; % Initial values for g1 and g2 added
options = optimset('MaxIter', 10000, 'MaxFunEvals', 90000);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Modified code relevant to parameter tau %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Sensitivity Analysis: Tax rate (tau)
params = BaselineParams;
g1_results = []; % Initialize array for g1 computations
MyResults.tau = []; % Initialize array for relevant tau values
tauVec = 0:0.1:1; % tau values randing from 0 to 1, with steps of 0.1


for tau = tauVec
    params.tax = tau;
    % Solve nonlinear system
    [ fsopt, fval, efl ] = fsolve(@(x)twoperiodequilibrium_tax(x, exog, params), initval, options);

    % Compute g1 using tax, r1, and k1
    %r1 = fsopt(7); % Extract r1 from solution of fsolve
    %g1 = tau * r1 * exog.k1; % g1 = tax * r1 * k1 as defined in problem 2

    %Get g1 from 10th spot in output array
    g1 = fsopt(10);
    g1_results = [g1_results, g1]; %adds new g1 value to the results array

    %NOTE: same graph is plotted when fetching g1 directly from output array or calculating it with r1
end

% Display results
fig_counter = 0;

% Plot g1 as a function of tau
fig_counter = fig_counter + 1;
hf = figure(fig_counter);
plot(tauVec, g1_results, 'color', BfBlue, 'LineWidth', 3);
title('Sensitivity of g_1 to \tau');
xlabel('Tax Rate (\tau)');
ylabel('g_1');
if DoSavePlots
    saveas(hf, '../../figures/fig_Two-Period-Tau.png', 'png');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   End of modified code relevant to tau  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Done. Bye.');
if MyEnv.Octave
    disp(['End: ', strftime("%Y-%m-%d %H:%M", localtime(time()))]);
else
    disp(datetime('now','TimeZone','local','Format','yyyy-MM-dd HH:mm'));
end
disp('******************************************');
