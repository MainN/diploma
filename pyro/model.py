import os
from functools import partial
import torch
import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import pyro
import pyro.distributions as dist
def model(data):
    alpha = pyro.sample('alpha', pyro.distributions.Normal(0,5))
    beta = pyro.sample('beta', pyro.distributions.Normal(0,5))
    sigma = pyro.sample('sigma',pyro.distributions.Gamma(0.5,4.))
    mu = alpha + beta*torch.FloatTensor(data)
    res = pyro.sample('result',pyro.distributions.Normal(mu,sigma))
    return res
print(model([1,2,3,4,5,6]))