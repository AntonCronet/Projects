% Load the data
data = csvread('Cleaned_Data.csv');

% Extract columns for countries and GDP per capita
LKA_GDP = data(3:end, 1); % Skip the first two value in the first column
NOR_GDP = data(3:end, 2); % Skip the first two value in the second column
years = data(3:end, 3); % Skip the first two value in the third column

% Plot for Sri Lanka GDP
figure;
  plot(years, LKA_GDP, 'Color', [1, 0.6, 0], 'LineWidth', 2); % Orange line
  title('Real GDP Per Capita - Sri Lanka');
  xlabel('Year');
  ylabel('GDP Per Capita (constant 2015 US$)');
  grid on;

% Plot for Norway GDP
figure;
  plot(years, NOR_GDP, 'Color', [0, 0.45, 0.75], 'LineWidth', 2); % Blue line
  title('Real GDP Per Capita - Norway');
  xlabel('Year');
  ylabel('GDP Per Capita (constant 2015 US$)');
  grid on;

% Combined plot for comparison
figure;
  hold on; % for multiple plots on a same figure
  plot(years, LKA_GDP, 'Color', [1, 0.6, 0], 'LineWidth', 2);
  plot(years, NOR_GDP, 'Color', [0, 0.45, 0.75], 'LineWidth', 2);
  ylim([0, 100000]); % Set y-axis limit for better readability of the legend
  title('Real GDP Per Capita (constant 2015 US$) - Both Countries');
  xlabel('Year');
  ylabel('GDP Per Capita (constant 2015 US$)');
  legend('Sri Lanka', 'Norway');
  grid on;
