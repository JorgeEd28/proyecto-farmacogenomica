# Hyphotesis test

data <- read.csv("prop_diff_by_sample.csv", as.is = TRUE)

# Ho: p >= 0.05
# Ha: p < 0.05

# Declare variables
p_hat <- mean(data[["proporcion"]])
po <- 0.05
s <- sd(data[["proporcion"]])
n <- nrow(data)
alpha <- 0.05

# Critical value
t <- sqrt(n)*(p_hat - po)/s
t_crit <- qt(alpha, n - 1, lower.tail = FALSE)

# Test
reject <- t < t_crit
desc <- ifelse(t < t_crit, paste("Reject Ho: p >=", po),
       paste("Do not reject Ho: p >=", po)); desc