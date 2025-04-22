library("readr")
library("readxl")
library("forecast")
library("stats")
library("Hmisc")
library("dplyr")
library("lubridate")
library("ggplot2")


############################################################
se_short <- read.csv("Swestr_2024-04-10_18_07.csv", header = FALSE, sep = ";", quote = "\"")

# Remove rows with indices 89, 342, and 593
indices_to_remove_2 <- c(89, 342, 593)
se_short <- se_short[-indices_to_remove_2, ]



col_names <- as.character(se_short[3, ])

# Remove the first three rows
se_short <- se_short[-c(1:3), ]

# Assign the extracted row as column names
colnames(se_short) <- col_names
names(se_short)[1] <- "Date"

row.names(se_short) <- NULL
# get time series. Remove last obs, not included in eu_str
ts_se_str <- as.numeric(
  gsub(
    ",", ".",
    se_short$`Swestr (%)`[1:(nrow(se_short)-1)] 
  )
)

length(ts_se_str)
plot(ts_se_str)

se_short$Date <- ymd(se_short$Date)

############################################################
eu_short <- read_csv("ECB_Data_Portal_20240402140404.csv")

eu_short_retrim <- eu_short[eu_short$DATE %in% se_short$Date,]

class(se_short$Date)

ts_eu_str <- eu_short_retrim$`Euro short-term rate - Volume-weighted trimmed mean rate (EST.B.EU000A2X2A25.WT)`

length(ts_eu_str)

############################################################
eu_styr <- read_csv("ECB_Data_Portal_20240410182357.csv")
eu_styr_trim <- eu_styr[7579:nrow(eu_styr), ]
eu_styr_trim_retrim <- eu_styr_trim[eu_styr_trim$DATE %in% eu_short$DATE,]


ts_eu <- eu_styr_trim_retrim$`Deposit facility - date of changes (raw data) - Level (FM.D.U2.EUR.4F.KR.DFR.LEV)`
length(ts_eu)


############################################################
se_styr <- read_excel("styrrantan-effektiv.xlsx")
se_styr_trim <- se_styr[97:nrow(se_styr), ]


rate_changes <- data.frame(
  date = as.Date(se_styr_trim$...1),
  rate = se_styr_trim$`Styrräntan per förändring (effektiv)`
)

start_date <- as.Date("2021-09-01")
end_date <- as.Date("2024-03-28")

all_dates <- seq(start_date, end_date, by = "day")

interest_rates <- numeric(length(all_dates))

current_rate <- rate_changes$rate[1]

for (i in seq_along(all_dates)) {
  if (i > which.max(rate_changes$date >= all_dates[i])) {
    current_rate <- rate_changes$rate[which.max(rate_changes$date >= all_dates[i])]
  }
  
  interest_rates[i] <- current_rate
}
se_styr_trim_expand <- data.frame(date = all_dates, rate = interest_rates)


se_styr_trim_expand_retrim <- se_styr_trim_expand[se_styr_trim_expand$date %in% se_short$Date , ]


row.names(se_styr_trim_expand_retrim) <- NULL
se_styr_trim_expand_retrim$row_number[4]


ts_se <- se_styr_trim_expand_retrim$rate

length(ts_se)
plot(ts_se)
############################################################
ts_se_vol <- as.numeric(
  gsub(
    ",", ".",
    se_short$`Volym (MSEK)`
  )
)
length(ts_se_vol)
ts_se_vol[354] <- 65000


############################################################



#lag the interest rates
ts_eu_lag <- Lag(ts_eu, shift = 1)
ts_eu_str_lag <- Lag(ts_eu_str, shift = 1)
ts_se_lag <- Lag(ts_se, shift = 1)
ts_se_vol_lag <- Lag(ts_se_vol, shift = 1)

########## Swestr - Styr ########## 

plot(ts_se)
plot(ts_se_str)
se_spread <- ts_se_str - ts_se
plot(se_spread)
adf.test(se_spread)

## Eu spread ##
eu_spread <- ts_eu_str - ts_eu
plot(eu_spread)

arima <- auto.arima(eu_spread) # ARIMA(1,1,2)
summary(arima)
residuals <- arima$residuals

#Diagnostics for arima:
plot(residuals)
acf(residuals)
pacf(residuals)
Box.test(residuals, type = "Ljung-Box") # H0: Data is independently distributed


#more lagged variables as regressors:



############## determining p, d, q manually:

#### Model 1:  (0, 1, 0)
plot(ts_se_str)

library(tseries)
adf.test(ts_se_str) # => integrate

acf(ts_se_str)
pacf(ts_se_str) # => AR(1)

order <- c(0, 1, 0) 
  
arima <- arima(ts_se_str, order = order)
summary(arima)

residuals <- arima$residuals
adf.test(residuals) # => stationary

acf(residuals) # => perfect
pacf(residuals) # => perfect

# Adding integrated-lagged Regressors


ts_se_str_diff <- diff(ts_se_str)
ts_se_lag_diff <- diff(ts_se_lag)
ts_eu_str_se_lag_diff <- diff(ts_eu_str_se_lag)

plot(ts_se_str)
plot(ts_se_lag)

xreg <- cbind(ts_se_lag_diff, ts_eu_str_se_lag_diff)

order <- c(0, 0, 0) #se_str is integrated manually
arima <- arima(ts_se_str_diff, order = order, xreg = xreg)
summary(arima)

residuals <- arima$residuals
adf.test(residuals[2:length(residuals)]) # Stationary

acf(residuals[2:length(residuals)]) 
pacf(residuals[2:length(residuals)]) 

#irrelevant
order <- c(0, 0, 1)

arima <- arima(ts_se_str_diff, order = order, xreg = xreg)
summary(arima)

residuals <- arima$residuals

adf.test(residuals[2:length(residuals)]) # Stationary
acf(residuals[2:length(residuals)]) # => perfect
pacf(residuals[2:length(residuals)]) # => perfect



#### Model 2: (assume the regressors *cause* the jumps in the data (reason why integration is not needed))


order <- c(0, 0, 0)
xreg <- cbind(ts_se_lag, ts_eu_str_lag)

arima <- arima(ts_se_str, order = order, xreg = xreg)
summary(arima)

residuals <- arima$residuals
adf.test(residuals[2:length(residuals)]) # Stationary

acf(residuals[2:length(residuals)]) 
pacf(residuals[2:length(residuals)]) 



lm <- lm(ts_se_str ~ ts_se_lag + ts_eu_str_se_lag)
summary(lm)

#Iterate

#Good model:
order <- c(3, 0, 1)
xreg <- cbind(ts_se_lag, ts_eu_str_lag)

arima <- arima(ts_se_str, order = order, xreg = xreg)
summary(arima)

residuals <- arima$residuals
adf.test(residuals[2:length(residuals)])# Still Stationary

acf(residuals[2:length(residuals)]) # => perfect
pacf(residuals[2:length(residuals)]) # => perfect


#Only EU str as regressor
order <- c(1, 0, 0)
xreg <- cbind(ts_eu_str_lag[2:650])

arima <- arima(ts_se_str[2:650], order = order, xreg = xreg)
summary(arima)

residuals <- arima$residuals
adf.test(residuals[2:length(residuals)])# Still Stationary

acf(residuals[2:length(residuals)]) # => perfect
pacf(residuals[2:length(residuals)]) 
plot(residuals)

#problematic variable: , ts_se_vol_lag
#NA at ts_se_vol_lag: index 355
#Filling in value doesn't help




############## Rolling prediction: ##############

# Number of steps to forecast
n_steps <- length(ts_se_str)

# Number of steps to predict (last 60 values)
predict_steps <- 60

# Initialize variables to store predicted values
predictions <- numeric(predict_steps)

# Fit the initial ARIMA model
order <- c(2, 0, 0)
xreg <- cbind(ts_se_lag, ts_eu_str_se_lag)

# Use a subset of data to fit the initial model
initial_data <- ts_se_str[1:(n_steps - predict_steps)]
initial_xreg <- xreg[1:(n_steps - predict_steps), ]

# Fit initial model
arima_model <- arima(initial_data, order = order, xreg = initial_xreg)

# Perform rolling one-step-ahead predictions for the last 60 values
for (i in (n_steps - predict_steps + 1):n_steps) {
  # Get the regressors for the current time step
  current_xreg <- xreg[i, , drop = FALSE]
  
  # Forecast one step ahead using the current model and regressors
  forecast <- predict(arima_model, n.ahead = 1, newxreg = current_xreg)
  
  # Store the predicted value
  predictions[i - (n_steps - predict_steps)] <- forecast$pred
  
  # Update the model with the observed value for the current time step
  if (i < n_steps) {
    arima_model <- arima(ts_se_str[1:i], order = order, xreg = xreg[1:i, ])
  }
}

# Actual values for the last 60 steps
actual_values <- ts_se_str[(n_steps - predict_steps + 1):n_steps]

# Compare predictions with actual values for the last 60 steps
comparison <- data.frame(Actual = actual_values, Predicted = predictions)

comparison #simply apply error metrics

# Model 1:
############## Rolling prediction: ##############
# Specifics for model 1

ts_se_str_diff <- diff(ts_se_str)
ts_se_lag_diff <- diff(ts_se_lag)
ts_eu_str_se_lag_diff <- diff(ts_eu_str_se_lag)

plot(ts_se_str)
plot(ts_se_lag)

# Number of steps to forecast
n_steps <- length(ts_se_str_diff)

# Number of steps to predict (last 60 values)
predict_steps <- 500

# Initialize variables to store predicted values
predictions <- numeric(predict_steps)

# Fit the initial ARIMA model
order <- c(0, 0, 0)
xreg <- cbind(ts_se_lag_diff, ts_eu_str_se_lag_diff)
# Use a subset of data to fit the initial model
initial_data <- ts_se_str[1:(n_steps - predict_steps)]
initial_xreg <- xreg[1:(n_steps - predict_steps), ]

# Fit initial model
arima_model <- arima(ts_se_str_diff, order = order, xreg = xreg)
# Perform rolling one-step-ahead predictions for the last 60 values
for (i in (n_steps - predict_steps + 1):n_steps) {
  # Get the regressors for the current time step
  current_xreg <- xreg[i, , drop = FALSE]
  
  # Forecast one step ahead using the current model and regressors
  forecast <- predict(arima_model, n.ahead = 1, newxreg = current_xreg)
  
  # Store the predicted value
  predictions[i - (n_steps - predict_steps)] <- forecast$pred
  
  # Update the model with the observed value for the current time step
  if (i < n_steps) {
    arima_model <- arima(ts_se_str[1:i], order = order, xreg = xreg[1:i, ])
  }
}

# Actual values for the last 60 steps
actual_values <- ts_se_str[(n_steps - predict_steps + 1):n_steps]

# Compare predictions with actual values for the last 60 steps
comparison <- data.frame(Actual = actual_values, Predicted = predictions)



# Model 2:
############## Rolling prediction: ##############

# Number of steps to forecast
n_steps <- length(ts_se_str)

# Number of steps to predict (last 60 values)
predict_steps <- 500

# Initialize variables to store predicted values
predictions <- numeric(predict_steps)

# Fit the initial ARIMA model
order <- c(3, 0, 1)
xreg <- cbind(ts_se_lag, ts_eu_str_se_lag)


# Use a subset of data to fit the initial model
initial_data <- ts_se_str[1:(n_steps - predict_steps)]
initial_xreg <- xreg[1:(n_steps - predict_steps), ]

# Fit initial model
arima_model <- arima(initial_data, order = order, xreg = initial_xreg)

# Perform rolling one-step-ahead predictions for the last 60 values
for (i in (n_steps - predict_steps + 1):n_steps) {
  # Get the regressors for the current time step
  current_xreg <- xreg[i, , drop = FALSE]
  
  # Forecast one step ahead using the current model and regressors
  forecast <- predict(arima_model, n.ahead = 1, newxreg = current_xreg)
  
  # Store the predicted value
  predictions[i - (n_steps - predict_steps)] <- forecast$pred
  
  # Update the model with the observed value for the current time step
  if (i < n_steps) {
    arima_model <- arima(ts_se_str[1:i], order = order, xreg = xreg[1:i, ])
  }
}

# Actual values for the last 60 steps
actual_values <- ts_se_str[(n_steps - predict_steps + 1):n_steps]

# Compare predictions with actual values for the last 60 steps
comparison <- data.frame(Actual = actual_values, Predicted = predictions)

# Model 4:
############## Rolling prediction: ##############

# Number of steps to forecast
n_steps <- length(ts_se_str)

# Number of steps to predict (last 60 values)
predict_steps <- 500

# Initialize variables to store predicted values
predictions <- numeric(predict_steps)

# Fit the initial ARIMA model
order <- c(3, 0, 1)
xreg <- cbind(ts_se_lag)
# EU regressor removed, ts_eu_str_se_lag
# Use a subset of data to fit the initial model
initial_data <- ts_se_str[1:(n_steps - predict_steps)]
initial_xreg <- xreg[1:(n_steps - predict_steps), ]

# Fit initial model
arima_model <- arima(initial_data, order = order, xreg = initial_xreg)

# Perform rolling one-step-ahead predictions for the last 60 values
for (i in (n_steps - predict_steps + 1):n_steps) {
  # Get the regressors for the current time step
  current_xreg <- xreg[i, , drop = FALSE]
  
  # Forecast one step ahead using the current model and regressors
  forecast <- predict(arima_model, n.ahead = 1, newxreg = current_xreg)
  
  # Store the predicted value
  predictions[i - (n_steps - predict_steps)] <- forecast$pred
  
  # Update the model with the observed value for the current time step
  if (i < n_steps) {
    arima_model <- arima(ts_se_str[1:i], order = order, xreg = xreg[1:i, ])
  }
}

# Actual values for the last 60 steps
actual_values <- ts_se_str[(n_steps - predict_steps + 1):n_steps]

# Compare predictions with actual values for the last 60 steps
comparison <- data.frame(Actual = actual_values, Predicted = predictions)



ggplot(comparison, aes(x = 1:nrow(comparison))) +
  geom_line(aes(y = Actual, color = "Actual")) +
  geom_line(aes(y = Predicted, color = "Predicted"), linetype = "dashed") +
  scale_color_manual(values = c("Actual" = "blue", "Predicted" = "red")) +
  labs(x = "Index", y = "Value", title = "Actual vs. Predicted Values") +
  theme_minimal()

MAE <- mean(abs(comparison$Actual - comparison$Predicted))
RMSE <- sqrt(mean((comparison$Actual - comparison$Predicted)^2))
MAPE <- mean(abs((comparison$Actual - comparison$Predicted) / comparison$Actual)) * 100
ME <- mean(comparison$Actual - comparison$Predicted)
MSE <- mean((comparison$Actual - comparison$Predicted)^2)

# Print the error metrics
cat("Mean Error (ME):", ME, "\n")
cat("Mean Absolute Error (MAE):", MAE, "\n")
cat("Root Mean Squared Error (RMSE):", RMSE, "\n")
cat("Mean Absolute Percentage Error (MAPE):", MAPE, "%\n")
cat("Mean Squared Error (MSE):", MSE, "\n")










#Model 3: 


#Iterate
xreg <- cbind(ts_se_lag)


#Good model:
order <- c(3, 0, 1)

arima_model <- arima(ts_se_str, order = order, xreg = xreg)
summary(arima_model)

residuals <- arima_model$residuals
adf.test(residuals[2:length(residuals)])# Still Stationary

acf(residuals[2:length(residuals)]) # => perfect
pacf(residuals[2:length(residuals)])
