#!/bin/bash
#SBATCH --job-name=pilon_align
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
module load minimap2
module load samtools

# Input and output
REF=../data/pilon_polish/pilon_polished.fasta
trim_dir=../data/trimmed
ONT_reads=../data/raw/ONT_raw/*fastq.gz
out_dir=../data/pilon_polish/ILL_alignment
ONT_out_dir=../data/pilon_polish/ONT_alignment
mkdir -p $out_dir
mkdir -p $ONT_out_dir

# Index polished genome assembly
bwa index $REF

# Align trimmed Illumina reads, alignments are indexed
for R1 in $trim_dir/*_1_trimmed.fastq.gz; do
    base=$(basename $R1 _1_trimmed.fastq.gz)
    R2=$trim_dir/${base}_2_trimmed.fastq.gz

    bwa mem -t 8 $REF $R1 $R2 | samtools sort -@ 8 -o $out_dir/${base}.sorted.bam
    samtools index $out_dir/${base}.sorted.bam
done

# Align ONT reads, alignments are indexed
for FQ in $ONT_reads; do
    base=$(basename $FQ .fastq.gz)

    minimap2 -ax map-ont -t 8 $REF $FQ | \
    samtools view -bS - | \
    samtools sort -@ 8 -o $ONT_out_dir/${base}.sorted.bam

    samtools index $ONT_out_dir/${base}.sorted.bam
done
