using Turing, MCMCChain, Flux

data = (y = [1.0, 3.0, 3.0, 3.0, 5.0], x = [1.0, 2.0, 3.0, 4.0, 5.0])

@model line(y, x) = begin
    #priors
    alpha ~ Normal(0.0, 10.0)
    beta ~ Normal(0.0, 10.0)
    s ~ InverseGamma(0.001, 0.001)
    #model

    mu = alpha .+ beta*x
    for i in 1:length(y)
      y[i] ~ Normal(mu[i], s)
    end
end
  
chn = sample(line(data.y, data.x), HMC(1000, 0.01, 10))
display(plot(chn))
readline()