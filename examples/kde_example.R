



## Example data
x = c(.5, 1, 1.25, 1.25, 1, 1.5, 2.5, 1 )
y = c(.5, .5, .5, 1, 1.5, 1.5, 1.5, 2)
df_new <- data.frame(x = c(0.5, 1.0, 1.5, 3.0),
                     y = c(1.0, 1.0, 1.0, 2.5))
new <- unlist(df_new[3, ])
h = c(1, 1)
h <- h/4


## kde from food inspection
nx <- length(x)
ax <- (new[1]-x) / h[1L]
ay <- (new[2]-y) / h[2L]
z0 <- tcrossprod(matrix(dnorm(ax), , nx), 
                 matrix(dnorm(ay), , nx)) / (nx * h[1L] * h[2L])
z0

## kde2d
MASS::kde2d
n = 25
lims = c(range(x), range(y)) 

nx <- length(x)
n <- rep(n, length.out = 2L)
gx <- seq.int(lims[1L], lims[2L], length.out = n[1L])
gy <- seq.int(lims[3L], lims[4L], length.out = n[2L])
ax <- outer(gx, x, "-") / h[1L]
ay <- outer(gy, y, "-") / h[2L]
z <- tcrossprod(matrix(dnorm(ax), , nx), 
                matrix(dnorm(ay), , nx)) / (nx * h[1L] * h[2L])
z

## plot
plot(x,y, xlim=c(0,3), ylim = c(0,3), pch = "X", col = "blue")
points(new["x"], new["y"], pch = "O", col = "red")
contour(x=gx, y=gy, z, nlevels=5, xlim=c(0,3), ylim = c(0,3), add = TRUE)
z0
