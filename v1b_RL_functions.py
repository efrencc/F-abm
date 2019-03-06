# -*- coding: utf-8 -*-
"""
Created on Sat Jan 26 19:48:44 2019

@author: Efren
"""

# functions supporting RL algorithm, multiarmed bandit

def chooseAction(Q,eps_exp):
    import numpy as np
    A = np.arange((len(Q)))
    greed = np.random.binomial(1,1 - eps_exp)
    if greed == 1:
        amax_candidates = np.where(Q == np.amax(Q))
        amax_candidates = A[amax_candidates]
        a = np.random.choice(amax_candidates)
    elif greed == 0:
        a = np.random.choice(A)
    return a;

def getTau(ap,fp,fc):
    if fc > 0:
        tau = 1 - ap*(fp / fc)
    else:
        tau = 100
    return tau;