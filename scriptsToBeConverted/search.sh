#!bin/bash
export PATH="$PATH:/home/sachsenb/OMS/OpenMS-build/bin"
export PATH="$PATH:/home/sachsenb/OpenMS/THIRDPARTY/Linux/64bit/Percolator"
export MSGF_PATH="/home/sachsenb/OpenMS/THIRDPARTY/All/MSGFPlus/MSGFPlus.jar"
export FASTA="uniprot_yeast_reviewed_isoforms_ups1_crap.fasta"

#input data
export DATA_PATH="./MZML"

# perform search, score calibration, and PSM-level q-value/PEP estimation
for f in ${DATA_PATH}/*.mzML; do
  echo $f
  fn=${f%.mzML} # filename and path without mzML extension
  # search with default fixed and variable mods
  MSGFPlusAdapter -in ${f} -out ${fn}.idXML -database ${FASTA}_td.fasta -executable ${MSGF_PATH} -max_precursor_charge 5 -threads 5 
  # annotate target/decoy and protein links
  PeptideIndexer -fasta ${FASTA}_td.fasta -in ${fn}.idXML -out ${fn}.idXML -enzyme:specificity none
  # run percolator so we get well calibrated PEPs and q-values
  PSMFeatureExtractor -in ${fn}.idXML -out ${fn}.idXML 
  PercolatorAdapter -in ${fn}.idXML -out ${fn}.idXML -percolator_executable percolator -post-processing-tdc -subset-max-train 100000 
  FalseDiscoveryRate -in ${fn}.idXML -out ${fn}.idXML -algorithm:add_decoy_peptides -algorithm:add_decoy_proteins 
 # pre-filter to 5% PSM-level FDR to reduce data
  IDFilter -in ${fn}.idXML -out ${fn}.idXML -score:pep 0.05 
 # switch to PEP score
  IDScoreSwitcher -in ${fn}.idXML -out ${fn}.idXML -old_score q-value -new_score MS:1001493 -new_score_orientation lower_better -new_score_type "Posterior Error Probability" 
done

