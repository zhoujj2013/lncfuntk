import os, sys
import re

def usage():
	print '\nCalculate FIS for each lncRNA gene\n'
	print 'Author: zhoujj2013@gmail.com \n'
	print 'Modified: Tue Apr 18 17:07:22 HKT 2017\n'
	print 'Usage: python '+sys.argv[0]+' data_matrix pretrained_weight_value'
	print ''
	sys.exit(2)

# check args
if len(sys.argv) < 2:
	usage()

f1 = sys.argv[1]
weight_value_f = sys.argv[2]

X = []
fh1 = open(f1, 'rb')
while True:
	l = fh1.readline()
	if len(l) == 0:
		break
	lc = l.strip("\n").split("\t")
	X.append([float(i) for i in lc])
fh1.close()

W = {}
fh2 = open(weight_value_f, 'rb')
while True:	
	l = fh2.readline()
	if len(l) == 0:
		break
	lc = l.strip("\n").split("\t")
	W[lc[0]] = float(lc[1])
fh2.close()


for x in X:
	#y = x[0]*0.21 + x[1]*4.02 + x[2]*1.56 - 2.09
	# default: y = x[0]*0.22 + x[1]*0.57 + x[2]*0.21
	y = x[0]*W["miRNA_weight"] + x[1]*W["TF_weight"] + x[2]*W["PCG_weight"]
	print y
#miRNA: 0.0284691204883; TF: 0.277011052806; PCG: 0.0891552119955
#residues: 0.987999357778
#intercept: 0.282349397125



