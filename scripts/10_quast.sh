#!/bin/bash
#SBATCH --job-name=quast_filtered
#SBATCH -n 1
#SBATCH -N 1
#SBATCH -c 16
#SBATCH --mem=20G
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --mail-type=ALL
#SBATCH --mail-user=alex.frutos@uconn.edu
#SBATCH -o %x_%j.out
#SBATCH -e %x_%j.err

module load quast/5.2.0

# Input and output
ASSEMBLY="../data/pilon_polish/pilon_polished.filtered_3kb.fasta"
OUTDIR="../data/quast/quast_filtered_3kb"

mkdir -p ${OUTDIR}

# Run QUAST
quast.py ${ASSEMBLY} \
  --threads 16 \
  -o ${OUTDIR}

