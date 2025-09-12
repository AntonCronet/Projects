% ===============================================
% Example 9.1 Edited version
% Ramsey Growth Model with Dynare
% This version: 18.01.2025
% Original Author: Oliver Holtemoeler
% Edited by: Anton Cronet
% Tested: Octave 9.2 and Dynare 6.2
% ===============================================

clear all;
close all;

addpath('C:\dynare\6.2\matlab') % Tell Octave where to find Dynare software

% Colorblind barrier-free color pallet
BfOrange       = [ 230, 159,   0 ]/255;

% Line Properties
StdLineWidth = 2;

disp(' ');
disp('******************************************');
disp('***        Ramsey Growth Model         ***');
disp('******************************************');
disp(' ');

% Run Dynare to initialize the model
dynare ramseygrowth_perm noclearall;

T = length(k);

% Baseline Endogenous Variables
endog_0.k = k(1) * ones(T, 1);
endog_0.c = c(1) * ones(T, 1);
endog_0.y = y(1) * ones(T, 1);
endog_0.i = i(1) * ones(T, 1);
endog_0.s = endog_0.i ./ endog_0.y;       % Savings rate
endog_0.rho_v = rho_v(1) * ones(T, 1);    % Time Preference Rate


% Endogenous Variables in the Alternative Scenario
endog_1.k = k;
endog_1.c = c;
endog_1.y = y;
endog_1.i = i;
endog_1.s = endog_1.i ./ endog_1.y;      % Savings rate
endog_1.rho_v = rho_v;                   % Time Preference Rate

Time = 1:min(T,100);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define a vector of time preference rates (rho_p)

rho_p_vec = 0.01:0.005:0.05;  % From 0.01 to 0.05 in steps of 0.005
s_vec = zeros(size(rho_p_vec));  % initialise saving rate, same lenght as rho vector

% Loop through each value of rho_p
for ii = 1:length(rho_p_vec) % "i" would interfere with model values, index set as "ii"

  % Set the new time preference rate
  set_param_value('rho_p', rho_p_vec(ii));

  % Recalculate steady state
  steady; % Note: rho_v is displayed in console and is correctly 2 * rho_p

  % Save steady state savings rate in respective vector
  s_vec(ii) = oo_.steady_state(6); % s is 6th row of the output

end

% Plot steady-state savings rate as a function of rho_p
figure;
  plot(rho_p_vec, s_vec, 'color', BfOrange, 'LineWidth', StdLineWidth);
  xlabel('Time Preference Rate (\rho_p)');
  ylabel('Steady State Savings Rate (s)');
  title('Steady State Savings Rate depending on Time Preference Rate');
  grid on;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compare Shock Scenario to Baseline Scenario (levels)

figure;
  subplot(3,2,1);
    hold on;
    plot(Time, endog_1.k(1:length(Time)), 'color', BfOrange, 'LineWidth', StdLineWidth);
    plot(Time, endog_0.k(1:length(Time)), 'color', 'black', 'LineWidth', StdLineWidth/3);
    hold off;
    title('Capital');

  subplot(3,2,2);
    hold on;
    plot(Time, endog_1.c(1:length(Time)), 'color', BfOrange, 'LineWidth', StdLineWidth);
    plot(Time, endog_0.c(1:length(Time)), 'color', 'black', 'LineWidth', StdLineWidth/3);
    hold off;
    title('Consumption');

  subplot(3,2,3);
    hold on;
    plot(Time, endog_1.y(1:length(Time)), 'color', BfOrange, 'LineWidth', StdLineWidth);
    plot(Time, endog_0.y(1:length(Time)), 'color', 'black', 'LineWidth', StdLineWidth/3);
    hold off;
    title('Output');

  subplot(3,2,4);
    hold on;
    plot(Time, endog_1.s(1:length(Time)), 'color', BfOrange, 'LineWidth', StdLineWidth);
    plot(Time, endog_0.s(1:length(Time)), 'color', 'black', 'LineWidth', StdLineWidth/3);
    hold off;
    title('Savings Rate');

  subplot(3,2,5);
    hold on;
    plot(Time, endog_1.i(1:length(Time)), 'color', BfOrange, 'LineWidth', StdLineWidth);
    plot(Time, endog_0.i(1:length(Time)), 'color', 'black', 'LineWidth', StdLineWidth/3);
    hold off;
    title('Investment');

  subplot(3,2,6);
    hold on;
    plot(Time, endog_1.rho_v(1:length(Time)), 'color', BfOrange, 'LineWidth', StdLineWidth);
    plot(Time, endog_0.rho_v(1:length(Time)), 'color', 'black', 'LineWidth', StdLineWidth/3);
    hold off;
    title('Time Preference Rate (\rho_v)');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compare Shock Scenario to Baseline Scenario (Percentages)

figure;
  subplot(3,2,1);
    hold on;
    plot(Time, 100*endog_1.k(1:length(Time))./endog_0.k(1:length(Time))-100, 'color', BfOrange, 'LineWidth', StdLineWidth);
    plot(Time, zeros(length(Time),1), 'color', 'black', 'LineWidth', StdLineWidth/3);
    hold off;
    ylabel('% dev.');
    title('Capital');

  subplot(3,2,2);
    hold on;
    plot(Time, 100*endog_1.c(1:length(Time))./endog_0.c(1:length(Time))-100, 'color', BfOrange, 'LineWidth', StdLineWidth);
    plot(Time, zeros(length(Time),1), 'color', 'black', 'LineWidth', StdLineWidth/3);
    hold off;
    ylabel('% dev.');
    title('Consumption');

  subplot(3,2,3);
    hold on;
    plot(Time, 100*endog_1.y(1:length(Time))./endog_0.y(1:length(Time))-100, 'color', BfOrange, 'LineWidth', StdLineWidth);
    plot(Time, zeros(length(Time),1), 'color', 'black', 'LineWidth', StdLineWidth/3);
    hold off;
    ylabel('% dev.');
    title('Output');

  subplot(3,2,4);
    hold on;
    plot(Time, 100*endog_1.s(1:length(Time))./endog_0.s(1:length(Time))-100, 'color', BfOrange, 'LineWidth', StdLineWidth);
    plot(Time, zeros(length(Time),1), 'color', 'black', 'LineWidth', StdLineWidth/3);
    hold off;
    ylabel('% dev.');
    title('Savings Rate');

  subplot(3,2,5);
    hold on;
    plot(Time, 100*endog_1.i(1:length(Time))./endog_0.i(1:length(Time))-100, 'color', BfOrange, 'LineWidth', StdLineWidth);
    plot(Time, zeros(length(Time),1), 'color', 'black', 'LineWidth', StdLineWidth/3);
    hold off;
    ylabel('% dev.');
    title('Investment');

  subplot(3,2,6);
    hold on;
    plot(Time, 100*endog_1.rho_v(1:length(Time))./endog_0.rho_v(1:length(Time))-100, 'color', BfOrange, 'LineWidth', StdLineWidth);
    plot(Time, zeros(length(Time),1), 'color', 'black', 'LineWidth', StdLineWidth/3);
    hold off;
    ylabel('% dev.');
    title('Time Preference Rate (\rho_v)');

