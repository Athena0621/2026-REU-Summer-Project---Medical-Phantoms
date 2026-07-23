import openmc
import numpy as np
import math
names = ['Skeletal bone','Skin','Lungs','Brain','Spinal Cord','Red Bone Marrow','Liver','Kidneys','Testes','Urinary Bladder','Gallbladder','Heart','Salivary Glands','Thymus','Thyroid','Oesophagus','Spleen','Pancreas','Stomach','Adipose Tissue','Muscle Tissue','Breast','Eye Lenses','Eyes','Prostate','Adrenals','Small intenstine','Lower Colon','Upper Colon','Remainder','Air']

Materials = openmc.Materials.from_xml('../external_data/materials.xml')
mats = dict(zip(names, Materials))
#is all hydrogen in tissue in water? DNA, if not whats the actual fraction?

side_length = 10  #cm
minx = openmc.XPlane(x0=-side_length/2)
maxx = openmc.XPlane(x0=side_length/2)
miny = openmc.YPlane(y0=-side_length/2)
maxy = openmc.YPlane(y0=side_length/2)
minz = openmc.ZPlane(z0=-side_length/2)
maxz = openmc.ZPlane(z0=side_length/2)

cube_region = +minx&-maxx&+miny&-maxy&+minz&-maxz
name = 'Muscle Tissue'
tissue = openmc.Cell(name = name)
tissue.fill = mats[name]
tissue.region = cube_region

bound_sphere = -openmc.Sphere(r = side_length *2, boundary_type = 'vacuum')

gap = openmc.Cell(name = 'gap')
gap.region = ~cube_region & bound_sphere

root = openmc.Universe(universe_id = 0, name = 'root universe', cells = [tissue, gap])

geom = openmc.Geometry(root)

point = openmc.stats.Point(([-side_length/2,0,0]))
#point = openmc.stats.Point(([0,0,0]))
src = openmc.IndependentSource(space=point,
                               particle = 'photon',
                               energy = openmc.stats.Discrete([2E4], [1.0]))

settings = openmc.Settings()
settings.photon_transport = True
settings.run_mode = 'fixed source'
settings.source = [src]
settings.batches = 100
#settings.inactive = 10
settings.particles = 10000

mesh = openmc.RegularMesh()
mesh.dimension = [1]*3
mesh.lower_left = [-side_length/2]*3
mesh.upper_right= [side_length/2]*3

mesh_filter = openmc.MeshFilter(mesh)

part_filter = openmc.ParticleFilter('photon')

current = openmc.Tally(name = 'current')
current.filters = [mesh_filter, part_filter]
current.scores = ['current','flux']

tally = openmc.Tally(name = 'reactions')
tally.filters = [mesh_filter, part_filter]
tally.scores = ['coherent-scatter','incoherent-scatter', 'photoelectric','pair-production','heating']

tallies = openmc.Tallies([current,tally])

plot = openmc.Plot()
plot.pixels = (250,250)
plot.filename ='Tissue_Cube'
plot.width = (4*side_length, 4*side_length)

model = openmc.model.Model()
model.materials = Materials
model.geometry = geom
#model.tallies = tallies
model.settings = settings
model.plots = openmc.Plots([plot])
model.export_to_model_xml()

openmc.plot_geometry(output = True)

sp = model.run()






     

