#!/bin/bash
#SBATCH --job-name=bwa-mem_align
#SBATCH -n 1
#SBATCH -N 1
#SBATCH -c 8
#SBATCH --mem=32G
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --mail-user=alex.frutos@uconn.edu
#SBATCH --mail-type=ALL
#SBATCH -o %x_%j.out
#SBATCH -e %x_%j.err

module load bwa/0.7.17
module load samtools

REF=../data/medaka_polish_2/consensus.fasta
trim_dir=../data/trimmed
out_dir=../data/alignment
mkdir -p $out_dir

bwa index $REF

for R1 in $trim_dir/*_1_trimmed.fastq.gz; do
    base=$(basename $R1 _1_trimmed.fastq.gz)
    R2=$trim_dir/${base}_2_trimmed.fastq.gz

    bwa mem -t 8 $REF $R1 $R2 | samtools sort -@ 8 -o $out_dir/${base}.sorted.bam
    samtools index $out_dir/${base}.sorted.bam
done

