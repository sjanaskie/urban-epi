#! /bin/bash/env python

import osmnx as ox, matplotlib.pyplot as plt
from descartes import PolygonPatch
from shapely.geometry import Polygon, MultiPolygon
import geopandas as gpd
import json
import os, sys

ox.config(log_console=True, use_cache=True, data_folder='data/vector/city_networks/')

indir = "data/vector/city_boundaries/"
for file in os.listdir(indir):
    if file.endswith(".shp"):
        print(os.path.basename(file).split(".")[0]
        continue
else:
    continue

###########################################################################
#
# Los Angeles
#
###########################################################################

place = gpd.read_file(os.path.join(indir, "losangeles.shp"))
place_simple = place.unary_union

# Use retain_all if you want to keep all disconnected subgraphs (e.g. when your places aren't adjacent)
G = ox.graph_from_polygon(place_simple, network_type='drive', retain_all=True)
G_projected = ox.project_graph(G)

# save the shapefile to disk
#name = os.path.basename("beijing.shp")).split(".")[0]  # make better place_names
ox.save_graph_shapefile(G_projected, filename="losangeles")

area = ox.project_gdf(place).unary_union.area
stats = ox.basic_stats(G, area=area)
# save to file:
def ensure_dir(file_path):
    directory = os.path.dirname(file_path)
    if not os.path.exists(directory):
        os.makedirs(directory)

path = 'data/vector/city_networks/losangeles'
ensure_dir(path)
with open(path + '_stats.json', 'wb') as f:
    json.dump(stats, f)

###########################################################################
#
# Beijing
#
###########################################################################

place = gpd.read_file(os.path.join(indir, "beijing.shp"))
place_simple = place.unary_union

# Use retain_all if you want to keep all disconnected subgraphs (e.g. when your places aren't adjacent)
G = ox.graph_from_polygon(place_simple, network_type='drive', retain_all=True)
G_projected = ox.project_graph(G)

# save the shapefile to disk
#name = os.path.basename("beijing.shp")).split(".")[0]  # make better place_names
ox.save_graph_shapefile(G_projected, filename="beijing")

area = ox.project_gdf(place).unary_union.area
stats = ox.basic_stats(G, area=area)
# save to file:
def ensure_dir(file_path):
    directory = os.path.dirname(file_path)
    if not os.path.exists(directory):
        os.makedirs(directory)

path = 'data/vector/city_networks/beijing'
ensure_dir(path)
with open(path + '_stats.json', 'wb') as f:
    json.dump(stats, f)
    




###########################################################################
#
# tokyo
#
###########################################################################

place = gpd.read_file(os.path.join(indir, "tokyo.shp"))
place_simple = place.unary_union

# Use retain_all if you want to keep all disconnected subgraphs (e.g. when your places aren't adjacent)
G = ox.graph_from_polygon(place_simple, network_type='drive', retain_all=True)
G_projected = ox.project_graph(G)

# save the shapefile to disk
#name = os.path.basename("tokyo.shp")).split(".")[0]  # make better place_names
ox.save_graph_shapefile(G_projected, filename="tokyo")

area = ox.project_gdf(place).unary_union.area
stats = ox.basic_stats(G, area=area)
# save to file:
def ensure_dir(file_path):
    directory = os.path.dirname(file_path)
    if not os.path.exists(directory):
        os.makedirs(directory)

path = 'data/vector/city_networks/tokyo'
ensure_dir(path)
with open(path + '_stats.json', 'wb') as f:
    json.dump(stats, f)




###########################################################################
#
# manila
#
###########################################################################

place = gpd.read_file(os.path.join(indir, "manila.shp"))
place_simple = place.unary_union

# Use retain_all if you want to keep all disconnected subgraphs (e.g. when your places aren't adjacent)
G = ox.graph_from_polygon(place_simple, network_type='drive', retain_all=True)
G_projected = ox.project_graph(G)

# save the shapefile to disk
#name = os.path.basename("manila.shp")).split(".")[0]  # make better place_names
ox.save_graph_shapefile(G_projected, filename="manila")

area = ox.project_gdf(place).unary_union.area
stats = ox.basic_stats(G, area=area)
# save to file:
def ensure_dir(file_path):
    directory = os.path.dirname(file_path)
    if not os.path.exists(directory):
        os.makedirs(directory)

path = 'data/vector/city_networks/manila'
ensure_dir(path)
with open(path + '_stats.json', 'wb') as f:
    json.dump(stats, f)






###########################################################################
#
# london
#
###########################################################################

place = gpd.read_file(os.path.join(indir, "london.shp"))
place_simple = place.unary_union

# Use retain_all if you want to keep all disconnected subgraphs (e.g. when your places aren't adjacent)
G = ox.graph_from_polygon(place_simple, network_type='drive', retain_all=True)
G_projected = ox.project_graph(G)

# save the shapefile to disk
#name = os.path.basename("london.shp")).split(".")[0]  # make better place_names
ox.save_graph_shapefile(G_projected, filename="london")

area = ox.project_gdf(place).unary_union.area
stats = ox.basic_stats(G, area=area)
# save to file:
def ensure_dir(file_path):
    directory = os.path.dirname(file_path)
    if not os.path.exists(directory):
        os.makedirs(directory)

path = 'data/vector/city_networks/london'
ensure_dir(path)
with open(path + '_stats.json', 'wb') as f:
    json.dump(stats, f)




###########################################################################
#
# hochiminh
#
###########################################################################

place = gpd.read_file(os.path.join(indir, "hochiminh.shp"))
place_simple = place.unary_union

# Use retain_all if you want to keep all disconnected subgraphs (e.g. when your places aren't adjacent)
G = ox.graph_from_polygon(place_simple, network_type='drive', retain_all=True)
G_projected = ox.project_graph(G)

# save the shapefile to disk
#name = os.path.basename("hochiminh.shp")).split(".")[0]  # make better place_names
ox.save_graph_shapefile(G_projected, filename="hochiminh")

area = ox.project_gdf(place).unary_union.area
stats = ox.basic_stats(G, area=area)
# save to file:
def ensure_dir(file_path):
    directory = os.path.dirname(file_path)
    if not os.path.exists(directory):
        os.makedirs(directory)

path = 'data/vector/city_networks/hochiminh'
ensure_dir(path)
with open(path + '_stats.json', 'wb') as f:
    json.dump(stats, f)




###########################################################################
#
# newyork
#
###########################################################################

place = gpd.read_file(os.path.join(indir, "newyork.shp"))
place_simple = place.unary_union

# Use retain_all if you want to keep all disconnected subgraphs (e.g. when your places aren't adjacent)
G = ox.graph_from_polygon(place_simple, network_type='drive', retain_all=True)
G_projected = ox.project_graph(G)

# save the shapefile to disk
#name = os.path.basename("newyork.shp")).split(".")[0]  # make better place_names
ox.save_graph_shapefile(G_projected, filename="newyork")

area = ox.project_gdf(place).unary_union.area
stats = ox.basic_stats(G, area=area)
# save to file:
def ensure_dir(file_path):
    directory = os.path.dirname(file_path)
    if not os.path.exists(directory):
        os.makedirs(directory)

path = 'data/vector/city_networks/newyork'
ensure_dir(path)
with open(path + '_stats.json', 'wb') as f:
    json.dump(stats, f)





###########################################################################
#
# saopaulo
#
###########################################################################

place = gpd.read_file(os.path.join(indir, "saopaulo.shp"))
place_simple = place.unary_union

# Use retain_all if you want to keep all disconnected subgraphs (e.g. when your places aren't adjacent)
G = ox.graph_from_polygon(place_simple, network_type='drive', retain_all=True)
G_projected = ox.project_graph(G)

# save the shapefile to disk
#name = os.path.basename("saopaulo.shp")).split(".")[0]  # make better place_names
ox.save_graph_shapefile(G_projected, filename="saopaulo")

area = ox.project_gdf(place).unary_union.area
stats = ox.basic_stats(G, area=area)
# save to file:
def ensure_dir(file_path):
    directory = os.path.dirname(file_path)
    if not os.path.exists(directory):
        os.makedirs(directory)

path = 'data/vector/city_networks/saopaulo'
ensure_dir(path)
with open(path + '_stats.json', 'wb') as f:
    json.dump(stats, f)












