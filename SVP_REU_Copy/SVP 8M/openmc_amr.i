#--------------------------
# Reaction Rate Parameters
#--------------------------
rxn_type = total
dose_score = heating
#--------------------------

[Mesh]
  [file]
    type = FileMeshGenerator
    file = mesh_in.e
  []
[]

[Adaptivity]
  marker = error_combo
  steps = 10
  [Indicators]
    [optical_depth]
      type = ElementOpticalDepthIndicator
      rxn_rate = '${rxn_type}'
      h_type = 'max'
    []
  []
  [Markers]
    [depth_frac]
      type = ErrorFractionMarker
      indicator = optical_depth
      refine = 0.2
      coarsen = 0.0
    []
    [rel_error]
      type = ValueThresholdMarker
      invert = true
      coarsen = 10e-2
      refine = 7e-2
      variable = interest_rel_error
      third_state = DO_NOTHING
    []
    [error_combo]
      type = BooleanComboMarker
      # Only refine iff the relative error is sufficiently low AND the optical depth is
      # sufficiently large.
      refine_markers = 'rel_error depth_frac'
      # Coarsen based exclusively on relative error.
      coarsen_markers = 'rel_error'
      boolean_operator = and
    []
  []
[]

[Problem]
  type = OpenMCCellAverageProblem
  particles = 100000 #number of particles to small for statistical hit, 1000000 works
  #inactive_batches = 50
  batches = 100
  
  source_strength = 2E4

  #verbose = true
  assume_separate_tallies = true
  skip_statepoint = true

  [Tallies]
    [reactions]
      type = MeshTally
      score = '${rxn_type} ${dose_score} flux fission'
      name = 'reaction interest flux fission' 
      output = 'unrelaxed_tally_std_dev unrelaxed_tally_rel_error'
      block = '0'
      check_tally_sum = false
      normalize_by_global_tally = false
    []
  []
[]

[Postprocessors]
  [num_elem]
    type = NumElements
    elem_filter = active
  []
  [max_rel_err]
    type = TallyRelativeError
    value_type = max
    tally_score = '${dose_score}'
  []
  [min_rel_err]
    type = TallyRelativeError
    value_type = min
    tally_score = '${dose_score}'
  []
  [avg_rel_err]
    type = TallyRelativeError
    value_type = average
    tally_score = '${dose_score}'
  []
[]


[Executioner]
  type = Steady
[]

[Outputs]
  execute_on = 'timestep_end'
  exodus = true
  csv = true
[]
