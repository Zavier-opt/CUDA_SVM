#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Feb 26 15:18:53 2022

@author: dinglin
"""

file_direct = '/Users/dinglin/Desktop/Operations Research/ISyE6679 Computational Methods/Final Project/Dataset/MUSK_training.csv'

import numpy as np
import pandas as pd
from pandas import DataFrame
from libsvm.svmutil import *
import time

def process_features(features_df):
    features = []
    m = features_df.shape[0]
    n = features_df.shape[1]
    for i in range(m):
        features.append([])
        for j in range(n):
            features[i].append(features_df.iloc[i,j])
    return features

clean_iris_data = pd.read_csv(file_direct,header=0)
labels = list(clean_iris_data.iloc[:,167])
raw_features = clean_iris_data.iloc[:,1:167]
features = process_features(raw_features)

T1 = time.time()
prob1 = svm_problem(labels, features)

param1 = svm_parameter()
param1.kernel_type = LINEAR
param1.C = 0.01

m=svm_train(prob1, param1)
T2 = time.time()
print('Running Time:%sms' % ((T2 - T1)*1000))

p_label, p_acc, p_val = svm_predict(labels,features,m)
ACC, MSE, SCC = evaluations(labels, p_label)
