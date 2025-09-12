% --- Clear environment ---
clear;

%% --- Importing Data ---
% --- File paths ---
file1 = 'estat_prc_hicp_midx_filtered_en.csv';
file2 = 'estat_prc_hicp_midx_filtered_en_energy.csv';
file3 = 'estat_sts_inpr_m_filtered_en.csv';
file4 = 'estat_une_rt_m_filtered_en.csv';
file5 = 'carbonPolicyShocks.xlsx';

% --- Read CSVs as cell arrays ---
hicp = readcell(file1);
hicp_energy = readcell(file2);
industrial_prod = readcell(file3);
unemployment = readcell(file4);
carbon_data = readcell(file5, 'Sheet', 2);

% --- Extract time and value columns ---
hicp_time_str = strrep(string(hicp(2:end, 7)), '-', '');
hicp_val_num = cell2mat(hicp(2:end, 8));

hicp_energy_time_str = strrep(string(hicp_energy(2:end, 7)), '-', '');
hicp_energy_val_num = cell2mat(hicp_energy(2:end, 8));

industrial_time_str = strrep(string(industrial_prod(2:end, 9)), '-', '');
industrial_val_num = cell2mat(industrial_prod(2:end, 10));

unemployment_time_str = strrep(string(unemployment(2:end, 9)), '-', '');
unemployment_val_num = cell2mat(unemployment(2:end, 10));

%% -- Processing Carbon Data ---
% --- Extract columns ---
raw_dates = carbon_data(2:end, 1);      % Format: YYYY"M"MM
raw_surprise = carbon_data(2:end, 2);   % Monthly carbon policy surprises
raw_shock = carbon_data(2:end, 3);      % Carbon policy shock

% --- Convert dates to string format YYYYMM ---
carbon_dates_str = replace(string(raw_dates), 'M', '');  % remove the "M"
carbon_surprise = cell2mat(raw_surprise);
carbon_shock = cell2mat(raw_shock);

%% --- Align and Merge ---
% --- Common time merging common dates between all time series ---
common_time = intersect(intersect(intersect(intersect( ...
              hicp_time_str, ...
              hicp_energy_time_str), ...
              industrial_time_str), ...
              unemployment_time_str), ...
              carbon_dates_str);

% --- Index each dataset by common time ---
[~, idx_hicp] = ismember(common_time, hicp_time_str);
[~, idx_energy] = ismember(common_time, hicp_energy_time_str);
[~, idx_industrial] = ismember(common_time, industrial_time_str);
[~, idx_unemp] = ismember(common_time, unemployment_time_str);
[~, idx_carbon] = ismember(common_time, carbon_dates_str);

% --- Align series ---
hicp_vals = hicp_val_num(idx_hicp);
hicp_energy_vals = hicp_energy_val_num(idx_energy);
industrial_vals = industrial_val_num(idx_industrial);
unemp_vals = unemployment_val_num(idx_unemp);
carbon_surprise_vals = carbon_surprise(idx_carbon);
carbon_shock_vals = carbon_shock(idx_carbon);

%% --- Part 1: ---
% Log transform relevant variables (level data only) 

log_hicp = log(hicp_vals);
log_hicp_energy = log(hicp_energy_vals);
log_industrial = log(industrial_vals);
% Unemployment rate is already in percent, no need to log
% Surprise and shock are already "shocks", so not logged

% --- Create final data matrix ---
Y = [log_hicp, log_hicp_energy, log_industrial, unemp_vals, carbon_surprise_vals, carbon_shock_vals];


%% --- Part 2 --- 
% ADF test for stationarity

% Test each variable in levels
[h_hicp, p_hicp] = adftest(log_hicp);
[h_energy, p_energy] = adftest(log_hicp_energy);
[h_industrial, p_industrial] = adftest(log_industrial);
[h_unemp, p_unemp] = adftest(unemp_vals);
[h_surprise, p_surprise] = adftest(carbon_surprise_vals);
[h_shock, p_shock] = adftest(carbon_shock_vals);


% Difference non-stationary series once
if ~h_hicp, log_hicp = diff(log_hicp); end % H = 0: Non Stationary
if ~h_energy, log_hicp_energy = diff(log_hicp_energy); end % H = 0: Non Stationary
if ~h_industrial, log_industrial = diff(log_industrial); end % H = 0: Non Stationary
if ~h_unemp, unemp_vals = diff(unemp_vals); end % H = 0: Non Stationary
if ~h_surprise, carbon_surprise_vals = diff(carbon_surprise_vals); end % H = 1: Stationary
if ~h_shock, carbon_shock_vals = diff(carbon_shock_vals); end % H = 1: Stationary

% Adjust common_time if any differencing occurred
if any(~[h_hicp, h_energy, h_industrial, h_unemp, h_surprise, h_shock])
    common_time = common_time(2:end);
end

% Find minimum length after differencing
minLen = min([length(log_hicp), length(log_hicp_energy), length(log_industrial), ...
              length(unemp_vals), length(carbon_surprise_vals), length(carbon_shock_vals)]);

% Align all series to minimum length and concatenate
Y_final = [ ...
    log_hicp(1:minLen), ...
    log_hicp_energy(1:minLen), ...
    log_industrial(1:minLen), ...
    unemp_vals(1:minLen), ...
    carbon_surprise_vals(1:minLen), ...
    carbon_shock_vals(1:minLen) ...
];


%% --- Part 3 ---
% --- Estimate a VAR on a mix of differenced (non-stationary) and level (stationary) data with an intercept, no trend.

% --- Initial VAR order ---
p = 1;

% --- Create lagged matrix ---
T = size(Y_final,1);
X = [];
for i = 1:p
    X = [X, Y_final(p+1-i:end-i, :)];
end

% Add intercept term
X = [ones(T-p,1), X];

% Dependent variable matrix
Y_dep = Y_final(p+1:end, :);

% --- Estimate VAR by OLS ---
Beta = (X' * X) \ (X' * Y_dep);  

% --- Residuals ---
% U = Y_dep - X * Beta; % Unused but kep for later reference  

% --- Display estimated coefficients ---
var_names = {'log_HICP', 'log_Energy', 'log_IndProd', 'UnempRate', 'Surprise', 'Shock'};
disp('Estimated VAR coefficients (including intercept):') 
disp(array2table(Beta, 'VariableNames', var_names, 'RowNames', ...
    ['Intercept', compose("L%d_", 1:p) + repmat(var_names, 1, p)]))


%% --- Part 4 ---
% Finding appropriate length for the model

maxLag = 15; % max lag to check, more not needed for monthly data
T = size(Y_final, 1);
nVars = size(Y_final, 2);

aic = zeros(maxLag, 1);
bic = zeros(maxLag, 1);

for p = 1:maxLag
    X = [];
    for i = 1:p
        X = [X, Y_final(p + 1 - i:end - i, :)];
    end
    X = [ones(T - p, 1), X];
    Y_dep = Y_final(p + 1:end, :);
    
    Beta = (X' * X) \ (X' * Y_dep);
    U = Y_dep - X * Beta;
    sigma = (U' * U) / (T - p);
    
    % Number of parameters
    k = nVars * p + 1; % intercept + lagged terms
    
    % Log-likelihood (up to constant)
    logL = - (T - p)*nVars / 2 * (1 + log(2 * pi)) - (T - p) / 2 * log(det(sigma));
    
    % Calculate criteria
    aic(p) = -2 * logL / (T - p) + 2 * k / (T - p);
    bic(p) = -2 * logL / (T - p) + log(T - p) * k / (T - p);
end 

% Display results
table((1:maxLag)', aic, bic, 'VariableNames', {'Lag', 'AIC', 'BIC'})

% After lag 6 there are less marginal improvements in the metrics
% Refit with lag 6

p = 6;

T = size(Y_final, 1);
X = [];
for i = 1:p
    X = [X, Y_final(p + 1 - i:end - i, :)];
end
X = [ones(T - p, 1), X];
Y_dep = Y_final(p + 1:end, :);

Beta = (X' * X) \ (X' * Y_dep);
U = Y_dep - X * Beta;

var_names = {'diff_log_HICP', 'diff_log_Energy', 'diff_log_IndProd', 'diff_UnempRate', 'Surprise', 'Shock'};

% Create row names for table
rowNames = ["Intercept"];
for lag = 1:p
    for v = 1:length(var_names)
        rowNames(end+1) = sprintf("L%d_%s", lag, var_names{v});
    end
end

% disp('Estimated VAR coefficients (including intercept):') % Not needed in final output
% disp(array2table(B, 'VariableNames', var_names, 'RowNames', rowNames)) % Not needed in final output


%% --- Part 5 ---
% Ljung-Box test for autocorrelation to see if the model should be expanded

% Number of lags to test for autocorrelation
acf_lags = 12; % Seems like a good fit for monthly data, wehre 12 lags cover a year

% Preallocate
ljungBox_pvals = zeros(size(U, 2), 1);

% Test each variable's residuals
for i = 1:size(U, 2)
    [~, pval] = lbqtest(U(:, i), 'Lags', acf_lags);
    ljungBox_pvals(i) = pval;
end

% Display results
disp('Ljung-Box test p-values for residual autocorrelation:')
disp(table(var_names', ljungBox_pvals, 'VariableNames', {'Variable', 'pValue'}))
fprintf('VAR model lag order used: %d\n', p);
% p-value < 0.05, reject the null of no autocorrelation, residuals are autocorrelated.


% changing order number until there is no autocorrelation left
p = 9; % at 9 lags all p-val of the Ljung-Box test are > 0.05

T = size(Y_final, 1);
X = [];
for i = 1:p
    X = [X, Y_final(p + 1 - i:end - i, :)];
end
X = [ones(T - p, 1), X];
Y_dep = Y_final(p + 1:end, :);

Beta = (X' * X) \ (X' * Y_dep);
U = Y_dep - X * Beta;

var_names = {'diff_log_HICP', 'diff_log_Energy', 'diff_log_IndProd', 'diff_UnempRate', 'Surprise', 'Shock'};

% Create row names for table
rowNames = ["Intercept"];
for lag = 1:p
    for v = 1:length(var_names)
        rowNames(end + 1) = sprintf("L%d_%s", lag, var_names{v});
    end
end


% Number of lags to test for autocorrelation
acf_lags = 12;

% Preallocate
ljungBox_pvals = zeros(size(U, 2), 1);

% Test each variable's residuals
for i = 1:size(U, 2)
    [~, pval] = lbqtest(U(:, i), 'Lags', acf_lags);
    ljungBox_pvals(i) = pval;
end

% Display results
disp('Ljung-Box test p-values for residual autocorrelation:')
disp(table(var_names', ljungBox_pvals, 'VariableNames', {'Variable', 'pValue'}))
fprintf('VAR model lag order used: %d\n', p);
% p-value < 0.05, reject the null of no autocorrelation, residuals are autocorrelated.


%% --- Part 6 ---
% Ordering
current_vars = {
    'diff_log_HICP', ...
    'diff_log_Energy', ...
    'diff_log_IndProd', ...
    'diff_UnempRate', ...
    'Surprise', ...
    'Shock'
};

ordered_vars = {
    'Surprise', ...           % Policy/external surprises
    'Shock', ...              % Carbon price shocks
    'diff_log_Energy', ...    % Energy price
    'diff_log_IndProd', ...   % Industrial economic activity
    'diff_log_HICP'  ...      % Price level 
    'diff_UnempRate',  ...    % Labor market response
};

[~, reorder_idx] = ismember(ordered_vars, current_vars); % Find the reordering indices

Y_final = Y_final(:, reorder_idx); % Needed for the rest of the analysis

% --- Cholesky decomposition (SVAR) ---
% - Step 1: Residual covariance matrix from reduced-form VAR - 
U_ordered = U(:, reorder_idx); % reorder previous U with new index order
Sigma_u = cov(U_ordered);  % (6x6)

% - Step 2: Cholesky factor (lower triangular matrix) -
B_chol = chol(Sigma_u, 'lower');  % B_chol * B_chol' = Sigma_u
                                  % Double checked varaible: indeed lower triangular

% - Step 3: Structural shocks (orthogonalized residuals) -

  % Method 1: 
% B_inv = inv(B_chol);                   % Compute inverse explicitly
% eps_struct = (B_inv * U_ordered')';    % Apply inverse, then transpose back
% Note: This gives a matlab error that the order of calculation aren't optimal


  % Method 2 (efficient MATLAB - left division):
struct_shocks = (B_chol \ U_ordered')';  % B_chol \ U' computes B_chol^(-1) * U'
                                         % Then transpose to get (T x n) format
                                         % More matlab friendly notation
                                         % Issue debugged with chatGPT

% Check to see math worked out: Display first few structural shocks
shock_names = {
  'Surprise', ...         
  'Shock', ...           
  'Energy', ... 
  'IndProd', ...
  'HICP', ...   
  'UnempRate'    
};
disp('First 5 observations of identified structural shocks:')
disp(array2table(struct_shocks(1:5, :), 'VariableNames', shock_names))
disp('Successful Cholesky Decomposition')


%% --- Part 7 --- 
% IRFs with 68 and 90% confidence bands

% --- Parameters ---
H = 20; % IRF horizon
nVars = size(U, 2);
p = 9; % as defined in the earlier model

% Extract coefficient matrices from Beta more carefully
A = zeros(nVars, nVars, p); % autoregressive coefficient matrice: nVars × nVars × p
for lag = 1:p
    start_row = 2 + (lag - 1) * nVars ;  % Skip intercept (row 1)
    end_row = 1 + lag * nVars;
    A(:, :, lag) = Beta(start_row:end_row, :)';
    % Debug help
     fprintf('Lag %d: extracting rows %d to %d from Beta\n', lag, start_row, end_row); 
end

% --- IRF Calculation (Two-Step Process) ---
% Step 1: Calculate reduced-form IRFs (Phi_h matrices from course)
IRF_reduced = zeros(nVars, nVars, H + 1);
IRF_reduced(:, :, 1) = eye(nVars);  % Identity at impact time

% Periods 1 to H: Recursive calculation for reduced-form responses
for h = 1:H
    IRF_reduced(:, :, h + 1) = zeros(nVars, nVars);
    
    % Sum over all relevant lags
    for lag = 1:min(h, p)  % Can't go back further than h periods or p lags
        IRF_reduced(:, :, h + 1) = IRF_reduced(:, :, h + 1) + ...
            A(:, :, lag) * IRF_reduced(:, :, h + 1 - lag);
    end
end

% Step 2: Apply structural identification (multiply by Cholesky factor)
IRF = zeros(size(IRF_reduced));
for h = 1:H+1
    IRF(:, :, h) = IRF_reduced(:, :, h) * B_chol;
    %Transform reduced-form to structural: Structural IRF = Theta × B
end

% --- Bootstrap ---
nBoot = 500;
IRF_boot = zeros(nBoot, nVars, nVars, H + 1);

for b = 1:nBoot
    % Resample residuals
    U_boot = U_ordered(randi(size(U_ordered, 1), size(U_ordered, 1), 1), :);
    
    % Generate bootstrap data 
    Y_boot = zeros(size(Y_final));
    Y_boot(1:p, :) = Y_final(1:p, :);
    
    for t = p + 1:size(Y_final, 1)
        Y_stack = [];
        % Calculate stack and append to bottom
        for lag = 1:p
            Y_stack = [Y_stack, Y_boot(t - lag, :)];
        end
        Y_boot(t, :) = [1, Y_stack] * Beta + U_boot(t - p, :);
    end
    
    % Re-estimate VAR
    Xb = [];
    for lag = 1:p
        Xb = [Xb, Y_boot(p + 1 - lag:end - lag, :)];
    end
    Xb = [ones(size(Y_boot, 1) - p, 1), Xb];
    Yb_dep = Y_boot(p + 1:end, :);
    
    Bb = (Xb' * Xb) \ (Xb' * Yb_dep);
    Ub = Yb_dep - Xb * Bb;
    Sigma_ub = cov(Ub);
    B_chol_b = chol(Sigma_ub, 'lower');
    
    % Extract bootstrap coefficient matrices
    A_b = zeros(nVars, nVars, p);
    for lag = 1:p
        A_b(:,:,lag) = Bb(2 + (lag - 1) * nVars : 1 + lag * nVars, :)';
    end
    
    % Compute bootstrap IRF 
    % Step 1: Reduced-form IRFs
    IRF_reduced_b = zeros(nVars, nVars, H + 1);
    IRF_reduced_b(:, :, 1) = eye(nVars); % Identity matrix at impact time
    
    for h = 1:H
        IRF_reduced_b(:, :, h + 1) = zeros(nVars, nVars);
        for lag = 1:min(h, p)
            IRF_reduced_b(:, :, h + 1) = IRF_reduced_b(:, :, h + 1) + ...
                A_b(:, :, lag) * IRF_reduced_b(:, :, h + 1 - lag);
        end
    end
    
    % Step 2: Apply structural identification
    IRF_b = zeros(size(IRF_reduced_b));
    for h = 1:H+1
        IRF_b(:, :, h) = IRF_reduced_b(:, :, h) * B_chol_b;
        % Same two-step process for bootstrap samples
    end
    
    IRF_boot(b, :, :, :) = IRF_b;
end

% Confidence bands 
alpha_vals = [0.16, 0.05];  % For 68% and 90% confidence: 2 sided
lower90 = squeeze(quantile(IRF_boot, alpha_vals(2), 1));
upper90 = squeeze(quantile(IRF_boot, 1 - alpha_vals(2), 1));
lower68 = squeeze(quantile(IRF_boot, alpha_vals(1), 1));
upper68 = squeeze(quantile(IRF_boot, 1 - alpha_vals(1), 1));

% --- Plot IRFs with confidence bands ---
figure(1);
shock_names = {
  'Surprise', ...         
  'Shock', ...           
  'Energy', ... 
  'IndProd', ...
  'HICP', ...   
  'UnempRate'    
};
time = 0:H;

% Color definitions
color1 = [1, 0.5, 0]; % Orange for main line -> visibility        
color2 = [0.8, 0.8, 0.8];  % Light grey for 68% confidence bands
color3 = [0.7, 0.7, 0.7];  % Dark grey for 90% confidence bands


for i = 1:nVars
    for j = 1:nVars
        subplot(nVars, nVars, (i - 1) * nVars + j)

        % Extract vectors
        mainIRF = squeeze(IRF(i, j, :));
        l68 = squeeze(lower68(i, j, :));
        u68 = squeeze(upper68(i, j, :));
        l90 = squeeze(lower90(i, j, :));
        u90 = squeeze(upper90(i, j, :));

        % 90% confidence ribbon 
        fill([time, fliplr(time)], [l90', fliplr(u90')], color3, ...
            'EdgeColor', 'none', 'FaceAlpha', 0.3); hold on;

        % 68% confidence ribbon 
        fill([time, fliplr(time)], [l68', fliplr(u68')], color2, ...
            'EdgeColor', 'none', 'FaceAlpha', 0.5);

        % Main IRF line (on top)
        plot(time, mainIRF, 'Color', color1, 'LineWidth', 1.5);

        title([shock_names{j}, ' → ', shock_names{i}])
        xlabel('Horizon')
        ylabel('Response')
        grid on
    end
end

% Add overall title
sgtitle('Structural IRFs with 68% and 90% Confidence Bands', 'FontSize', 14);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% --- Part 8: Robustness Checks --- %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% --- Linear Trend Robustness Check ---

% Create time trend variable
T_trend = size(Y_final, 1);
trend = (1:T_trend)';

% Rebuild the VAR model with linear trend
X_trend = [];
for i = 1:p
    X_trend = [X_trend, Y_final(p + 1 - i:end - i, :)]; % at this point Y_final is ordered properly
end
% Add intercept AND linear trend
X_trend = [ones(T_trend - p, 1), trend(p + 1:end), X_trend];
Y_dep_trend = Y_final(p + 1:end, :);

% Estimate VAR with trend
Beta_trend = (X_trend' * X_trend) \ (X_trend' * Y_dep_trend);
U_trend = Y_dep_trend - X_trend * Beta_trend;

% Reorder residuals for Cholesky decomposition
% U_trend_ordered = U_trend(:, reorder_idx);
% Reordering is done to Yfinal beforehand

% --- Structural identification with trend model ---
Sigma_u_trend = cov(U_trend); % non re-reordered twice
B_chol_trend = chol(Sigma_u_trend, 'lower');

% Extract coefficient matrices from Beta_trend (skip intercept AND trend)
A_trend = zeros(nVars, nVars, p);
for lag = 1:p
    start_row = 2 + (lag - 1) * nVars + 1;  % +2 Skips intercept (row 1) AND trend (row 2); +1 for indexing
    end_row = 2 + lag * nVars;          % Correct end row calculation
    A_trend(:, :, lag) = Beta_trend(start_row:end_row, :)';
end

% --- IRF Calculation for trend model ---
IRF_reduced_trend = zeros(nVars, nVars, H + 1);
IRF_reduced_trend(:, :, 1) = eye(nVars);

for h = 1:H
    IRF_reduced_trend(:, :, h + 1) = zeros(nVars, nVars);
    for lag = 1:min(h, p)
        IRF_reduced_trend(:, :, h + 1) = IRF_reduced_trend(:, :, h + 1) + ...
            A_trend(:, :, lag) * IRF_reduced_trend(:, :, h + 1 - lag);
    end
end

% Apply structural identification
IRF_trend = zeros(size(IRF_reduced_trend));
for h = 1:H+1
    IRF_trend(:, :, h) = IRF_reduced_trend(:, :, h) * B_chol_trend;
end

% --- Plot comparison: Original vs Trend model ---
figure(2);
% Color definitions
color1 = [1, 0.5, 0]; % Orange for original model
color_trend = [0, 0.4, 0.8]; % Blue for trend model

for i = 1:nVars
    for j = 1:nVars
        subplot(nVars, nVars, (i - 1) * nVars + j)
        % Extract IRF vectors
        mainIRF = squeeze(IRF(i, j, :));
        mainIRF_trend = squeeze(IRF_trend(i, j, :));
        % Plot both models
        plot(time, mainIRF, 'Color', color1, 'LineWidth', 1.5); hold on;
        plot(time, mainIRF_trend, 'Color', color_trend, 'LineWidth', 1.5);
        title([shock_names{j}, ' → ', shock_names{i}])
        xlabel('Horizon')
        ylabel('Response')
        grid on
    end
end

% Create figure-wide legend in bottom right
% Create invisible lines for legend
h1 = plot(NaN, NaN, 'Color', color1, 'LineWidth', 1.5);
h2 = plot(NaN, NaN, 'Color', color_trend, 'LineWidth', 1.5);

% Position legend at bottom right of entire figure
legend([h1, h2], {'Original Model', 'With Linear Trend'}, ...
    'Position', [0.75, 0.01, 0.2, 0.1], 'FontSize', 9);

% Add overall title
sgtitle('Robustness Check: Original Model vs Model with Linear Trend', 'FontSize', 14);

% Test for residual autocorrelation in trend model
fprintf('\n--- Ljung-Box Test Results for Trend Model ---\n');
ljungBox_pvals_trend = zeros(size(U_trend, 2), 1);
for i = 1:size(U_trend, 2)
    [~, pval] = lbqtest(U_trend(:, i), 'Lags', acf_lags);
    ljungBox_pvals_trend(i) = pval;
end

comparison_table = table(var_names', ljungBox_pvals, ljungBox_pvals_trend, ...
    'VariableNames', {'Variable', 'Original_pValue', 'Trend_pValue'});
disp(comparison_table);



%% --- 2. Lag Length Robustness Check (FIXED - No Trend) ---
lag_lengths = [6, 12, 24];
IRF_lag_robust = cell(length(lag_lengths), 1);
fprintf('\n=== LAG LENGTH ROBUSTNESS CHECK ===\n');

for lag_idx = 1:length(lag_lengths)
    p_robust = lag_lengths(lag_idx);
    fprintf('Estimating VAR with %d lags...\n', p_robust);
    
    % Build design matrix without trend (same as original model)
    X_robust = [];
    for i = 1:p_robust
        X_robust = [X_robust, Y_final(p_robust + 1 - i:end - i, :)];
    end
    X_robust = [ones(size(Y_final, 1) - p_robust, 1), X_robust]; % Only intercept
    Y_dep_robust = Y_final(p_robust + 1:end, :);
    
    % Estimate VAR
    Beta_robust = (X_robust' * X_robust) \ (X_robust' * Y_dep_robust);
    U_robust = Y_dep_robust - X_robust * Beta_robust;
    
    % Structural identification (no reordering needed - Y_final already ordered)
    Sigma_u_robust = cov(U_robust);
    B_chol_robust = chol(Sigma_u_robust, 'lower');
    
    % Extract coefficient matrices (skip only intercept, not trend)
    A_robust = zeros(nVars, nVars, p_robust);
    for lag = 1:p_robust
        start_row = 2 + (lag - 1) * nVars;  % Skip intercept only
        end_row = 1 + lag * nVars;          % Standard calculation
        A_robust(:, :, lag) = Beta_robust(start_row:end_row, :)';
    end
    
    % Calculate IRFs
    IRF_reduced_robust = zeros(nVars, nVars, H + 1);
    IRF_reduced_robust(:, :, 1) = eye(nVars);
    
    for h = 1:H
        IRF_reduced_robust(:, :, h + 1) = zeros(nVars, nVars);
        for lag = 1:min(h, p_robust)
            IRF_reduced_robust(:, :, h + 1) = IRF_reduced_robust(:, :, h + 1) + ...
                A_robust(:, :, lag) * IRF_reduced_robust(:, :, h + 1 - lag);
        end
    end
    
    % Apply structural identification
    IRF_robust = zeros(size(IRF_reduced_robust));
    for h = 1:H+1
        IRF_robust(:, :, h) = IRF_reduced_robust(:, :, h) * B_chol_robust;
    end
    
    % Store results (no reordering back needed - already in desired order)
    IRF_lag_robust{lag_idx} = IRF_robust;
end

% Plot comparison across lag lengths
figure(3);
colors = {[1, 0.5, 0], [0, 0.4, 0.8], [0.8, 0.2, 0.6], [0.2, 0.6, 0.2]}; % Orange, Blue, Purple, Green

for i = 1:nVars
    for j = 1:nVars
        subplot(nVars, nVars, (i - 1) * nVars + j)
        
        % Plot original model (p=9)
        mainIRF_original = squeeze(IRF(i, j, :));
        plot(time, mainIRF_original, 'Color', colors{1}, 'LineWidth', 1.5); hold on;
        
        % Plot different lag lengths
        for lag_idx = 1:length(lag_lengths)
            mainIRF_robust = squeeze(IRF_lag_robust{lag_idx}(i, j, :));
            plot(time, mainIRF_robust, 'Color', colors{lag_idx + 1}, 'LineWidth', 1.2);
        end
        
        title([shock_names{j}, ' → ', shock_names{i}])
        xlabel('Horizon')
        ylabel('Response')
        grid on
    end
end

% Create legend
legend_labels = {'Original (p=9)', 'p=6', 'p=12', 'p=24'};
h_legend = zeros(length(legend_labels), 1);
for i = 1:length(legend_labels)
    h_legend(i) = plot(NaN, NaN, 'Color', colors{i}, 'LineWidth', 1.5);
end

legend(h_legend, legend_labels, 'Position', [0.75, 0.01, 0.2, 0.15], 'FontSize', 9);
sgtitle('Lag Length Robustness Check: IRF Comparison', 'FontSize', 14);

%% --- 3. Variable Ordering Robustness Check (FIXED - No Trend) ---
orderings = {
    [1, 2, 3, 4, 5, 6], ... % Original: Surprise, Shock, Energy, IndProd, HICP, Unemp
    [2, 1, 6, 5, 4, 3], ... % Alternative 1: Shock, Surprise, Unemp, HICP, IndProd, Energy
    [5, 6, 4, 3, 1, 2]      % Alternative 2: HICP, Unemp, IndProd, Energy, Surprise, Shock
};
ordering_names = {
    'Original: Surprise, Shock, Energy, IndProd, HICP, Unemp';
    'Alt 1: Shock, Surprise, Unemp, HICP, IndProd, Energy';
    'Alt 2: HICP, Unemp, IndProd, Energy, Surprise, Shock'
};
IRF_order_robust = cell(length(orderings), 1);
fprintf('\n=== VARIABLE ORDERING ROBUSTNESS CHECK ===\n');

for order_idx = 1:length(orderings)
    current_order = orderings{order_idx};
    fprintf('Estimating with ordering: %s\n', ordering_names{order_idx});
    
    % For the first ordering (original), use the existing original IRF results
    if order_idx == 1
        IRF_order_robust{order_idx} = IRF;
        continue;
    end
    
    % Build design matrix without trend (consistent with original model)
    X_order = [];
    for i = 1:p
        X_order = [X_order, Y_final(p + 1 - i:end - i, :)];
    end
    X_order = [ones(size(Y_final, 1) - p, 1), X_order]; % Only intercept
    Y_dep_order = Y_final(p + 1:end, :);
    
    % Estimate VAR
    Beta_order = (X_order' * X_order) \ (X_order' * Y_dep_order);
    U_order = Y_dep_order - X_order * Beta_order;
    
    % Reorder residuals according to current ordering
    U_order_reordered = U_order(:, current_order);
    
    % Structural identification
    Sigma_u_order = cov(U_order_reordered);
    B_chol_order = chol(Sigma_u_order, 'lower');
    
    % Extract coefficient matrices (skip only intercept, no trend in model)
    A_order = zeros(nVars, nVars, p);
    for lag = 1:p
        start_row = 2 + (lag - 1) * nVars;  % Skip intercept only
        end_row = 1 + lag * nVars;          % Standard calculation
        A_order(:, :, lag) = Beta_order(start_row:end_row, :)';
    end
    
    % Calculate IRFs
    IRF_reduced_order = zeros(nVars, nVars, H + 1);
    IRF_reduced_order(:, :, 1) = eye(nVars);
    for h = 1:H
        IRF_reduced_order(:, :, h + 1) = zeros(nVars, nVars);
        for lag = 1:min(h, p)
            IRF_reduced_order(:, :, h + 1) = IRF_reduced_order(:, :, h + 1) + ...
                A_order(:, :, lag) * IRF_reduced_order(:, :, h + 1 - lag);
        end
    end
    
    % Apply structural identification
    IRF_order_reordered = zeros(size(IRF_reduced_order));
    for h = 1:H+1
        IRF_order_reordered(:, :, h) = IRF_reduced_order(:, :, h) * B_chol_order;
    end
    
    % Reorder back to original variable positions for comparison
    [~, inverse_order] = sort(current_order);
    IRF_order_robust{order_idx} = zeros(size(IRF_order_reordered));
    for h = 1:H+1
        IRF_order_robust{order_idx}(:, :, h) = IRF_order_reordered(inverse_order, inverse_order, h);
    end
end

%% --- Plot Variable Ordering Robustness ---
figure(5);
colors_order = {[1, 0.5, 0], [0, 0.4, 0.8], [0.8, 0.2, 0.6]};

for i = 1:nVars
    for j = 1:nVars
        subplot(nVars, nVars, (i - 1) * nVars + j)
        % Plot different orderings
        for order_idx = 1:length(orderings)
            mainIRF_order = squeeze(IRF_order_robust{order_idx}(i, j, :));
            plot(time, mainIRF_order, 'Color', colors_order{order_idx}, 'LineWidth', 1.5); hold on;
        end
        title([shock_names{j}, ' → ', shock_names{i}])
        xlabel('Horizon')
        ylabel('Response')
        grid on
    end
end

% Create figure-wide legend in bottom right
% Create invisible lines for legend
h_order = [];
for order_idx = 1:length(orderings)
    h_order(order_idx) = plot(NaN, NaN, 'Color', colors_order{order_idx}, 'LineWidth', 1.5);
end

% Position legend at bottom right of entire figure
leg = legend(h_order, ordering_names, ...
    'Position', [0.72, 0.01, 0.25, 0.1], 'FontSize', 9);

% Optional: Add a box around the legend
leg.Box = 'on';

sgtitle('Variable Ordering Robustness Check', 'FontSize', 14);