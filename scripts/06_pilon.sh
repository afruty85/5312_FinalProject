#!/bin/bash
#SBATCH --job-name=pilon_polish
#SBATCH -n 1
#SBATCH -N 1
#SBATCH -c 8
#SBATCH --mem=128G
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --mail-user=alex.frutos@uconn.edu
#SBATCH --mail-type=ALL
#SBATCH -o %x_%j.out
#SBATCH -e %x_%j.err

# Input and output
REF=../data/medaka_polish_2/consensus.fasta
bams=../data/alignment
out_dir=../data/pilon_polish
mkdir -p $out_dir

module load pilon/1.24
module load samtools

# Merge all BAM files and index
samtools merge $bams/merged.bam $bams/*sorted.bam
samtools index $bams/merged.bam

# Pilon parameters: 
# -Xmx100G = allocate 100GB RAM to Java 
# --genome = input reference genome 
# --frags = BAM file with aligned reads 
# --output = name of output files 
# --outdir = output directory 
# --chunksize 1000000 = process genome in 1 Mb chunks 
# --nostrays = ignore improperly paired reads
# --fix snps,indels = correct SNPs and small insertions/deletions

# Run Pilon polishing
java -Xmx100G -jar $PILON --genome $REF --frags $bams/merged.bam --output pilon_polished --outdir $out_dir --chunksize 1000000 --nostrays --fix snps,indels
