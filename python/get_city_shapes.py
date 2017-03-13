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
for place in place_names:
    name = (place.replace(",","").replace(" ","")) # make better place_names
    print("getting shape of: " + name) 
    city_20kmbuff = ox.gdf_from_place(place, buffer_dist=20000)
    city_20kmbuff['place_name'] = name # overwrite place_names
    ox.save_gdf_shapefile(city_20kmbuff, filename=name, folder='../../data/vector/city_shapes/')
