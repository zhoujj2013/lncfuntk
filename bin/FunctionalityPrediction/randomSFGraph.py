
import os, sys
import networkx as nx

num_node = sys.argv[1]
num_edge = sys.argv[2]
pvalue = sys.argv[3]

G = nx.powerlaw_cluster_graph(int(num_node),int(num_edge),float(pvalue))

#import matplotlib.pyplot as plt
#from matplotlib.backends.backend_pdf import PdfPages
#
#plt.figure(figsize=(50, 50))
#nx.draw_spring(G)
#pp = PdfPages('Graph.spring.' + pvalue + '.pdf')
#plt.savefig(pp, format='pdf')
#pp.close()
#
#plt.figure(figsize=(50, 50))
#nx.draw_circular(G)
#pp = PdfPages('Graph.circular.' + pvalue + '.pdf')
#plt.savefig(pp, format='pdf')
#pp.close()

for a,b in G.edges():
	print str(a) + "\t" + str(b)

#deg = nx.degree(G)

#for i in deg.items():
#	print >>sys.stderr, i 
