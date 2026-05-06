#!/bin/bash
#SBATCH --job-name=busco_filtered
#SBATCH -n 1
#SBATCH -N 1
#SBATCH -c 12
#SBATCH --mem=20G
#SBATCH --qos=general
#SBATCH --partition=general
#SBATCH --mail-user=alex.frutos@uconn.edu
#SBATCH --mail-type=ALL
#SBATCH --constraint=AVX2
#SBATCH -o %x_%j.out
#SBATCH -e %x_%j.err

module load busco/5.4.5

# Input and output
ASSEMBLY="../data/pilon_polish/pilon_polished.filtered_3kb.fasta"
OUTDIR="../data/busco/busco_filtered_3kb"
DATABASE="/isg/shared/databases/busco/odb10/sauropsida_odb10"

mkdir -p ${OUTDIR}

# BUSCO parameters: 
# -i = input assembly FASTA 
# -o = output name 
# -l = lineage dataset (reference gene set) 
# -m genome = genome mode 
# -c 12 = use 12 threads 
# --out_path = output directory
# -f = overwrite existing output

# Run BUSCO on filtered assembly
busco \
  -i ${ASSEMBLY} \
  -o busco_sauropsida_filtered_3kb \
  -l ${DATABASE} \
  -m genome \
  -c 12 \
  --out_path ${OUTDIR} \
  -f

date
