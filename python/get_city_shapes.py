#! /bin/bash/env python

import osmnx as ox, matplotlib.pyplot as plt
from descartes import PolygonPatch
from shapely.geometry import Polygon, MultiPolygon
import json
import os, sys
from places import *

ox.config(log_console=True, use_cache=True, data_folder='../../data/vector/city_shapes/')

def ensure_dir(file_path):
    directory = os.path.dirname(file_path)
    if not os.path.exists(directory):
        os.makedirs(directory)


for place in places:
    name = (place.replace(",","").replace(" ","")) # make better place_names
    print('working on: ', name)

    #make a geodataframe of the street network (outline) from openstreetmap place names
    # use retain_all if you want to keep all disconnected subgraphs (e.g. when your places aren't adjacent)
    G = ox.graph_from_place(place, network_type='drive', retain_all=True)
    G = ox.project_graph(G)
    
    ox.save_graph_shapefile(gdf, filename=name)
    