    // Original Author: Oliver Holtemoeller //
   //         Ramsey Growth Model          //
  // Deterministic Extended Path Solution //
 //   Edited by Anton Cronet 23.01.2025  //
// Permanent Time Preference Rate Shock //

var k c y i rho_v s; // Added time preference rate (rho_v) and savings rate (s)

varexo epsilon Z; // Set epsilon as exogenous, which changes the relationship between rho_v and rho_p


parameters alpha, delta, theta, a, n, rho_p; // Added rho_p to parameters

// Initial parameter values
alpha = 0.3;
theta = 1;
delta = 0.02;
a = 0.01;
n = 0;
rho_p = 0.01; // Set initial value, parameters can be updated in Octave

model;
  (c(+1) / c) = (((1 + alpha * Z * k^(alpha - 1) - delta) / (1 + rho_v))^(1 / theta)) / (1 + a);
  k = (Z * k(-1)^alpha + (1 - delta) * k(-1) - c) / (1 + n) / (1 + a);
  y = Z * k(-1)^alpha;
  i = y - c;
  s = i / y;                // Savings rate as the ratio of investment to output
  rho_v = epsilon * rho_p; // Equation required here to satisfy 6 equations for 6 variables
end;
               // Sidenote: It all makes sense now why have rho_p in parameters, rho_v in
              // endogenous, and epsilon as a link between them which can easily change value
initval;
  k = 10;
  c = 2;
  y = 5;
  i = 1;
  epsilon = 1;  // Initial value for rho_v = rho_p
  Z = 1;
end;

steady;

endval;
  epsilon = 1;  // After the shock, rho_v = 2 * rho_p
end;

steady;

perfect_foresight_setup(periods=300);
perfect_foresight_solver;

send_endogenous_variables_to_workspace;
