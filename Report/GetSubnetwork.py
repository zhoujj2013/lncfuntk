#!/usr/bin/python

import networkx as nx
import sys,os
import re

interaction_f = sys.argv[1]
node_lst = sys.argv[2]
prefix = sys.argv.pop()

if os.path.exists(interaction_f):
	G = nx.read_gpickle(interaction_f)

# read in node information
nodeIn = open(node_lst, 'rb')

nodes = []

while True:
	l = nodeIn.readline()
	if len(l) == 0:
		break
	if re.search('^#',l):
		continue
	l = l.strip('\n')
	lc = l.split('\t')
	if lc[0] in nodes:
		continue
	else:
		nodes.append(lc[0])

# get subnetwork
sG = G.subgraph(nodes)

SubDict = nx.degree(sG)
SubDictSort = sorted(SubDict.items(),key=lambda e:e[1],reverse=True)

fout = open('./' + prefix + '.node.degree.txt', 'wb')
for item in SubDictSort:
	if 'BioType' in G.node[item[0]]:
		biotype = G.node[item[0]]['BioType']
	else:
		biotype = 'NA'
	group = ""
	if biotype == 'TF':
		group = 1
	elif biotype == 'miRNA':
		group = 2
	elif biotype == 'lncRNA':
		group = 3
	elif biotype == 'pcg':
		group = 4
	
	print >>fout, "%s\t%s\t%d" % (item[0], item[1], group)

fout.close()


fout1 = open('./' + prefix + '.int.txt','wb')
for line in nx.generate_edgelist(sG, delimiter='\t', data=['type', 'direction', 'evidence']):
	lc = line.split('\t')
	link_value = ''
	if re.search('TF_binding',lc[4]):
		link_value = 2
	elif re.search('within_transcript', lc[4]):
		link_value = 2
	elif re.search('ClipseqMiranda', lc[4]):
		link_value = 2
	else:
		link_value = 1
	
	print >>fout1, "%s\t%s\t%d" % (lc[0], lc[1], link_value)
fout1.close()
