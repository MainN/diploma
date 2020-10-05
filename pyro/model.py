import os
from functools import partial
import torch
import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import pyro
import pyro.distributions as dist
def model():
    alpha = pyro.sample('alpha', pyro.distributions.Normal(0,5))
    beta = pyro.sample('beta', pyro.distributions.Normal(0,5))
    sigma = pyro.sample('sigma',pyro.distributions.Gamma(0.5,4.))
    return alpha,beta,sigma
for _ in range(3):
    print(model())