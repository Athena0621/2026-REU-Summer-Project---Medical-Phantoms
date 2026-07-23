#------------------------
# Geometrical Information
#------------------------

#------------------------

#------------------------
# Meshing Parameters
#------------------------

#------------------------

#too small source, MOOSE doesn't have default units, ports units form the multi-app.

[Mesh]
  [Cube]
    type = GeneratedMeshGenerator
    dim = 3
    nx = 1
    ny = 1
    nz = 1
    xmax = 35
    ymax = 35
    zmax = 100
    xmin = -35
    ymin = -35
    zmin = -80
  []
[]
  