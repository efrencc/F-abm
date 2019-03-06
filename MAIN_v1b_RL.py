# -*- coding: utf-8 -*-
"""
Created on Sat Jan 26 19:24:34 2019

@author: Efren
"""

# v1b with reinfo learning!

# let's start with fixed tolerance threshold and fixed q0
# we'll do multi-armed bandit
# remember to setup model, then seed it, then setup again

import numpy as np
import matplotlib.pyplot as plt
import time
import pyNetLogo

##### --- Run Once --- #####
#netlogo = pyNetLogo.NetLogoLink() #needed? #Show NetLogo GUI
#netlogo.load_model(r'Desktop\Fairness-ABM\racial arrest_v1b01.nlogo')
##### ---------------- #####

tol_fair = .5
q0 = np.array([5,8]) #focus on one
theta_vector = np.array([0, 25, 50, 75, 100])
n_steps = 3000
myseeds = np.array([0,42])
N_runs = 30 #60

n_actions = len(theta_vector)
n_seeds = len(myseeds)
eps_exp = .1 #epsilon used for exploration -> using greedy action choice
# initialize RL value and count functions
QM = np.zeros((n_seeds,n_actions))
AM = np.zeros((n_seeds,n_actions))

from v1b_RL_functions import *

for si in range(n_seeds):
    Q = 3*np.ones((n_actions)) # since maximum reward is 1, this is "optimistic initialization"
    action_count = np.zeros((n_actions)) # how many times we've chosen an action
    netlogo.command('setup')
    netlogo.command('set myseed ' + str(myseeds[si]))
    start_time = time.time()
    for ti in range(N_runs):
        a = chooseAction(Q,eps_exp)
        ### this portion does netlogo part, figure out how to put in functions later on
        theta = theta_vector[a]
        netlogo.command('setup')
        netlogo.command('set theta ' + str(theta))
        netlogo.command('set q0 ' + str(q0[si])) # needed here? or just once at the beginning?
        netlogo.repeat_command('go', n_steps)
        arr_prop = netlogo.report('arrest-proportion')
        fpr_poc = netlogo.report('FPR-poc')
        fpr_cau = netlogo.report('FPR-cau')
        tau_p = getTau(arr_prop,fpr_poc,fpr_cau) #
        r_bool = np.abs(tau_p) < tol_fair
        r = np.sum(r_bool)
        # r = getReward(a)
        ######
        action_count[a] = action_count[a] + 1
        Q[a] = Q[a] + (1/action_count[a])*(r - Q[a])
    QM[si,:] = Q
    AM[si,:] = action_count
final_time = (time.time() - start_time) / 60
print('%s mins' % final_time)

# note for q0=50 it chooses either theta 0 or theta .25. For this q0 we need
# more runs and averages over different seeds, of course.

####### BIG QUESTION: what if we do use the taus directly (without thresholding?)

a_props = AM[1]/N_runs
rew_expc = QM[1]

plt.figure(1)
plt.plot(theta_vector,a_props)
#plt.legend()
plt.title('Proportion of taken action')
plt.xlabel(r'$\theta$')
plt.ylabel(r'$\frac{N_A(\theta)}{N_{tot}}$')
plt.show

plt.figure(2)
plt.plot(theta_vector,rew_expc)
#plt.legend()
plt.title('Expected reward')
plt.xlabel(r'$\theta$')
plt.ylabel(r'$Q_N(A)$')
plt.show

























### end here