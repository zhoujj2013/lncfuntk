#!/usr/bin/python

import networkx as nx
import sys,os
import re

interaction_f = sys.argv[1]
prefix = sys.argv.pop()

if os.path.exists('./' + prefix + '.network.pickle'):
	G = nx.read_gpickle('./' + prefix + '.network.pickle')
else:
	G = nx.read_edgelist(interaction_f, comments='#', delimiter='\t', nodetype=str, data=(('type',str),('direction',str), ('evidence',str)))
	
	# get all nodes in the graph
	NodeDegree = nx.degree(G)
	
	# Read in the node attributes
	NodeAtt = open(sys.argv[2], 'rb')
	Sym = {}
	BioType = {}
	TargetNodeSet = {}
	while True:
		l = NodeAtt.readline()
		if len(l) == 0:
			break
		if re.search('^#',l):
			continue
		l = l.strip('\n')
		lc = l.split('\t')
		if lc[0] in NodeDegree:
			Sym[lc[0]] = lc[0]
			BioType[lc[0]] = lc[1]
			TargetNodeSet[lc[0]] = 1
	
	# remove the node not in the prefer list
	for ensembl_id, degree_value in NodeDegree.items():
		if ensembl_id not in TargetNodeSet:
			G.remove_node(ensembl_id)
	
	#for item in Sym:
	#	print "%s\t%s" % (item, Sym[item])
	# ENSMUSG00000031934 print G.node['ENSMUSG00000031934']['Sym']
	nx.set_node_attributes(G, 'Sym', Sym)

	nx.set_node_attributes(G, 'BioType', BioType)
	nx.write_gpickle(G, './' + prefix + '.network.pickle')

# output degree distribution
degreeLst = nx.degree_histogram(G)
fout = open('./' + prefix + '.degree_histogram.txt','wb')
for i in range(0,len(degreeLst)):
	print >>fout, "%d\t%d" % (i,degreeLst[i])
fout.close()


# output node degree
dgDict = nx.degree(G)
dgDictSort = sorted(dgDict.items(),key=lambda e:e[1],reverse=True)

fout = open('./' + prefix + '.node.degree.txt', 'wb')
for item in dgDictSort:
	if 'Sym' in G.node[item[0]]:
		name = G.node[item[0]]['Sym']
	else:
		name = 'NA'
	if 'BioType' in G.node[item[0]]:
		biotype = G.node[item[0]]['BioType']
	else:
		biotype = 'NA'
	
	print >>fout, "%s\t%s\t%s\t%d" % (item[0], name, biotype, item[1])
fout.close()

# output the network (Tow format)
fout1 = open('./' + prefix + '.int.txt','wb')
#fout2 = open('./' + prefix + '.int.mgi.txt', 'wb')
for line in nx.generate_edgelist(G, delimiter='\t', data=['type', 'direction', 'evidence']):
	# output ensembl
	print >>fout1, line
	# output mgi
	#lc = line.split('\t')
	#print >>fout2, "%s\t%s\t%s\t%s\t%s" % (G.node[lc[0]]['Sym'], G.node[lc[1]]['Sym'], lc[2], lc[3], lc[4])
fout1.close()
#fout2.close()

# output general information of the graph
print "Directed Graph: %s" % (nx.is_directed(G))
print nx.info(G)
print "Graph density: %s" % (nx.density(G))
