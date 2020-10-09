import os
from functools import partial
import torch
import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import pyro
from pyro.infer import EmpiricalMarginal
import pyro.poutine as poutine
import pyro.distributions as dist
from pyro.infer import MCMC, NUTS,HMC
def scale(guess):
    weight = pyro.sample("weight", dist.Normal(guess, 1.0))
    measurement = pyro.sample("measurement", dist.Normal(weight, 0.75))
    return measurement
conditioned_scale = pyro.condition(scale, data={"measurement": torch.tensor(14.)})
guess_prior = 10.
hmc_kernel = HMC(conditioned_scale, step_size=0.9, num_steps=4)
posterior = MCMC(hmc_kernel,
                 num_samples=1000,
                 warmup_steps=50).run(guess_prior)

print(posterior)
