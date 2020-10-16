import pyro
import os
from functools import partial
import torch
import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

import pyro.poutine as poutine
import pyro.distributions as dist
from pyro.infer.mcmc.api import MCMC
from pyro.infer.mcmc.hmc import HMC
def linear(xes,yes):
    slope = pyro.sample("slope",dist.Normal(5,10))
    intercept = pyro.sample("intercept",dist.Normal(0,10))
    var = pyro.sample("var",dist.InverseGamma(3, 0.1))
    x=slope*xes
    return slope
print(linear([1],[1]))
