import os, sys
import re
import networkx as nx

def usage():
	print '\nThis script designed for getting gene ontology annotation of a gene list.\n'
	print 'Author: zhoujj2013@gmail.com\n'
	print 'Usage: '+sys.argv[0]+' <gene_list> <go_db_dir> <aspect=C|F|P>'
	print ''
	sys.exit(2)


if __name__ == "__main__":
	if len(sys.argv) < 4:
		usage()
	
	gene_list, go_db_dir, aspect = sys.argv[1:]

	species = "GO"
		
	# initialize the aspect hash
	aspect_h = {
		'F':"molecular_function",
		'C':"cellular_component",
		'P':"biological_process"
	}

	# read in gene list file
	g={}
	fh = open(gene_list, 'rb')
	while True:
		l = fh.readline()
		if len(l) == 0:
			break
		lc = l.strip('\n').split('\t')
		if lc[1] == "miRNA":
			continue
		g[lc[0]] = lc[1]
	fh.close()

	# read in go level file
	topgo={}
	fh=open(go_db_dir + '/' + species + '.level12.go')
	aspect_id = ''
	while True:
		l = fh.readline()
		if len(l) == 0:
			break
		l = l.strip('\n')
		flag=0
		if re.match('^>(\S+)',l):
			m=re.match('^>(\S+)',l)
			aspect_id = m.group(1)
			topgo[aspect_id]={}
		elif re.match('^(GO:\d+)\t(.*)',l):
			#print l
			m=re.match('^(GO:\d+)\t(.*)',l)
			#print m.group(1)
			topgo[aspect_id][m.group(1)] = m.group(2)
	#print topgo
	fh.close()
	
	# read in go annotation
	aspect_arr=aspect.split(',')
	
	anno = {}
	go2gene={}
	
	G = nx.read_gpickle(go_db_dir +'/' + species + '.network.pickle')
	# G.node[go_id]['name']

	fh=open(go_db_dir + '/goa.gaf')
	while True:
		l = fh.readline()
		if len(l) == 0:
			break
		
		if re.match('^\!',l):
			continue

		lc = l.strip('\n').split('\t')
		# base on http://www.geneontology.org/GO.evidence.shtml
		# filter ND, IEA and NR annotation records
		if lc[6] == 'ND' or lc[6] == 'IEA' or lc[6] == 'NR':
			continue
		
		gene_name = lc[2]
		# filter out microRNA annotation
		if gene_name not in g:
			continue
		
		go_id = lc[4]
		if go_id not in G.node:
			continue
		
		function_aspect = lc[8]
			
		for i in aspect_arr:
			if i == function_aspect and go_id not in topgo[aspect_h[function_aspect]]:
				if gene_name not in anno:
					anno[gene_name] = {}
				if go_id not in go2gene:
					go2gene[go_id] = {}
				anno[gene_name][go_id] = 1
				go2gene[go_id][gene_name] = 1
				#print gene_name + '\t' + go_id + '\t' + function_aspect

	# output gene2go	
	oh = open('./' + species + '.' + '_'.join(aspect_arr) + '.gene2go', 'wb')
	for gene_name, ensembl_id in g.items():
		if gene_name in anno:
			go_arr=[]
			for go_id in anno[gene_name]:
				go_arr.append(go_id)
			print >>oh, gene_name + '\t' + "\t".join(go_arr)
		else:
			print >>oh, gene_name + '\t' + 'NA'
	oh.close()

	# output go2gene
	oh = open('./' + species + '.' + '_'.join(aspect_arr) + '.go2gene', 'wb')
	for go_id in go2gene:
		gene_arr = go2gene[go_id].keys()
		print >>oh, go_id + '\t' + G.node[go_id]['name'] + '\t' + '\t'.join(gene_arr)
	oh.close()
