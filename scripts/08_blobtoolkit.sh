#!/bin/bash
#SBATCH --job-name=blobtoolkit_01
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

module load samtools

# Merge and index Illumina BAM files
samtools merge ../data/pilon_polish/ILL_merged.bam ../data/pilon_polish/ILL_alignment/*.bam
samtools index -c ../data/pilon_polish/ILL_merged.bam

# Merge and index ONT BAM files
samtools merge ../data/pilon_polish/ONT_merged.bam ../data/pilon_polish/ONT_alignment/*.bam
samtools index -c ../data/pilon_polish/ONT_merged.bam

# Load conda + environment
module load miniconda3/3.9
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate blobtk39

echo "Starting BlobToolKit at $(date)"

# Create BlobDir
blobtools create \
  --fasta ../data/pilon_polish/pilon_polished.fasta \
  BlobDir

# Add coverage (Illumina + ONT)
blobtools add \
  --cov ../data/pilon_polish/ILL_merged.bam \
  --cov ../data/pilon_polish/ONT_merged.bam \
  BlobDir

echo "Finished BlobToolKit at $(date)"

# Download taxonomy/reference files
cd BlobDir
wget https://ftp.uniprot.org/pub/databases/uniprot/knowledgebase/complete/uniprot_sprot.fasta.gz
gunzip uniprot_sprot.fasta.gz

wget https://ftp.ncbi.nlm.nih.gov/pub/taxonomy/taxdump.tar.gz
wget https://ftp.ncbi.nlm.nih.gov/pub/taxonomy/accession2taxid/prot.accession2taxid.gz
tar -xzf taxdump.tar.gz

module load blast/2.13.0
echo "Starting BLASTn at $(date)"

# Run BLAST against nt database
blastn \
  -query ../../data/pilon_polish/pilon_polished.fasta \
  -db /isg/shared/databases/blast/v5/nt \
  -out blastn_nt.out \
  -outfmt "6 qseqid staxids bitscore std" \
  -max_target_seqs 10 \
  -max_hsps 1 \
  -evalue 1e-25 \
  -num_threads 16
echo "Finished BLASTn at $(date)"

cd ../

# Add BLAST hits and taxonomy information to BlobDir
blobtools add \
  --hits BlobDir/blastn_nt.out \
  --taxdump BlobDir \
  BlobDir

# Filter contigs by length
blobtools filter \
  --param length--Min=3000 \
  --output BlobDir_filtered \
  BlobDir

# Extract filtered contig names from BlobToolKit output
python
import json

f = open("BlobDir_filtered/identifiers.json")
data = json.load(f)
f.close()

ids = data["values"]

out = open("filtered_contigs.txt", "w")
for contig in ids:
    out.write(contig + "\n")

out.close()

len(ids)

exit()

module load seqkit

# Extract filtered contigs to turn into new assembly FASTA
seqkit grep -f filtered_contigs.txt \
  ../data/pilon_polish/pilon_polished.fasta \
  > ../data/pilon_polish/pilon_polished.filtered_3kb.fasta

# Check final filtered assembly
grep -c ">" ../data/pilon_polish/pilon_polished.filtered_3kb.fasta
ls -lh ../data/pilon_polish/pilon_polished.filtered_3kb.fasta

