# -*- coding: utf-8 -*-
"""
Created on Wed Jan 23 16:41:17 2019

@author: Efren
"""

# obtaining mean and kdes

def obtainTauArrest(M1,M2):
    # M is a (d1,d2,n) matrix
    import numpy as np
    import math
    d1 = M1.shape[0]
    d2 = M1.shape[1]
    n = M1.shape[2]
    T = np.zeros((d1,d2,n))
    #basically i want elementwise M1/M2 if M2>0 and 0 else
    for ix in range(d1):
        for jx in range(d2):
            for tx in range(n):
                if (M2[ix,jx,tx] > 0):
                    T[ix,jx,tx] = (1 - (M1[ix,jx,tx]/M2[ix,jx,tx])) #instead of abs(.)
    return T;

def obtainTauPopulation(A,M1,M2):
    # M is a (d1,d2,n) matrix
    import numpy as np
    import math
    d1 = M1.shape[0]
    d2 = M1.shape[1]
    n = M1.shape[2]
    T = np.zeros((d1,d2,n))
    #basically i want elementwise M1/M2 if M2>0 and 0 else
    for ix in range(d1):
        for jx in range(d2):
            for tx in range(n):
                if (M2[ix,jx,tx] > 0):
                    T[ix,jx,tx] = (1 - A[ix,jx,tx]*(M1[ix,jx,tx]/M2[ix,jx,tx])) #instead of abs(.)
    return T;

def obtainMean(M):
    # M is a (d1,d2,n) matrix
    import numpy as np
    M_avg = np.mean(M, axis = 2)
    M_std = np.std(M,axis = 2)
    return M_avg, M_std;

def obtainKDE(M,M_std,eval_points):
    # M is a (d1,d2,n) matrix
    import numpy as np
    import math
    import scipy.spatial.distance as ssd
    d1 = M.shape[0]
    d2 = M.shape[1]
    n = M.shape[2]
    nx = eval_points.shape[2]
    V = np.zeros((d1,d2,nx))
    
    def takeDists(X,Y):
        n1 = len(X)
        n2 = len(Y)
        d = np.zeros((n1,n2))
        for ii in range(n1):
            for jj in range(n2):
                d[ii,jj] = abs(X[ii] - Y[jj])
        return d;
    
    for ix in range(d1):
        for jx in range(d2):
            yij = M[ix,jx]
            sd = M_std[ix,jx]#np.std(yij)
            sigma = 1.06*sd*math.pow(n,-1/5)
            xeval = eval_points[ix,jx]
            d = takeDists(yij,xeval)
            dsq = np.square(d)
            k2 = np.exp(-.5*(1/sigma**2)*dsq) / np.sqrt(2*(math.pi)*(sigma**2))
            vij = np.mean(k2,axis = 0)
            V[ix,jx,:] = vij
    return V;

def obtainEvalPoints(M1avg,M1std,M2avg,M2std,N):
    # M is a (d1,d2,n) matrix
    import numpy as np
    #import math
    d1 = M1avg.shape[0]
    d2 = M1avg.shape[1]
    #n = M1.shape[2]
#    y1 = min(np.amin(M1), np.amin(M2))
#    y2 = max(np.amax(M1), np.amax(M2))
    # eval_points = np.linspace(y1,y2,num = N)
    minmax = np.zeros((d1,d2,2))
    eval_points = np.zeros((d1,d2,N))
    for ii in range(d1):
        for jj in range(d2):
            min1 = M1avg[ii,jj] - 3*M1std[ii,jj]
            max1 = M1avg[ii,jj] + 3*M1std[ii,jj]
            min2 = M2avg[ii,jj] - 3*M2std[ii,jj]
            max2 = M2avg[ii,jj] + 3*M2std[ii,jj]
            eval_points[ii,jj] = np.linspace(min(min1,min2),max(max1,max2),num=N)
    # for now:
    #eval_points = np.linspace(-30,2,num=N)
    return eval_points;

def obtainThresholded_old(M,S):
    import numpy as np
    d1 = M.shape[0]
    d2 = M.shape[1]
    V = np.zeros(M.shape)
    for ii in range(d1):
        for jj in range(d2):
            #V[ii,jj] = (M[ii,jj] > S[ii,jj]) #if comparing to own std
            V[ii,jj] = (M[ii,jj] > S[jj]) # for one common thresholding vector
    return V;

def obtainThresholded(M,S):
    import numpy as np
    d1 = M.shape[0]
    d2 = M.shape[1]
    new_shape = np.concatenate(([len(S)],M.shape))
    V = np.zeros(new_shape)
    for ti in range(len(S)):
        for ii in range(d1):
            for jj in range(d2):
                V[ti,ii,jj] = M[ii,jj] < S[ti] # 1 is good, 0 is bad
    return V;

def obtainFairProportions(M):
    import numpy as np
    ntols = M.shape[0]
    nqs = M.shape[1]
    nthets = M.shape[2]
    n = M.shape[3]
    V = np.zeros((nqs,nthets,ntols))
    for ti in range(ntols):
        for ii in range(nqs):
            for jj in range(nthets):
                V[ii,jj,ti] = np.sum(M[ti,ii,jj]) / n
    return V;










# end here