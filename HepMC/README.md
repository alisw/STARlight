# author: Christoph Mayer

awk -f pdg.awk $ROOTSYS/etc/pdg_table.txt ## this generates pdgMass.awk included in starlight2hepmc.awk
starlight slight.in | tee slight.log
cat slight.log slight.out | awk -f pdgMass.awk -f starlight2hepmc.awk > starlight.hepmc
