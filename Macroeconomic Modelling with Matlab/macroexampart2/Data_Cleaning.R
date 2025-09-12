#install.packages("readr")

# Load library to read CSV file
library("readr")

# Read the CSV file
data <- read_csv("GDP.csv")

# Only keeping the first 2 rows where the data is, and transposing for convention
clean_data <- t(data[1:2, ])

# Removes columns 2, 3, and 4 containing excess information
clean_data <- clean_data[-c(2, 3, 4), ]

# Defines "years" column spanning 1974 - 2023
year_row <- c("Year", 1974:2023)

# Adds the year column to the clean data
clean_data <- cbind(clean_data, year_row)

# Saves the cleaned data to a new CSV file
clean_data <- as.data.frame(clean_data)
write_csv(clean_data, "Cleaned_Data.csv")










