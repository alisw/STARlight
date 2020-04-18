## this generated pdgMass.awk
## awk -f pdg.awk  $ROOTSYS/etc/pdg_table.txt

BEGIN {
  counter = 0
  print "function pdg2mass(x) {" > "pdgMass.awk"
}

!/^#/ {
  if (counter == 0) {
    pdg = $3
    mass = $8
    if (pdg > 0) {
      printf("pdgMass[%d] = %e\n", pdg, mass) >> "pdgMass.awk"
      counter = $15
    }
  } else {
    --counter
  }
}

END {
    print "return pdgMass[abs(x)]\n}" >> "pdgMass.awk"
}
