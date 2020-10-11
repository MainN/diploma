import pandas as pd
import numpy as np

import tensorflow as tf
import tensorflow_probability as tfp

import seaborn as sns
import matplotlib.pyplot as plt
import arviz as az

df=pd.read_csv('../data/data.csv', sep=',',header=None)
df=df.fillna('0')
df=df.drop([0])
a=np.asarray(df.values.astype(int))
print(a)
