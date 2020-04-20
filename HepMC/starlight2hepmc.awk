## awk script for converting slight.out into HepMC format

function abs(x) { return (x>0 ? x : -x) }

function xyzm2e(x,y,z,m) {
  return sqrt(x*x + y*y + z*z - m*m); ## E^2 = m^2 + p^2
}

BEGIN {
  print "HepMC::Version 2.06.00"
  print "HepMC::IO_GenEvent-START_EVENT_LISTING"
}

/^    PDG ID of produced particle/ {
  pdg_id_gen = $7
}

/^EVENT/ {
# • int: event number
# • int: number of multi paricle interactions
# • double: event scale
# • double: alpha QCD
# • double: alpha QED
# • int: signal process id
# • int: barcode for signal process vertex
# • int: number of vertices in this event
# • int: barcode for beam particle 1
# • int: barcode for beam particle 2
# • int: number of entries in random state list (may be zero)
# • long: optional list of random state integers
# • int: number of entries in weight list (may be zero)
# • double: optional list of weights
  event_number = $2
  num_mpi = "_" ## ignored
  ev_scale = "_" ## ignored
  ev_alpha_QCD = "_" ## ignored
  ev_alpha_QED = "_" ## ignored
  sig_process_id = "_" ## ignored
  sig_process_vtx_barcode = "_" ## ignored
  num_vtx = $4 ##  STARLight nvertices
  beam_part1_barcode = "_" ## ignored
  beam_part2_barcoce = "_" ## ignored
  num_random_state_list = "_" ## ignored
  num_weights = 1
  list_of_weights = 1
  printf("E %d %s %s %s %s %s %s %d %s %s %d %d %e\n",
         event_number,
         num_mpi,
         ev_scale,
         ev_alpha_QCD,
         ev_alpha_QED,
         sig_process_id,
         vtx_barcode,
         num_vtx,
         beam_part1_barcode,
         beam_part2_barcoce,
         num_random_state_list,
         num_weights,
         list_of_weights)
  printf("U GEV MM\n")
}

/^VERTEX/ {
# • int: barcode
# • int: id
# • double: x
# • double: y
# • double: z
# • double: ctau
# • int: number of ”orphan” incoming particles
# • int: number of outgoing particles
# • int: number of entries in weight list (may be zero)
# • double: optional list of weights
  barcode = -$6 ## nv
  id = "_" ## ignored
  x = $2
  y = $3
  z = $4
  ctau = $5
  num_orphan_in = "_" ## ignored
  num_out = $9 ## ndaughters
  num_weight = "_" ## ignored
  printf("V %d %s %e %e %e %e %s %d %s\n",
         barcode,
         id,
         x,
         y,
         z,
         ctau,
         num_orphan_in,
         num_out,
         num_weight)
  sumPx = 0
  sumPy = 0
  sumPz = 0
  sumE = 0
}

/^TRACK/ {
  # • int: barcode
  # • int: PDG id
  # • double: px
  # • double: py
  # • double: pz
  # • double: energy
  # • double: generated mass
  # • int: status code
  # • double: Polarization theta
  # • double: Polarization phi
  # • int: barcode for vertex that has this particle as an incoming particle
  # • int: number of entries in flow list (may be zero)
  # • int, int: optional code index and code for each entry in the flow list
  ntr = $7
  barcode =  "_" ## ignored: should be $7 == STARLight ntr
  pdg_id = $9
  px = $3
  py = $4
  pz = $5
  gen_mass = pdg2mass(pdg_id)
  energy = xyzm2e(px,py,pz,gen_mass)
  status_code = 1
  ## HEPEVT status codes:
  # • 0 : an empty entry with no meaningful information and therefore to be skipped unconditionally
  # • 1 : a final-state particle, i.e. a particle that is not decayed further by the generator (may also include unstable particles that are to be decayed later, as part of the detector simulation). Such particles must  always be labelled ’1’.
  # • 2 : decayed Standard Model hadron or tau or mu lepton, excepting virtual intermediate states thereof  (i.e. the particle must undergo a normal decay, not e.g. a shower branching). Such particles must  always be labelled ’2’. No other particles can be labelled ’2’.
  # • 3 : a documentation entry
  # • 4 : an incoming beam particle
  pol_theta =  "_" ## ignored
  pol_phi = "_" ## ignored
  barcode_vtx_incoming = 0
  num_flow_list = "_" ## ignored
  printf("P %s %d %e %e %e %e %e %d %s %s %d %s\n",
         barcode,
         pdg_id,
         px,
         py,
         pz,
         energy,
         gen_mass,
         status_code,
         pol_theta,
         pol_phi,
         barcode_vtx_incoming,
         num_flow_list);
  sumPx += px
  sumPy += py
  sumPz += pz
  sumE  += energy
  if (ntr == num_out-1) {
    ## add the mother particle with status=3 (documentation entry)
    ## without this no primary particles are seen in O2
    gen_mass = sqrt(sumE*sumE - sumPx*sumPx - sumPy*sumPy - sumPz*sumPz)
    printf("P X %d %e %e %e %e %e 3 X X -1 X\n", pdg_id_gen, sumPx, sumPy, sumPz, sumE, gen_mass)
  }
}

END {
  print "HepMC::IO_GenEvent-END_EVENT_LISTING"
}
