bci <- read.csv('~/Dropbox/Research/data/stri/BCIS.csv', as.is = TRUE)
bci <- bci[bci$year == max(bci$year), ]


esf <- meteESF(S0 = length(unique(bci$spp)), N0 = sum(bci$count), E0 = sum(bci$dbh^2))
thisIPD <- ipd(esf)

plot(seq(1.1, 0.000001*e, length.out = 100), thisIPD$p(seq(1.1, 0.000001*e, length.out = 100)), )

exp(seq(log(1), log(esf$state.var['E0']), length.out = 10000))



esf <- meteESF(S0 = 300, N0 = 2000, E0 = 2000 * 100)
thisIPD <- ipd(esf)






plot(thisIPD, ylim = c(0, 1), xlim = c(1, 200000), log = 'x')


s <- 256
n <- 2^12 * s
e <- 2^10 * n
esf <- meteESF(S0 = s, N0 = n, E0 = e)

thisIPD <- ipd(esf)

plot(thisIPD, ptype = 'rad', log = 'y')

plot(thisIPD$q(seq(0, 1, length.out = 1000)), seq(0, 1, length.out = 1000), log = 'x')

points(seq(1.1, 0.000001*e, length.out = 100), thisIPD$p(seq(1.1, 0.000001*e, length.out = 100)), col = 'red')
