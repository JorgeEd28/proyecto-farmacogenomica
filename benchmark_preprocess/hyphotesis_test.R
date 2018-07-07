# Specify directories ---------------------------------------------------------

datadir <- "R_Benchmark"

# Hyphotesis test -------------------------------------------------------------

data <- read.csv(file.path(datadir, "prop_diff_by_sample.csv"), as.is = TRUE)

# Ho: p >= po
# Ha: p < po

# Declare variables
p_hat <- mean(data[["proporcion"]])
po <- 0.01
s <- sd(data[["proporcion"]])
n <- nrow(data)
alpha <- 0.01

# Critical value
t <- sqrt(n)*(p_hat - po)/s
t_crit <- qt(alpha, n - 1, lower.tail = FALSE)

# Test
reject <- t < t_crit
desc <- ifelse(t < t_crit, paste("Reject Ho: p >=", po),
       paste("Do not reject Ho: p >=", po)); desc
