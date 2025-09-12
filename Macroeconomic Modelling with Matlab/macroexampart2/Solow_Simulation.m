clear all;
close all;
DoSavePlots = 0;

% Define intial parameters of the model
s      = 0.3;     % Savings ratio
alpha  = 0.3;     % capital elasticity of output
delta  = 0.1;     % depreciation rate
A1     = 1;      % Total factor productivity economy 1
A2     = 1.1;     % Total factor productivity economy 2
k_init = 0.1;     % Initial productivity values for both economies

T = 100;          % Number of time periods / loop iterations


% Initialising vectors based on iterations to be simulated
k1 = zeros(T, 1); % Capital stock economy 1
k2 = zeros(T, 1); % Capital stock economy 2
y1 = zeros(T, 1); % Productivity economy 1
y2 = zeros(T, 1); % Productivity economy 2


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Simulate k and y over time %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Setting the initial capita lstock value
k1(1) = k_init;
k2(1) = k_init;

% Calculating the first value for y
y1(1) = A1 * k1(1)^alpha;
y2(1) = A2 * k2(1)^alpha;

% Looping for the rest of the values, indices match with the equations of the model
for t = 2:T

  k1(t) = s * y1(t-1) + (1 - delta) * k1(t-1)
  k2(t) = s * y2(t-1) + (1 - delta) * k2(t-1)

  y1(t) = A1 * k1(t)^alpha;
  y2(t) = A2 * k2(t)^alpha;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plotting k and y over time %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Plot results of the simulation for capital stock per capita (k)
figure;
  hold on; % for multiple plots on a same figure
  plot(1:T, k1, 'Color', [1, 0.6, 0], 'LineWidth', 2);
  plot(1:T, k2, 'Color', [0, 0.45, 0.75], 'LineWidth', 2);
  xlabel('Time');
  ylabel('Capital Stock (per capita)');
  legend('Economy 1 (A = 1)', 'Economy 2 (A = 1.1)');
  ylim([0, 7]); % Set upper limit of y to 7 to avoid overlap of legend on plot
  grid on;


% Plot results of the simulation for per capita production (y)
figure;
  hold on; % for multiple plots on a same figure
  plot(1:T, y1, 'Color', [1, 0.6, 0], 'LineWidth', 2);
  plot(1:T, y2, 'Color', [0, 0.45, 0.75], 'LineWidth', 2);
  xlabel('Time');
  ylabel('Per Capita Production (y)');
  legend('Economy 1 (A = 1)', 'Economy 2 (A = 1.1)');
  ylim([0, 2.5]); % avoid overlap of legend on plot
  grid on;

