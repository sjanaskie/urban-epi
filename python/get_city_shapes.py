import osmnx as ox, matplotlib.pyplot as plt
from descartes import PolygonPatch
from shapely.geometry import Polygon, MultiPolygon
ox.config(log_console=True, use_cache=True)

place_names = ['Ho Chi Minh City, Vietnam',
               'Beijing, China', 
               'Jakarta, Indonesia',
               'London, UK',
               'Los Angeles, California, USA',
               'Manila, Philippines',
               'Mexico City, Mexico',
               'Quito, Ecuador',
               'New Delhi, India',
               'Sao Paulo, Brazil',
               'New York, New York, USA',
               'Seoul, South Korea',
               'Singapore, Singapore',
               'Tokyo, Japan',
               'Nairobi, Kenya',
               'Bangalore, India']

# pass in buffer_dist in meters - notice plural 'gdf_from_places'
cities_20kmbuff = ox.gdf_from_places(place_names, gdf_name='global_cities', buffer_dist=20000)
ox.save_gdf_shapefile(cities_20kmbuff, folder='../../data/vector/city_shapes/')