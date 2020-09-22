using MCMCChains
using StatsPlots
using AdvancedMH
using Plots
using Distributions
theme(:ggplot2)

function my_model(data)
    alpha = Normal(0,10000)
    beta = Normal(0,10000)
    s = InverseGamma(0.0001, 0.001)
    
    mu = rand(alpha) .+ rand(beta)*data
    return mu
end
function likelihood(data::Vector,mu::Float64,sigma::Real)
    numofdatapoints = length(data)
    result=1.0
    for k = 1:numofdatapoints
        result *= pdf(Normal(mu, sigma),data[k])
    end
    return result
end
function likelihood_sigma(data::Vector,mu::Float64,sigma::Real)
    numofdatapoints = length(data)
    result=1.0
    for k = 1:numofdatapoints
        result *= pdf(InverseGamma(mu, sigma),data[k])
    end
    return result
end
function loglikelihood(data::Vector,alpha::Real,beta::Real,sigma::Real)
    numofdatapoints = length(data)
    result=0.0
    
    mu = alpha .+ beta * data
    for k in 1:numofdatapoints
        result += log10(  pdf(Normal(mu[k], sigma),data[k])  )
    end
    return result
end  
function main()  
data = [1,2,3,4,5,6]
alpha_distr = Normal(5,10)
beta_distr = Normal(0,10)
sigma_distr = InverseGamma(3, 0.5)
n_samples = 1_000_0
alpha = zeros(n_samples)
beta= zeros(n_samples)
sigma = zeros(n_samples)
alpha[1]=rand(alpha_distr)
beta[1]=rand(beta_distr)
sigma[1]=rand(sigma_distr)
#sigma[1]=rand(sigma_distr)
alpha_pdf(x)=(Distributions.pdf(alpha_distr,x))
beta_pdf(x)=(Distributions.pdf(beta_distr,x))
sigma_pdf(x)=(Distributions.pdf(sigma_distr,x))
JumpingWidth = 1.5
for x in 2:n_samples
    #component-wise metropolis
    alpha_new = rand(  Normal( alpha[x-1] , JumpingWidth )  )
    beta_new = rand(  Normal( beta[x-1] , JumpingWidth )  )
    sigma_new = abs(rand( (Normal( sigma[x-1] , JumpingWidth )  )))
    #sigma_new = sigma[x-1]
    alpha_0=alpha_pdf(alpha[x-1])
    beta_0=beta_pdf(beta[x-1])

    sigma_0=sigma_pdf(sigma[x-1])
    alpha_1=alpha_pdf(alpha_new)
    beta_1=beta_pdf(beta_new)
    sigma_1=sigma_pdf(sigma_new)
    logprior_alpha0 = log10(  alpha_pdf(alpha[x-1])  )
    logprior_beta0 = log10(  beta_pdf(beta[x-1])  )
    logprior_sigma0 = log10(  sigma_pdf(sigma[x-1])  )
    logprior_alpha1 = log10(  alpha_pdf(alpha_new)   )
    logprior_beta1 = log10(  beta_pdf(beta_new)   )
    logprior_sigma1 = log10(  sigma_pdf(sigma_new)   )
    q0 = loglikelihood(data,alpha[x-1],beta[x-1],sigma[x])+logprior_alpha0+logprior_beta0+logprior_sigma0
    q1 = loglikelihood(data,alpha_new,beta_new,sigma_new)+logprior_alpha1+logprior_beta1+logprior_sigma1
    if log10(rand())<q1-q0
        alpha[x]=alpha_new
        beta[x]=beta_new
        sigma[x]=sigma_new
    else 
        alpha[x]=alpha[x-1]
        beta[x]=beta[x-1]
        sigma[x]=sigma[x-1]
    end
    
end
Plots.plot(alpha,legend=false,title="Iterations of alpha") |> display
readline()
Plots.plot(beta,legend=false,title="Iterations of beta") |> display
readline()
Plots.plot(sigma,legend=false,title="Iterations of sigma") |> display
readline()
histogram(alpha,legend=false,title="Posterior of alpha") |> display
readline()
histogram(beta,legend=false,title="Posterior of beta") |> display
readline()
histogram(sigma,legend=false,title="Posterior of sigma") |> display
readline()

end
@time main()