#--------------------------
# Reaction Rate Parameters
#--------------------------
rxn_type = absorption
#--------------------------

[Mesh]
  [file]
    type = FileMeshGenerator
    file = mesh_in.e
  []
[]

[Adaptivity]
  marker = error_combo
  steps = 4
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
      refine = 0.3
      coarsen = 0.0
    []
    [rel_error]
      type = ValueThresholdMarker
      invert = true
      coarsen = 1e-1
      refine = 5e-2
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
  particles = 1000
  inactive_batches = 50
  batches = 200
  
  source_strength = 2E4

  verbose = true
  #assume_separate_tallies = true
  skip_statepoint = true

  [Tallies]
    [reactions]
      type = MeshTally
      score = '${rxn_type} flux fission'
      name = 'interest flux fission' #interest used as name instead of rxn score name bc of referential 'confusion'
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
    tally_score = '${rxn_type}'
  []
  [min_rel_err]
    type = TallyRelativeError
    value_type = min
    tally_score = '${rxn_type}'
  []
  [avg_rel_err]
    type = TallyRelativeError
    value_type = average
    tally_score = '${rxn_type}'
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
