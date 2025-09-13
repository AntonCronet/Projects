close all;
clear all;

% Read the CSV file
gdp = csvread('cleaned_data.csv', 1, 0);

% Set the HP filter smoothing parameter
HP_LAMBDA = 1600; % Usual value for quarterly data

% Apply the HP filter
[hpcycle, hptrend] = hpfilter(gdp, HP_LAMBDA);

% Plot the cyclical component
figure; % Create a new figure
  plot(hpcycle, 'LineWidth', 2);

  xlabel('Year'); % Label the x-axis

  xticks([1 38 82 99]); % Define positions of ticks
  xticklabels({'2000', '2009', '2020' , '2024-Q3'}); % Set character labels for ticks

  ylabel('Cyclical Component'); % Label the y-axis

  title('France GDP - Cyclical Component from HP Filter'); % Add a title

  grid on; % Add a grid



