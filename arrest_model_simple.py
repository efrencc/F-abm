# -*- coding: utf-8 -*-
"""
Created on Thu Aug 23 15:16:01 2018

@author: Efren
"""

# Arrest Model, no RL

import numpy as np
import random
import matplotlib.pyplot as plt
import pyNetLogo
import time

##### --- Run Once --- #####
#netlogo = pyNetLogo.NetLogoLink() #Show NetLogo GUI
#netlogo.load_model(r'Desktop\Fairness-ABM\racial arrest.nlogo')
##### ---------------- #####

# run it for several values of theta. Obtain appropriate metrics at given times
# and plot that. Average over several runs.

N_runs = 30 # do 10 or so?
n_steps_total = 3000 #3000
measure_window = 50
n_steps = int(n_steps_total / measure_window)
time_vector = measure_window * (1 + np.arange(n_steps) )
theta_vector = np.array([0, 25, 50, 100])
T = len(theta_vector)
AP = np.zeros((T,n_steps))
TAUM_A = np.zeros((T,n_steps))
TAUM_P = np.zeros((T,n_steps))

start_time = time.time()

for t in range(T):
    theta = theta_vector[t]
    arrest_proportion = np.zeros(n_steps)
    tau_A = np.zeros(n_steps)
    tau_P = np.zeros(n_steps)
    
    for irun in range(N_runs):
        netlogo.command('setup')
        netlogo.command('set theta ' + str(theta))
        for indx in range(n_steps):
            netlogo.repeat_command('go', measure_window)
            arrest_proportion[indx] = arrest_proportion[indx] + netlogo.report('arrest-proportion')
            tau_A[indx] = tau_A[indx] + netlogo.report('tau-arrest')
            tau_P[indx] = tau_P[indx] + netlogo.report('tau-population')
    arrest_proportion = arrest_proportion / N_runs
    tau_A = tau_A / N_runs
    tau_P = tau_P / N_runs
        
    AP[t,:] = arrest_proportion
    TAUM_A[t,:] = tau_A
    TAUM_P[t,:] = tau_P
        
final_time = (time.time() - start_time) / 60
print('%s mins' % final_time)

plt.figure(1)
for t in range(T):
    theta = theta_vector[t]
    plt.plot(time_vector, AP[t,:], label = r'$\theta$ = %d'%(theta,))
plt.legend()
plt.title('Arrest Proportion')
plt.xlabel('time')
plt.ylabel(r'$\frac{p_A(G1)}{p_A(G2)}$')
plt.show

plt.figure(2)
for t in range(T):
    plt.plot(time_vector, TAUM_A[t,:]/3, label = r'$\theta$ = %d'%(theta_vector[t],))
plt.legend()
plt.title('Tau_A')
plt.xlabel('time')
plt.ylabel(r'$\tau_A$')
plt.show

plt.figure(3)
for t in range(T):
    plt.plot(time_vector, TAUM_P[t,:]/3,label = r'$\theta$ = %d'%(theta_vector[t],))
plt.legend()
plt.title('Tau_P')
plt.xlabel('time')
plt.ylabel(r'$\tau_P$')
plt.show


##########
#import pickle
#file_name = 'arrest_simple_02.pickle'
#vars_to_save = [AP,TAUM_A,TAUM_P,N_runs,n_steps_total,measure_window,theta_vector]
## recid 40, crime rate 10 (of 1k), population 100, with replacement
#pickle.dump(vars_to_save,open(file_name,'wb'))





##########
        
        
        
        
        
#