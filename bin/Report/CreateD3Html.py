#!/usr/bin/python

import sys,os
import re
import json

json_f = sys.argv[1]
prefix = sys.argv.pop()

html1 = '''<!DOCTYPE html>
<meta charset="utf-8">
<style>

.node {
  stroke: #fff;
  stroke-width: 1.5px;
}

.link {
  stroke: #999;
  stroke-opacity: .6;
}

.nodetext {
	font-size: 12px ;
	font-family: SimSun;
	fill:#000000;
}

.linetext {
	font-size: 12px ;
	font-family: SimSun;
	fill:#0000FF;
	fill-opacity:0.0;
}

</style>
<body>
<script src="https://cdnjs.cloudflare.com/ajax/libs/d3/3.5.5/d3.min.js"></script>
<script>

var width = 1024,
    height = 800;

var color = d3.scale.category20();

var force = d3.layout.force()
    .charge(-480)
    .linkDistance(100)
    .size([width, height]);

var svg = d3.select("body").append("svg")
    .attr("width", width)
    .attr("height", height);

d3.json("'''

html2= '''", function(error, graph) {
  if (error) throw error;

  force
      .nodes(graph.nodes)
      .links(graph.links)
      .start();

  var link = svg.selectAll(".link")
      .data(graph.links)
      .enter().append("line")
      .attr("class", "link")
      //.style("stroke-width", function(d) { return Math.sqrt(d.value); });
      .style("stroke-width", function(d) { return d.value; });
	  
  var node = svg.selectAll(".node")
      .data(graph.nodes)
      .enter().append("circle")
      .attr("class", "node")
      //.attr("r", 10)
	  .attr("r", function(d) {return d.size; })
      .style("fill", function(d) { return color(d.group); })
      .call(force.drag);

  //node.append("title")
  //    .text(function(d) { return d.name; });
	  
  var text_dx = 0;
  var text_dy = 0;
			
  var nodes_text = svg.selectAll(".nodetext")
								.data(graph.nodes)
								.enter()
								.append("text")
								.attr("class","nodetext")
								.attr("dx",text_dx)
								.attr("dy",text_dy)
								.text(function(d){
									return d.name;
								});
								
  force.on("tick", function() {
    link.attr("x1", function(d) { return d.source.x; })
        .attr("y1", function(d) { return d.source.y; })
        .attr("x2", function(d) { return d.target.x; })
        .attr("y2", function(d) { return d.target.y; });

    node.attr("cx", function(d) { return d.x; })
        .attr("cy", function(d) { return d.y; });
		
	nodes_text.attr("x", function(d){ return d.x })
	    .attr("y", function(d){ return d.y });
  });
});

</script>'''

fout = open('./' + prefix + '.d3.html', 'wb')
print >>fout, '%s%s%s' % (html1, json_f, html2)
fout.close()
 
