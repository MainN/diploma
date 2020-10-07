import logging
import pymc4 as pm
import numpy as np
import arviz as az

import timeit
import tensorflow as tf
import tensorflow_probability as tfp

import seaborn as sns
import matplotlib.pyplot as plt
tfd = tfp.distributions
N = 6
std = 1
m = np.random.normal(0, scale=5, size=1).astype(np.float32)
b = np.random.normal(0, scale=5, size=1).astype(np.float32)
x = np.linspace(0, 100, N).astype(np.float32)
y = m*x+b+ np.random.normal(loc=0, scale=std, size=N).astype(np.float32)
def joint_log_prob(x, y, m, b, std):
  rv_m = tfd.Normal(loc=0, scale=5)
  rv_b = tfd.Normal(loc=0, scale=5)
  rv_std = tfd.HalfCauchy(loc=0., scale=2.)

  y_mu = m*x+b
  rv_y = tfd.Normal(loc=y_mu, scale=std)

  return (rv_m.log_prob(m) + rv_b.log_prob(b) + rv_std.log_prob(std)
          + tf.reduce_sum(rv_y.log_prob(y)))
def target_log_prob_fn(m, b, std):
    return joint_log_prob(x, y, m, b, std)

hmc_kernel = tfp.mcmc.HamiltonianMonteCarlo(
  target_log_prob_fn=target_log_prob_fn,
  step_size=np.float64(0.000000000000008),
  num_leapfrog_steps=7)

states,kernel_results=tfp.mcmc.sample_chain(num_results=1000,
current_state=[
          0.01 * tf.ones([], name='init_m', dtype=tf.float32),
          0.01 * tf.ones([], name='init_b', dtype=tf.float32),
          1. * tf.ones([], name='init_std', dtype=tf.float32)
      ],kernel=hmc_kernel)
colors = ['b', 'g', 'r']
print("Acceptance rate:", kernel_results.is_accepted.numpy().mean())
for i in range(3):
  sns.distplot(states[i], color=colors[i])
ymax = plt.ylim()[1]
plt.ylim(0, ymax)
plt.show()