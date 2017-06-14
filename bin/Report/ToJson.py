#!/usr/bin/python

import sys,os
import re
import json

interaction_f = sys.argv[1]
node_f = sys.argv[2]
prefix = sys.argv.pop()

NetJson = {}

NetJson['nodes'] = []
NetJson['links'] = []

node = {}

i = 0
no = open(node_f, 'rb')
while True:
	l = no.readline()
	if len(l) == 0:
		break
	if re.search('^#',l):
		continue
	l = l.strip('\n')
	lc = l.split('\t')
	nodeH = {}
	nodeH['name'] = lc[0]
	nodeH['size'] = int(lc[1])
	nodeH['group'] = int(lc[2])

	NetJson['nodes'].append(nodeH)
	
	node[lc[0]] = i
	
	i = i + 1
no.close()

inter = open(interaction_f, 'rb')
while True:
	l = inter.readline()
	if len(l) == 0:
		break
	if re.search('^#',l):
		continue
	l = l.strip('\n')
	lc = l.split('\t')
	
	linkH = {}
	linkH['source'] = node[lc[0]]
	linkH['target'] = node[lc[1]]
	linkH['value'] = int(lc[2])
	NetJson['links'].append(linkH)

inter.close()


encodedjson = json.dumps(NetJson, indent=4)

fout = open('./sn.json', 'wb')
print >>fout, encodedjson
fout.close()

