

# Load the data
data <- read.table(gzfile("FR.gz"), header = FALSE, sep = "", stringsAsFactors = FALSE)

# Remove the first column and first row
data <- data[-1, -1]

# Set the data type as double to be able to use it in Octave
data <- as.data.frame(lapply(data, as.double))

# Transpose data out of convention. 1 column for 1 variable
data <- t(data)

# Save to a new CSV file
write.csv(data, "cleaned_data.csv", row.names = FALSE)


