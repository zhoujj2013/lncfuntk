import os, sys
import re
from scipy import stats
from statsmodels.sandbox.stats.multicomp import multipletests

#.sandbox.stats.multicomp.multipletests

def usage():
	print '\nPerform enrichment analysis for lncRNAs within network.\n'
	print 'Author: zhoujj2013@gmail.com\n'
	print 'Usage: '+sys.argv[0]+' <file1> '
	print 'Example: python ' + sys.argv[0] + ''
	print ''
	sys.exit(2)


if __name__ == "__main__":
	if len(sys.argv) < 2:
		usage()
	
	informative_hub, gene2go, go2gene = sys.argv[1:]
	prefix = "lncFunNet"
	
	# read in gene2go and go2gene
	fh = open(gene2go,'rb')
	gene2go = {}
	while True:
		l = fh.readline()
		if len(l) == 0:
			break
		lc = l.strip('\n').split('\t')
		name = lc.pop(0)
		if lc[0] != 'NA':
			gene2go[name] = lc
	fh.close()
	
	fh = open(go2gene, 'rb')
	go2gene = {}
	go_info = {}
	while True:
		l = fh.readline()
		if len(l) == 0:
			break
		lc = l.strip('\n').split('\t')
		go_id = lc.pop(0)
		desc = lc.pop(0)
		go_info[go_id] = desc
		go2gene[go_id] = lc
	fh.close()
	
	# background analysis
	total_gene = len(gene2go.keys())
	
	# output tow file result
	fo_raw = open('./' + prefix + '.GO.enrich.raw.txt', 'wb')
	fo = open('./' + prefix + '.GO.enrich.txt', 'wb')
	# go enrichment, this is the key step of the project
	fh = open(informative_hub, 'rb')
	enrich = {}
	while True:
		l = fh.readline()
		if len(l) == 0:
			break
		lc = l.strip('\n').split('\t')
		total_subset_gene = lc[7]
		gene_name = lc[0]
		ensembl_id = lc[0]
		
		# store subset gene
		subset = {}
		subset_arr = lc[-2].split(',')
		for g in subset_arr:
			subset[g] = 1

		# for every go term, do a test
		go_arr = lc[-1].split(',')
		p_arr=[]
		
		if len(go_arr) <= 10:
			print >>fo, lc[0] + "\tNA\tNA\tNA\t1\t1\tNA"
			continue
		
		output = []
		for go in go_arr:
			out = []
			total_go_gene = len(go2gene[go])
			go2gene_subset = []
			total_subset_go_gene = 0
			for g in go2gene[go]:
				if g in subset:
					total_subset_go_gene = total_subset_go_gene + 1
					go2gene_subset.append(g)
			
			# this test result can be replaced by fisher's exact test, which will save computational time.
			# for hypergeometric test
			# p_value = stats.hypergeom.sf(int(total_subset_go_gene)-1, int(total_gene), int(total_go_gene), int(total_subset_gene))

			# for fisher's excact test
			# devide in tow group: cluster and non-cluster, tow properties: GO, non-GO
			cluster_and_go = int(total_subset_go_gene)
			cluster_and_nongo = int(total_subset_gene) - int(total_subset_go_gene)

			noncluster_and_go = int(total_go_gene) - cluster_and_go
			noncluster_and_nongo = int(total_gene) - cluster_and_go - cluster_and_nongo - noncluster_and_go
			
			#print str(cluster_and_go) + '\t' + str(noncluster_and_go) + '\t' + str(cluster_and_nongo) + '\t' + str(noncluster_and_nongo)
			p_value = stats.fisher_exact([[cluster_and_go, noncluster_and_go],[cluster_and_nongo,noncluster_and_nongo]],alternative='greater')[1]
			p_arr.append(p_value)
			
			# prepare the output	
			#out.append(gene_name)
			out.append(go)
			out.append(go_info[go])
			contingency_table = '[[' + str(cluster_and_go) + ',' + str(noncluster_and_go) + ']' + ',[' + str(cluster_and_nongo) + ',' + str(noncluster_and_nongo) + ']]'
			out.append(contingency_table)
			out.append(','.join(go2gene_subset))
			output.append(out)
		
		p_corrected = multipletests(p_arr, alpha=0.05, method='fdr_bh', returnsorted=False)[1]
		
		#print len(p_corrected)
		for i in range(len(output)):
			gene_name_str = output[i].pop()
			output[i].append(p_arr[i])
			output[i].append(p_corrected[i])
			output[i].append(gene_name_str)
			#print '\t'.join(str(x) for x in output[i])
		
		output_sorted = sorted(output, key=lambda output: output[-2])
		
		# prepare 2 output file
		for i in range(len(output_sorted)):
			if i > 4:
				break
			if i == 0:
				output_sorted[i].insert(0, gene_name)
				print >>fo, '\t'.join(str(x) for x in output_sorted[i])
			else:
				output_sorted[i].insert(0, '')
			
			if output_sorted[i][-2] <= 0.05:
				print >>fo_raw, '\t'.join(str(x) for x in output_sorted[i])

	# close output file handle
	fo_raw.close()
	fo.close()
