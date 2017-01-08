#!/usr/bin/env python
# -*- coding: utf-8 -*-

#
#    graph_coloring_z3.py - Constraint programming exercice: play with the graph coloring problem
#    Copyright (C) 2012 Axel "0vercl0k" Souchet - http://www.twitter.com/0vercl0k
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

import sys
import time
import pygraphviz as pgv
from z3 import *


#Contributed by @cbrewbs chad@dataculture.co
#Requires z3 >= 4.4.1 
def min_dom_set(graph):
    """Try to dominate the graph with the least number of verticies possible"""
    s = Optimize()
    nodes_colors = dict((node_name, Int('k%r' % node_name)) for node_name in graph.nodes())
    for node in graph.nodes():
           if graph.has_edge(node,node):
	      graph.remove_edge(node,node)
	   s.add(And(nodes_colors[node] >= 0, nodes_colors[node] <= 1))
           if len(graph.in_neighbors(node)) >0:
              dom_neighbor = Sum ([ (nodes_colors[j]) for j in graph.in_neighbors(node) ])
	      s.add(Sum(nodes_colors[node], dom_neighbor ) >=1)
	   else:
	      s.add(nodes_colors[node]==1)
    s.minimize( Sum([ nodes_colors[y] for y in graph.nodes()]) )

    if s.check() == unsat:
        raise Exception('Could not find a solution.')
    else:
        m = s.model()
        return dict((name, m[color].as_long()) for name, color in nodes_colors.iteritems())


def build_graph(path):
    G = pgv.AGraph(path)
    return G

def main(argc, argv):
    path = argv[1]
    outName = argv[2]
    G =  build_graph(path)
    
    s = min_dom_set(G)

    color_available = [
            'red',
            'blue'
    ]

    dom_size = 0
    for node in G.nodes_iter():
        n = G.get_node(node)
        n.attr['color'] = color_available[s[node]]
	if s[node] != 0:
		dom_size = dom_size +1

    #G.layout('dot')
    
    if len(G.nodes()) <1000:
        G.draw('./%s_min_dom_dot.pdf' % outName, format='pdf', prog='dot')
    G.draw('./%s_min_dom_neato.pdf' % outName, format='pdf', prog='neato',args='-Gmaxiter=5')
    os.system('echo "%s" > %s' % (G.string(), "%s_min_dom.gv" % outName ))
    os.sys.stdout.write(str(dom_size))
    return 0

if __name__ == '__main__':
    sys.exit(main(len(sys.argv), sys.argv))
