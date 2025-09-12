function fun = twoperiodequilibrium_tax(endog, exog, params)
  % Parameters
  alpha = params.alpha;
  rho   = params.rho;
  theta = params.theta;
  tax   = params.tax; % Added tax as parameter, relevant for Task 2

  % Exogenous variables
  A1 = exog.A1; % Productivity in period 1
  A2 = exog.A2; % Productivity in period 2
  k1 = exog.k1; % Capital stock for period 1
  n1 = exog.n1; % Labor in period 1
  n2 = exog.n2; % Labor in period 2

  % Endogenous variables
  y1 = endog(1); % Output in period 1
  y2 = endog(2); % Output in period 2
  c1 = endog(3); % Consumption in period 1
  c2 = endog(4); % Consumption in period 2
  w1 = endog(5); % Wage in period 1
  w2 = endog(6); % Wage in period 2
  r1 = endog(7); % Rental rate of capital in period 1
  r2 = endog(8); % Rental rate of capital in period 2
  k2 = endog(9); % Capital stock for period 2
  g1 = endog(10); % Added public consumption in period 1
  g2 = endog(11); % Added public consumption in period 2


  % Equilibrium equations
  fun = ones(11,1); % adapted dimentions to 11 = number of endogenous variables (outputs)

  % Government spending as stated in Task 2
  fun(1) = g1 - tax * r1 * k1;
  fun(2) = g2 - tax * r2 * k2;

  % Market clearing conditing of goods as stated in Task 2
  %fun(3) = y1 - c1 - g1;
  %fun(4) = y2 - c2 - g2; %unused

  % Consumption budegt restrictions with tax
  fun(5) = c1 + k2 - ( 1 - tax ) * r1 * k1 - w1 * n1 - k1; %Modified to newly derived equation
  fun(6) = c2 - k2 - ( 1 - tax ) * r2 * k2 - w2 * n2; %Modified to newly derived equation

  % Euler equation
  fun(7) = c2 - (( 1 + ( 1 - tax ) * r2 ) / ( 1 + rho )) * c1; %Modified to newly derived Euler equation

  % Untouched equations
  fun(3) = y1 - A1*k1^alpha*n1^(1-alpha);
  fun(4) = y2 - A2*k2^alpha*n2^(1-alpha);
  fun(8) = w1 - (1-alpha)*A1*k1^alpha*n1^(-alpha);
  fun(9) = w2 - (1-alpha)*A2*k2^alpha*n2^(-alpha);
  fun(10) = r1 - alpha*A1*k1^(alpha-1)*n1^(1-alpha);
  fun(11) = r2 - alpha*A2*k2^(alpha-1)*n2^(1-alpha);


end
