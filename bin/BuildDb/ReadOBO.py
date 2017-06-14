import sys,os
import networkx as nx
import re

def readobo(obofile, prefix):
	import networkx as nx
	import re
	oboin = open (obofile, 'rb')
	
	flag = 0
	arr = []
	G = nx.DiGraph()
	
	while True:
		l = oboin.readline()
		if len(l) == 0:
			break
		
		l = l.strip('\n')
		
		if re.search('^$',l) and flag == 1:
			node = ''
			if arr[1] == "[Typedef]":
				pass
			else:
				for i in arr[2:]:
					m = re.match(r'^(?P<k>.*): (?P<v>.*)$', i)
					# for node id
					if m.groupdict()['k'] == 'id':
						node = m.groupdict()['v']
						G.add_node(m.groupdict()['v'])
					# for node annotation
					if m.groupdict()['k'] == 'name':
						G.node[node]['name'] = m.groupdict()['v']
					if m.groupdict()['k'] == 'namespace':
						G.node[node]['namespace'] = m.groupdict()['v']
					if m.groupdict()['k'] == 'def':
						G.node[node]['def'] =  m.groupdict()['v']
					if m.groupdict()['k'] == 'is_obsolete' and m.groupdict()['v'] == 'true':
						G.remove_node(node)
						break
					
					# for node-node relation-ship
					if m.groupdict()['k'] == 'is_a':
						#print m.groupdict()['v']
						#print node
						string = m.groupdict()['v']
						m2 = re.match(r'^(?P<target>GO:\d+) ! .*$', string)
						G.add_edge(m2.groupdict()['target'], node)
						G[m2.groupdict()['target']][node]['type'] = 'is_a'
					
					if m.groupdict()['k'] == 'relationship':
						#print m.groupdict()['v']
						m2 = re.match(r'^(?P<type>\w+) (?P<target>GO:\d+) ! .*', m.groupdict()['v'])

						if m2.groupdict()['type'] == 'has_part':
							G.add_edge(node, m2.groupdict()['target'])
						else:
							G.add_edge(m2.groupdict()['target'], node)

						if m2.groupdict()['type'] == 'has_part':
							G[node][m2.groupdict()['target']]['type'] = m2.groupdict()['type']
						else:
							G[m2.groupdict()['target']][node]['type'] = m2.groupdict()['type']
			arr = []
			
		if re.search("^$",l):
			flag = 1

		if flag == 1:
			arr.append(l)
	oboin.close()
	return G

if __name__ == '__main__':
	obofile, prefix = sys.argv[1:]
	# get output dir
	outdir = os.path.split(obofile)[0]
	
	G = readobo(obofile, prefix)
	# this script designed for getting the level1 and level2 go term id

	# get level 1 go term
	level1 = {}
	for n in nx.nodes(G):
		if len(nx.ancestors(G, n)) <= 1:
			for i in nx.ancestors(G, n):
				level1[i] = G.node[i]['name']
	
	# get level 2 go term
	level2 = {}
	for n in nx.nodes(G):
		if len(nx.ancestors(G, n)) == 2:
			aspect = ""
			for i in nx.ancestors(G, n):
				# check which aspect
				if i in level1:
					aspect = i
			if level1[aspect] not in level2:
				level2[level1[aspect]] = {}
			
			for i in nx.ancestors(G, n):
				level2[level1[aspect]][i] = 1
	# print out level1 and level2 go term
	for item in level2:
		print ">" + item
		for go_id in level2[item]:
			print go_id + "\t" + G.node[go_id]['name']
	
	# this part	for topological sort (have been delect)
		#print item + "\t" + G.node[item]['name'] + "\t",
		#print G.node[item]['namespace']
	
			#print n,
			#print "\t",
			#print nx.ancestors(G, n)
			#print nx.topological_sort(G, nx.ancestors(G, n))
	
	# print out pickle
	nx.write_gpickle(G, outdir + '/' + 'GO.network.pickle')

