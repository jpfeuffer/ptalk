#!/bin/bash
export PATH="$PATH:/home/sachsenb/OMS/OpenMS-build/bin"
export FASTA="uniprot_yeast_reviewed_isoforms_ups1_crap.fasta"

#input data
export DATA_PATH="./MZML"
export RESULT_PATH="./RESULTS"

ProteomicsLFQ -in ${DATA_PATH}/*.mzML -ids ${DATA_PATH}/*.idXML -design ${DATA_PATH}/experimental_design.tsv -fasta ${FASTA}_td.fasta -targeted_only "true" -mass_recalibration "false"  \
-out ${RESULT_PATH}/UPS1.mzTab -threads 12 -out_msstats ${RESULT_PATH}/UPS1.csv -out_cxml ${RESULT_PATH}/UPS1.consensusXML -debug 667


