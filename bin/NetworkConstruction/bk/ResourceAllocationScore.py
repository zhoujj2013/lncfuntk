#!/usr/bin/python
from __future__ import division
import os, sys
import re
import networkx as nx
from scipy import stats
import math

def usage():
	print '\nThis is the usage function\n'
	print 'Author: zhoujj2013@gmail.com\n'
	print 'Usage: '+sys.argv[0]+' <file1> '
	print 'Example: python ' + sys.argv[0] + ''
	print ''
	sys.exit(2)

def common_neighbors(G, u, v):
	if u not in G:
		raise nx.NetworkXError('u is not in the graph.')
	if v not in G:
		raise nx.NetworkXError('v is not in the graph.')
	return (w for w in G[u] if w in G[v] and w not in (u, v))

def resource_allocation_index(G, ebunch=None):
	def predict(u, v):
		return sum(1 / G.degree(w) for w in common_neighbors(G, u, v))
	return ((u, v, predict(u, v)) for u, v in ebunch)


if __name__ == "__main__":
	if len(sys.argv) < 3:
		usage()
	
	''' start coding here'''
	Coexpr=sys.argv[1]
	Evidence=sys.argv[2]
	
	CoexprG =  nx.read_edgelist(Coexpr, comments='#', delimiter='\t', nodetype=str, data=(('type',str),('direction',str), ('evidence',str)))

	EvidenceG = nx.read_edgelist(Evidence, comments='#', delimiter='\t', nodetype=str, data=(('type',str),('direction',str), ('evidence',str)))
	
	score = {}
	score_arr = []
	for s,t in CoexprG.edges():
		if s not in EvidenceG or t not in EvidenceG:
			continue
		
		#raScore = resource_allocation_index(EvidenceG, [(s,t)])
		#aa = []
		raScore = 0
		for w in common_neighbors(EvidenceG, s, t):
			sc = float(1)/int(EvidenceG.degree(w))
			raScore = raScore + sc
		
		str = s + "#" + t
		score[str] = raScore
		
		if raScore > 0:
			score_arr.append(raScore)
		
		#gg      NA      co-express
		#print s+"\t"+t+"\tgg\t",
		#print raScore,
		#print "\tco-express"
		#print ";".join(aa)

	standard_deviation = stats.tstd(score_arr)
	mean = stats.tmean(score_arr)

	score_arr_new = []

	for k,v in score.items():
		if v == 0:
			continue
		
		zscore = (v - mean)/standard_deviation
		new_score = 0
		if zscore > 2:
			new_score = 1
		elif zscore < -2:
			continue
		else:
			score_arr_new.append(math.log10(v))
	
	max_value = max(score_arr_new)
	min_value = min(score_arr_new)

	for k,v in score.items():
		if v == 0:
			continue
		zscore = (v - mean)/standard_deviation
		new_score = 0
		if zscore > 2:
			new_score = 1
		elif zscore < -2:
			continue
		else:
			log_score = math.log10(v)
			scaled_score = (log_score - min_value)/(max_value - min_value)
			new_score = scaled_score
		
		(s, t) = k.split("#")
		
		print s+"\t"+t+"\tgg\t",
		print new_score,
		print "\tco-express"
		#print ";".join(aa)
