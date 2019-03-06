# -*- coding: utf-8 -*-
"""
Created on Wed Jan 23 12:18:08 2019

@author: Efren
"""
#
# analysis and causal analysis of model v 1.x, without reinforcement learning

# Arrest Model, no RL

import numpy as np
import matplotlib.pyplot as plt
import time
import pyNetLogo

##### --- Run Once --- #####
#netlogo = pyNetLogo.NetLogoLink() #needed? #Show NetLogo GUI
#netlogo.load_model(r'Desktop\Fairness-ABM\racial arrest_v1b.nlogo')
##### ---------------- #####

# our first goal is to run it for different values of theta (cops surveillance bias)
# and q0, the initial distribution of cops over the two populations.

# Then collect the final values of fairness metrics, and create distribution (each run is sample point)
# as well as expectations, etc.

N_runs = 60 # do 30 or so?
n_steps_1 = 3000
n_steps_total = 5000 # 3000 -> time steps for each run, do 5000 to ensure stability?
theta_vector = np.array([0, 25, 50, 75, 100]) #np.array([0, 25, 50, 75, 100])
T = len(theta_vector)
q0_vector = np.array([5, 8]) #np.array([5, 6, 7, 8, 9, 10])
n_q0 = len(q0_vector)

arrest_proportion = np.zeros((n_q0,T,N_runs))
fpr_poc = np.zeros((n_q0,T,N_runs))
fpr_cau = np.zeros((n_q0,T,N_runs))
fnr_poc = np.zeros((n_q0,T,N_runs))
fnr_cau = np.zeros((n_q0,T,N_runs))
ppv_poc = np.zeros((n_q0,T,N_runs))
ppv_cau = np.zeros((n_q0,T,N_runs))

arrest_proportion_3k = np.zeros((n_q0,T,N_runs))
fpr_poc_3k = np.zeros((n_q0,T,N_runs))
fpr_cau_3k = np.zeros((n_q0,T,N_runs))
fnr_poc_3k = np.zeros((n_q0,T,N_runs))
fnr_cau_3k = np.zeros((n_q0,T,N_runs))
ppv_poc_3k = np.zeros((n_q0,T,N_runs))
ppv_cau_3k = np.zeros((n_q0,T,N_runs))

start_time = time.time()

for i_q0 in range(n_q0):
    q0 = q0_vector[i_q0]
    #
    for t in range(T):
        theta = theta_vector[t]
        #
        for irun in range(N_runs):
            netlogo.command('setup')
            netlogo.command('set theta ' + str(theta))
            netlogo.command('set q0 ' + str(q0))
            #
            netlogo.repeat_command('go', n_steps_1)
            arrest_proportion_3k[i_q0,t,irun] = netlogo.report('arrest-proportion')
            fpr_poc_3k[i_q0,t,irun] = netlogo.report('FPR-poc')
            fpr_cau_3k[i_q0,t,irun] = netlogo.report('FPR-cau')
            fnr_poc_3k[i_q0,t,irun] = netlogo.report('FNR-poc')
            fnr_cau_3k[i_q0,t,irun] = netlogo.report('FNR-cau')
            ppv_poc_3k[i_q0,t,irun] = netlogo.report('PPV-poc')
            ppv_cau_3k[i_q0,t,irun] = netlogo.report('PPV-cau')
            #
            netlogo.repeat_command('go', n_steps_total - n_steps_1)
            arrest_proportion[i_q0,t,irun] = netlogo.report('arrest-proportion')
            fpr_poc[i_q0,t,irun] = netlogo.report('FPR-poc')
            fpr_cau[i_q0,t,irun] = netlogo.report('FPR-cau')
            fnr_poc[i_q0,t,irun] = netlogo.report('FNR-poc')
            fnr_cau[i_q0,t,irun] = netlogo.report('FNR-cau')
            ppv_poc[i_q0,t,irun] = netlogo.report('PPV-poc')
            ppv_cau[i_q0,t,irun] = netlogo.report('PPV-cau')
            #        
final_time = (time.time() - start_time) / 60
print('%s mins' % final_time)

#
#import pickle
#file_name = 'outcomes_v1b_02.pickle'
#vars_to_save = [arrest_proportion,fpr_poc,fpr_cau,fnr_poc,fnr_cau,ppv_poc,ppv_cau,
#                arrest_proportion_3k,fpr_poc_3k,fpr_cau_3k,
#                fnr_poc_3k,fnr_cau_3k,ppv_poc_3k,ppv_cau_3k,
#                final_time,n_steps_total,n_steps_1,theta_vector,q0_vector]
#pickle.dump(vars_to_save,open(file_name,'wb'))



# now obtain means and create KDEs for each value of (q_0,theta_0)
from v1b_statistics import *
tau_a_1 = obtainTauArrest(fpr_poc,fpr_cau)
tau_a_2 = obtainTauArrest(fnr_poc,fnr_cau)
tau_a_3 = obtainTauArrest(ppv_poc,ppv_cau)
tau_p_1 = obtainTauPopulation(arrest_proportion,fpr_poc,fpr_cau)
tau_p_2 = obtainTauPopulation(arrest_proportion,fnr_poc,fnr_cau)

# for now, let's explore FPR
ma1,sa1 = obtainMean(tau_a_1)
mp1,sp1 = obtainMean(tau_p_1)
N_ep = 100
eval_points = obtainEvalPoints(ma1,sa1,mp1,sp1,N_ep)
ka1 = obtainKDE(tau_a_1,sa1,eval_points)
kp1 = obtainKDE(tau_p_1,sp1,eval_points)

############ PLOTS

plt.figure(1)
for iq in range(n_q0):
    plt.plot(theta_vector,mp1[iq,:],label = r'$q_0$ = %d'%(q0_vector[iq],))
plt.legend()
plt.title('Outcome Means')
plt.xlabel(r'$\theta$')
plt.ylabel(r'$E(\tau|q_0,\theta)$')
plt.show

plt.figure(2)
for iq in range(n_q0):
    plt.plot(theta_vector,ma1[iq,:],label = r'$q_0$ = %d'%(q0_vector[iq],))
plt.legend()
plt.title('Outcome Means')
plt.xlabel(r'$\theta$')
plt.ylabel(r'$E(\tau|q_0,\theta)$')
plt.show

plt.figure(3)
for iq in range(n_q0):
    plt.plot(theta_vector,ma1[iq,:]-mp1[iq,:],label = r'$q_0$ = %d'%(q0_vector[iq],))
plt.legend()
plt.title('Outcome Mean Difference')
plt.xlabel(r'$\theta$')
plt.ylabel(r'$E_a(\tau|q_0,\theta) - E_p(\tau|q_0,\theta)$')
plt.show

# i have to figure out how to build outcome axis pick [min,max]
fig,axes = plt.subplots(n_q0,T)
for ix in range(n_q0):
    for jx in range(T):
        axes[ix,jx].plot(eval_points[ix,jx],ka1[ix,jx],label = 'arrest')
        axes[ix,jx].plot(eval_points[ix,jx],kp1[ix,jx],label = 'population')
        axes[ix,jx].legend()
        axes[ix,jx].set_xlabel(r'$\tau$')
        axes[ix,jx].set_ylabel(r'$f(\tau)$')
fig.suptitle('Outcome Distribution')
plt.show

plt.figure(5)
plt.plot(eval_points[1,3],ka1[1,3],label='arrest')
plt.plot(eval_points[1,3],kp1[1,3],label='population') # -> this is the weird one ??
plt.legend()
plt.title('Outcome Distributions')
plt.xlabel(r'$\tau$')
plt.ylabel(r'$f(\tau)$')
plt.show


plt.figure(6)
plt.hist(tau_p_1[1,4])

###### Proportion of "fair" outcomes when thresholded
tols = np.array([.1, .5, 1, 2])
th_ta1 = obtainThresholded(np.abs(tau_a_1),tols)
th_tp1 = obtainThresholded(np.abs(tau_p_1),tols)
fp_ta1 = obtainFairProportions(th_ta1)
fp_tp1 = obtainFairProportions(th_tp1)

fig,axes = plt.subplots(2,2)
mycols = np.array(['r','b'])
mystyls = np.array(['-','--','-.',':'])
for tt in range(len(tols)):
    for ii in range(n_q0):
        axes[0,0].plot(theta_vector,fp_ta1[ii,:,tt], color = mycols[ii],linestyle = mystyls[tt])
        axes[0,1].plot(theta_vector,fp_tp1[ii,:,tt], color = mycols[ii],linestyle = mystyls[tt])
        axes[1,ii].plot(theta_vector,fp_ta1[ii,:,tt], color = mycols[0],linestyle = mystyls[tt])
        axes[1,ii].plot(theta_vector,fp_tp1[ii,:,tt], color = mycols[1],linestyle = mystyls[tt])
axes[0,0].set_title('Arrested, q0 = 50 (red) vs q0=80 (blue)')
axes[0,1].set_title('Population, q0 = 50 (red) vs q0=80 (blue)')
axes[1,0].set_title('q0 = 50, arrested (red) vs population (blue)')
axes[1,1].set_title('q0 = 80, arrested (red) vs population (blue)')
fig.suptitle('Fairness Proportions')
plt.show
#########################################################

















## end here ##