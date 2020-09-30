from math import exp, cos, pi, log
import pystan

code ='''
data {
    int T;  // Time
    int N;  // number of individuals
    real time[T]; // time measurements
    real dset[N,T]; // data
    int known[N,T]; // shows if the data point is available
 }
parameters {
    real b0;
    real b1;
    vector[N] C;
    real<lower = 0> delta_C;
    real<lower = 0> delta_ERR;
}
model {
    delta_ERR ~ exponential(1);
    delta_C ~ exponential(1);
    b0 ~ normal(0,1);
    b1 ~ normal(0,1);
    C ~ normal(0,delta_C);
    for (t in 1:T) {
        for (i in 1:N) {
            if (known[i,t] == 1)  {dset[i,t] ~ normal(C[i] + b0 + b1 * time[t],delta_ERR);}
        }
    }
}
'''
sm = pystan.StanModel(model_code=code)

name = 'M_1'
from M_data import data, known
#"t5"	"t6"	"t9"	"t12"	"t15"	"t20"
#samples scheduled at (1.5, 2.5, 3.5, 4.5)?, 5.5, 6.5, 7.5, 10.5, 13.5, 16.5, and 21.5 years of age
T=6
time = [log(x) for x in [1,2,5,8,11,16]]
N = len(data)
data  = dict(
        T=T,
        N=N,
        dset=data,
        known=known,
        time=time)
init = dict(
    b0 = 6,
    b1 = -2,
    C = [0]*N,
    delta_C=1,
    delta_ERR=1)  


fit = sm.sampling(data=data, iter=1500, chains=4, init=[init]*4,thin=1)
op = fit.extract()  