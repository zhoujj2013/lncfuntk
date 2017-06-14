import sys
import os

from sklearn import preprocessing
import numpy as np

min_max_scaler = preprocessing.MinMaxScaler()

fh = open(sys.argv[1], 'rb')

X = []
while True:
	l = fh.readline()
	if len(l) == 0:
		break
	lc = l.strip("\n").split("\t")
	X.append([float(i) for i in lc])

x_train_temp = np.array(X)

x_train_temp2 = min_max_scaler.fit_transform(x_train_temp)

x_train = x_train_temp2

for l in x_train:
	print "\t".join([str(i) for i in l])
