#!/bin/bash
#SBATCH --job-name=medaka_polish
#SBATCH -n 1
#SBATCH -N 1
#SBATCH -c 16
#SBATCH --mem=250G
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --mail-user=alex.frutos@uconn.edu
#SBATCH --mail-type=ALL
#SBATCH -o %x_%j.out
#SBATCH -e %x_%j.err

# Specifiy versions for Medaka 1.9.1
module load medaka/1.9.1
module load bcftools/1.12
module load samtools/1.12
module load htslib/1.12

# Input files
BASECALLS=../data/raw/all_ONT_reads.fastq.gz
DRAFT=../data/assembly/assembly.fasta

# Output directory
OUTDIR=../data/medaka_polish_2
mkdir -p $OUTDIR

# Run Medaka polishing
medaka_consensus -i ${BASECALLS} -d ${DRAFT} -o ${OUTDIR} -t 16
