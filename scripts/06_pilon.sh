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

REF=../data/medaka_polish_2/consensus.fasta
bams=../data/alignment
out_dir=../data/pilon_polish
mkdir -p $out_dir

module load pilon/1.24
module load samtools

samtools merge $bams/merged.bam $bams/*sorted.bam
samtools index $bams/merged.bam

java -Xmx100G -jar $PILON --genome $REF --frags $bams/merged.bam --output pilon_polished --outdir $out_dir --chunksize 1000000 --nostrays --fix snps,indels
