import logging
import pymc4 as pm
import numpy as np
import arviz as az

import tensorflow as tf
import tensorflow_probability as tfp
import matplotlib.pyplot as plt
@pm.model
def model(x):
    # prior for the mean of a normal distribution
    loc = yield pm.Normal('loc', loc=0, scale=10)
    
    # likelihood of observed data
    obs = yield pm.Normal('obs', loc=loc, scale=1, observed=x)
# 30 data points normally distributed around 3
x = np.random.randn(30) + 3

# Inference
trace = pm.sample(model(x))
plt.show(az.plot_posterior(trace, var_names=['model/loc']))
