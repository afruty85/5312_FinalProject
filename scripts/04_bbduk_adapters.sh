#!/bin/bash
#SBATCH --job-name=bbduk_trimming
#SBATCH -n 1
#SBATCH -N 1
#SBATCH -c 8
#SBATCH --mem=30G
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --mail-user=alex.frutos@uconn.edu
#SBATCH --mail-type=ALL
#SBATCH -o %x_%j.out
#SBATCH -e %x_%j.err

# Input and output directories
raw_reads=../data/raw
out_dir=../data/trimmed
mkdir -p $out_dir

module load bbmap

# Loop through all reads (_1 files)
for r1 in $raw_reads/*_1.fastq.gz
do
  r2=${r1/_1.fastq.gz/_2.fastq.gz}
  base=$(basename "$r1" _1.fastq.gz)

# BBDuk parameters: 
# adapters =  adapter reference sequences
# ktrim=r = trim adapters from the right end 
# k=31 = k-mer length used for matching 
# mink=11 = minimum k-mer size for shorter matches 
# hdist=1 = allow 1 mismatch in k-mer matching 
# tpe = trim both reads equally (paired-end)
# tbo = trim based on read overlap detection


  bbduk.sh \
    in1="$r1" \
    in2="$r2" \
    out1="$out_dir/${base}_1_trimmed.fastq.gz" \
    out2="$out_dir/${base}_2_trimmed.fastq.gz" \
    ref=adapters \
    ktrim=r k=31 mink=11 hdist=1 tpe tbo
done
