set.seed(42)
n <- 100
x <- rnorm(n, 0, 3)
y <- rnorm(n, 0, 3)
l <- rep('tomato', n)
id <- sort(c(sample(1:n, 50, F)))
l[id] <- 'steelblue'
lb <- factor(l, levels = c('tomato', 'steelblue'))
plot(x, y, col = l)

X <- cbind(x, y)

xbt_param <- list(eta = .1, max_depth = 20)
