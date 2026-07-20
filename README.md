# Getting started
## Make directories 
For the 11 myriapod genomes:\
&nbsp;&nbsp;&nbsp;&nbsp; mkdir /scratch/pawsey1193/lleclerc/CUHK_new/genome

For the corresponding .gff3 files for the 11 myriapod genomes:\
&nbsp;&nbsp;&nbsp;&nbsp; mkdir /scratch/pawsey1193/lleclerc/CUHK_new/gff

For the GH phylogenetic trees (that will be made)\
&nbsp;&nbsp;&nbsp;&nbsp; mkdir /scratch/pawsey1193/lleclerc/CUHK_new/trees

For the GHs\
&nbsp;&nbsp;&nbsp;&nbsp; mkdir /scratch/pawsey1193/lleclerc/CUHK_new/GHs

For the amino acid sequences of all the GHs\
&nbsp;&nbsp;&nbsp;&nbsp; mkdir /scratch/pawsey1193/lleclerc/CUHK_new/GHs/aa\
&nbsp;&nbsp;&nbsp;&nbsp; mkdir /scratch/pawsey1193/lleclerc/CUHK_new/GHs/aa/15\
&nbsp;&nbsp;&nbsp;&nbsp; mkdir /scratch/pawsey1193/lleclerc/CUHK_new/GHs/aa/16\
&nbsp;&nbsp;&nbsp;&nbsp; mkdir /scratch/pawsey1193/lleclerc/CUHK_new/GHs/aa/18\
&nbsp;&nbsp;&nbsp;&nbsp; mkdir /scratch/pawsey1193/lleclerc/CUHK_new/GHs/aa/2\
&nbsp;&nbsp;&nbsp;&nbsp; mkdir /scratch/pawsey1193/lleclerc/CUHK_new/GHs/aa/25\
&nbsp;&nbsp;&nbsp;&nbsp; mkdir /scratch/pawsey1193/lleclerc/CUHK_new/GHs/aa/3\
&nbsp;&nbsp;&nbsp;&nbsp; mkdir /scratch/pawsey1193/lleclerc/CUHK_new/GHs/aa/30\
&nbsp;&nbsp;&nbsp;&nbsp; mkdir /scratch/pawsey1193/lleclerc/CUHK_new/GHs/aa/31\
&nbsp;&nbsp;&nbsp;&nbsp; mkdir /scratch/pawsey1193/lleclerc/CUHK_new/GHs/aa/32\
&nbsp;&nbsp;&nbsp;&nbsp; mkdir /scratch/pawsey1193/lleclerc/CUHK_new/GHs/aa/35\
&nbsp;&nbsp;&nbsp;&nbsp; mkdir /scratch/pawsey1193/lleclerc/CUHK_new/GHs/aa/38\
&nbsp;&nbsp;&nbsp;&nbsp; mkdir /scratch/pawsey1193/lleclerc/CUHK_new/GHs/aa/39\
&nbsp;&nbsp;&nbsp;&nbsp; mkdir /scratch/pawsey1193/lleclerc/CUHK_new/GHs/aa/43\
&nbsp;&nbsp;&nbsp;&nbsp; mkdir /scratch/pawsey1193/lleclerc/CUHK_new/GHs/aa/47\
&nbsp;&nbsp;&nbsp;&nbsp; mkdir /scratch/pawsey1193/lleclerc/CUHK_new/GHs/aa/5\
&nbsp;&nbsp;&nbsp;&nbsp; mkdir /scratch/pawsey1193/lleclerc/CUHK_new/GHs/aa/6\
&nbsp;&nbsp;&nbsp;&nbsp; mkdir /scratch/pawsey1193/lleclerc/CUHK_new/GHs/aa/63\
&nbsp;&nbsp;&nbsp;&nbsp; mkdir /scratch/pawsey1193/lleclerc/CUHK_new/GHs/aa/9

### Extract the nucleotide sequences for each GH
Run _extract_gh.py_ to extract the nucleotide sequence for each GH and make .fasta files for each sequence. 
_extract_gh.py_ uses _new_GH.txt_ which is a list of the accession of each GH and its corresponding .gff file. (e.g. Gene_accession	Genome_gff, Ato_000013-T1	Ato,
Ato_000266-T1	Ato)

&nbsp;&nbsp;&nbsp;&nbsp;#!/bin/bash\
&nbsp;&nbsp;&nbsp;&nbsp;#SBATCH --account=pawsey1193\
&nbsp;&nbsp;&nbsp;&nbsp;#SBATCH --ntasks=1\
&nbsp;&nbsp;&nbsp;&nbsp;#SBATCH --ntasks-per-node=1\
&nbsp;&nbsp;&nbsp;&nbsp;#SBATCH --cpus-per-task=1\
&nbsp;&nbsp;&nbsp;&nbsp;#SBATCH --mem=100M\
&nbsp;&nbsp;&nbsp;&nbsp;#SBATCH --time=01:00:00\
&nbsp;&nbsp;&nbsp;&nbsp;#SBATCH --output=run_extract_gh.out\
&nbsp;&nbsp;&nbsp;&nbsp;#change directory\
&nbsp;&nbsp;&nbsp;&nbsp;cd /scratch/pawsey1193/lleclerc/CUHK_new\
&nbsp;&nbsp;&nbsp;&nbsp;#load conda, activate env and run extract_GH.py\
&nbsp;&nbsp;&nbsp;&nbsp;source /software/projects/pawsey1193/lleclerc/miniconda3/etc/profile.d/conda.sh\
&nbsp;&nbsp;&nbsp;&nbsp;conda activate /software/projects/pawsey1193/lleclerc/miniconda3/envs/GH_env\
&nbsp;&nbsp;&nbsp;&nbsp;python extract_GH.py

## Count number of exons in each glycoside hydrolase gene
_exon_number.sh_ is a  script that uses the .gff3 file to determine the number of exons in all the protein-coding genes (CDS) for each myriapod genome. 
Change the name of the input_gff3 and output_file to correspond to the myriapod species you want to analyse. 
The output is a table that gives you the gene ID, the number of exons and reports 'yes' if there are more than 1 exons. 

e.g. Gene_ID	
Exon_Count	Multiple_Exons\
Gma_018636-T1	5	yes\
Gma_018593-T1	8	yes\
Gma_018489-T1	4	yes\
Gma_018467-T1	6	yes

# Identify GHs that are from contamination
### Make directories
&nbsp;&nbsp;&nbsp;&nbsp; mkdir /scratch/pawsey1193/lleclerc/CUHK_new/contigs\
&nbsp;&nbsp;&nbsp;&nbsp; mkdir /scratch/pawsey1193/lleclerc/CUHK_new/contigs/neighbourhood\
&nbsp;&nbsp;&nbsp;&nbsp; mkdir /scratch/pawsey1193/lleclerc/CUHK_new/contigs/neighbourhood/10000\
&nbsp;&nbsp;&nbsp;&nbsp; mkdir /scratch/pawsey1193/lleclerc/CUHK_new/contigs/neighbourhood/blast_output\
&nbsp;&nbsp;&nbsp;&nbsp; mkdir /scratch/pawsey1193/lleclerc/CUHK_new/contigs/neighbourhood/logs

### Determine where the GHs are (what contig, what position, + or - strand)
Using the _new_GH.txt_ and .gff3 files again, determine the location of the GH within its respective genome.\
Run _contig_location.sh_

The output will look something like this:\
Gene	Contig	Start	End	Strand\
Ato_000013-T1	10x_75	19968	21188	-\
Ato_000266-T1	10x_125	37140	41489	-\
Ato_000272-T1	10x_129	15	548	-

Convert the table to only include the GH CDS and the contig name with the command:\
&nbsp;&nbsp;&nbsp;&nbsp;(echo -e "GH CDS\tcontig"; tail -n +2 contig_locations.txt | awk '{print $1 "\t" $2}') > contig_names.txt

### Extract the CDS next to the GH 
Using _contig_names.txt_, the .gff3 files and the genome files (.fasta), extract the CDS on 10,000 nt flanking upstream and downstream of the GH.

Run _extract_neighbourhood.py_ with \
&nbsp;&nbsp;&nbsp;&nbsp; #!/bin/bash\
&nbsp;&nbsp;&nbsp;&nbsp; #SBATCH --account=pawsey1193\
&nbsp;&nbsp;&nbsp;&nbsp; #SBATCH --ntasks=1\
&nbsp;&nbsp;&nbsp;&nbsp; #SBATCH --cpus-per-task=1\
&nbsp;&nbsp;&nbsp;&nbsp; #SBATCH --mem=32G\
&nbsp;&nbsp;&nbsp;&nbsp; #SBATCH --time=01:00:00\
&nbsp;&nbsp;&nbsp;&nbsp; #SBATCH --output=o_neighbourhood.out

&nbsp;&nbsp;&nbsp;&nbsp; source /software/projects/pawsey1193/lleclerc/miniconda3/etc/profile.d/conda.sh\
&nbsp;&nbsp;&nbsp;&nbsp; conda activate GH_env

&nbsp;&nbsp;&nbsp;&nbsp; python3 /scratch/pawsey1193/lleclerc/CUHK_new/contigs/extract_neighbourhood.py

The output will be {gene}_cds_neighbourhood.csv in /scratch/pawsey1193/lleclerc/CUHK_new/contigs/neighbourhood/10000. It will include a .csv table with the attributes of each CDS and its nucleotide sequence e.g. GH_Gene,Contig,Feature,Start,End,Strand,Attributes,Nucleotide_Sequence,Protein_Sequence
Ttu_027013-T1,ScORjMK_72212,CDS,60084278,60084474,+,ID=Ttu_027013-T1.cds;Parent=Ttu_027013-T1;,ATGAAGCATTGTGGGTGCGTGTGCATTCTGATTGCCATAGTATTAGGATTAGGATTAGCAGTGGCTTTAATTATGGTCTTTATTGTTGCTGACAAGACGGTGCGAATGCCTCATGTCACGGACC

### convert the .csv into .fasta
Use the command:\
&nbsp;&nbsp;&nbsp;&nbsp;for f in *_cds_neighbourhood.csv; do\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;    awk -F',' 'NR>1 {\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;        match($7, /Parent=([^;]+)/, p)\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;        printf(">%s|%s_%s-%s\n%s\n", $1, p[1], $4, $5, $8)\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;    }' "$f" > "${f%.csv}.fasta"\
&nbsp;&nbsp;&nbsp;&nbsp;done

### Perform a BLASTn to determine the top 5 hits for each extracted CDS
First, create a samples.tsv file listing all the input files. e.g. 
Ato_000013-T1_cds_neighbourhood\
Ato_000266-T1_cds_neighbourhood\
Ato_000272-T1_cds_neighbourhood\
Ato_000310-T1_cds_neighbourhood

&nbsp;&nbsp;&nbsp;&nbsp;#!/bin/bash\
&nbsp;&nbsp;&nbsp;&nbsp;#SBATCH --job-name=blast_array\
&nbsp;&nbsp;&nbsp;&nbsp;#SBATCH --account=pawsey1193\
&nbsp;&nbsp;&nbsp;&nbsp;#SBATCH --partition=work\
&nbsp;&nbsp;&nbsp;&nbsp;#SBATCH --ntasks=1\
&nbsp;&nbsp;&nbsp;&nbsp;#SBATCH --cpus-per-task=8\
&nbsp;&nbsp;&nbsp;&nbsp;#SBATCH --mem=32G\
&nbsp;&nbsp;&nbsp;&nbsp;#SBATCH --time=10:00:00\
&nbsp;&nbsp;&nbsp;&nbsp;#SBATCH --array=1-986\
&nbsp;&nbsp;&nbsp;&nbsp;#SBATCH --output=logs/blast_%A_%a.out\
&nbsp;&nbsp;&nbsp;&nbsp;#SBATCH --error=logs/blast_%A_%a.err\
&nbsp;&nbsp;&nbsp;&nbsp;cd /scratch/pawsey1193/lleclerc/CUHK_new/contigs/neighbourhood

&nbsp;&nbsp;&nbsp;&nbsp;export PATH=/software/projects/pawsey1193/ncbi-blast-2.17.0+/bin:$PATH\
&nbsp;&nbsp;&nbsp;&nbsp;export BLASTDB=/scratch/references/blastdb_update/blast-2026-06-01/db

&nbsp;&nbsp;&nbsp;&nbsp;#get the file corresponding to this task\
&nbsp;&nbsp;&nbsp;&nbsp;SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" samples.tsv)

&nbsp;&nbsp;&nbsp;&nbsp;INPUT="/scratch/pawsey1193/lleclerc/CUHK_new/contigs/neighbourhood/10000/${SAMPLE}.fasta"\
&nbsp;&nbsp;&nbsp;&nbsp;OUTPUT="/scratch/pawsey1193/lleclerc/CUHK_new/contigs/neighbourhood/10000/blast_output/${SAMPLE}.blast.out"

&nbsp;&nbsp;&nbsp;&nbsp;echo "running BLAST for ${SAMPLE}.fasta"

&nbsp;&nbsp;&nbsp;&nbsp;#run BLAST (edit db + parameters as needed)\
&nbsp;&nbsp;&nbsp;&nbsp;blastn \
&nbsp;&nbsp;&nbsp;&nbsp;  -task dc-megablast \
&nbsp;&nbsp;&nbsp;&nbsp;  -query "$INPUT" \
&nbsp;&nbsp;&nbsp;&nbsp;  -db nt \
&nbsp;&nbsp;&nbsp;&nbsp;  -out "$OUTPUT" \
&nbsp;&nbsp;&nbsp;&nbsp;  -outfmt "7 qseqid sseqid sseq stitle pident length evalue bitscore staxids sscinames sacc sskingdoms" \
&nbsp;&nbsp;&nbsp;&nbsp;  -num_threads $SLURM_CPUS_PER_TASK \
&nbsp;&nbsp;&nbsp;&nbsp;  -evalue 1e-5 \
&nbsp;&nbsp;&nbsp;&nbsp;  -max_target_seqs 5

&nbsp;&nbsp;&nbsp;&nbsp;exit_code=$?

Look at the output manually to determine if the CDS are Myriapod or bacterial (or another form of contamination). Or use the commands below to provide a summary of the results:

&nbsp;&nbsp;&nbsp;&nbsp;#!/bin/bash\
&nbsp;&nbsp;&nbsp;&nbsp;#Print header\
&nbsp;&nbsp;&nbsp;&nbsp;echo -e "File\tBacteria\tEukaryota\tArchaea\tVirus\tProp_Bac\tProp_Euk\tProp_Arc\tProp_Vir\tMost_common"

&nbsp;&nbsp;&nbsp;&nbsp;for f in *_cds_neighbourhood.blast.out; do\
&nbsp;&nbsp;&nbsp;&nbsp;    b=$(grep -c 'Bacteria' "$f")\
&nbsp;&nbsp;&nbsp;&nbsp;    e=$(grep -c 'Eukaryota' "$f")\
&nbsp;&nbsp;&nbsp;&nbsp;    a=$(grep -c 'Archaea' "$f")\
&nbsp;&nbsp;&nbsp;&nbsp;    v=$(grep -c 'Virus' "$f")

&nbsp;&nbsp;&nbsp;&nbsp;    total=$((b + e + a + v))

&nbsp;&nbsp;&nbsp;&nbsp;    # Avoid division by zero\
&nbsp;&nbsp;&nbsp;&nbsp;    if [ "$total" -eq 0 ]; then\
&nbsp;&nbsp;&nbsp;&nbsp;        pb=0; pe=0; pa=0; pv=0
&nbsp;&nbsp;&nbsp;&nbsp;    else
&nbsp;&nbsp;&nbsp;&nbsp;        pb=$(awk "BEGIN {printf \"%.3f\", $b/$total}")\
&nbsp;&nbsp;&nbsp;&nbsp;        pe=$(awk "BEGIN {printf \"%.3f\", $e/$total}")\
&nbsp;&nbsp;&nbsp;&nbsp;        pa=$(awk "BEGIN {printf \"%.3f\", $a/$total}")\
&nbsp;&nbsp;&nbsp;&nbsp;        pv=$(awk "BEGIN {printf \"%.3f\", $v/$total}")\
&nbsp;&nbsp;&nbsp;&nbsp;    fi

&nbsp;&nbsp;&nbsp;&nbsp;    max=$b\
&nbsp;&nbsp;&nbsp;&nbsp;    label="Bacteria"

&nbsp;&nbsp;&nbsp;&nbsp;    if [ "$e" -gt "$max" ]; then max=$e; label="Eukaryota"; fi\
&nbsp;&nbsp;&nbsp;&nbsp;    if [ "$a" -gt "$max" ]; then max=$a; label="Archaea"; fi\
&nbsp;&nbsp;&nbsp;&nbsp;    if [ "$v" -gt "$max" ]; then max=$v; label="Virus"; fi

&nbsp;&nbsp;&nbsp;&nbsp;    echo -e "$f\t$b\t$e\t$a\t$v\t$pb\t$pe\t$pa\t$pv\t$label"\
&nbsp;&nbsp;&nbsp;&nbsp;done

The output will look something like this:\
File	Bacteria	Eukaryota	Archaea	Virus	Prop_Bac	Prop_Euk	Prop_Arc	Prop_Vir	Most_common\
Ato_000013-T1_cds_neighbourhood.blast.out	57	0	0	0	1.000	0.000	0.000	0.000	Bacteria\
Ato_000266-T1_cds_neighbourhood.blast.out	75	2	0	3	0.938	0.025	0.000	0.037	Bacteria\
Ato_000272-T1_cds_neighbourhood.blast.out	52	0	1	1	0.963	0.000	0.019	0.019	Bacteria

# Phylogenetic analysis of myriapod GHs
Now that we know which GHs are of myriapod origin (and not contamination), we can perform a phylogenetic analysis to determine their origin and evolution. 

### make directories
&nbsp;&nbsp;&nbsp;&nbsp;mkdir /scratch/pawsey1193/lleclerc/CUHK_new/trees\
&nbsp;&nbsp;&nbsp;&nbsp;mkdir /scratch/pawsey1193/lleclerc/CUHK_new/trees/blast_outputs\
&nbsp;&nbsp;&nbsp;&nbsp;mkdir /scratch/pawsey1193/lleclerc/CUHK_new/trees/logs

## Example for GH5
### Getting started
Make a general GH5 directory for all the required sequences\
&nbsp;&nbsp;&nbsp;&nbsp;mkdir /scratch/pawsey1193/lleclerc/CUHK_new/GHs/aa/5\
Make .fasta files for the amino acid sequence of each myriapod GH5 in this directory. 

Make a directory for diverse representatives of the GH. \
&nbsp;&nbsp;&nbsp;&nbsp;mkdir /scratch/pawsey1193/lleclerc/CUHK_new/GHs/aa/5/GH5_reps\
In this directory, add a .fasta file (e.g. GH5_reps.fasta) of the amino acid sequences of the 20 most diverse representatives of that GH using the NCBI Conserved Domain search tool (https://www.ncbi.nlm.nih.gov/Structure/wrpsb-out/wrpsb.cgi)

Make a directory for the GH5 contaminants\
&nbsp;&nbsp;&nbsp;&nbsp;mkdir /scratch/pawsey1193/lleclerc/CUHK_new/GHs/aa/5/contamination\
Make a .fasta file of the amino acid sequences of all the GHs that were determined to be contaminated in the previous step. (These will be included in the tree in case the contaminants are related to the bacteria that led to the horizontal gene transfer of GHs in the myriapods). 

List all the myriapod GHs that are from the GH5 family in GH5_samples.tsv. e.g. \
Tco_015307-T1\
Plu_002086-T1\
Gma_009097-T1\
Ato_055614-T1\
Ato_042299-T1

### Perform the BLAST searches

Three different BLAST searches will be run, one with no filtering, one filtering out bacteria (taxid 2) and one filtering out bacteria and fungi (taxid 2 and 2,4751). This ensures that in the trees that are predominantly bacteria, there are some eukaryotic representatives. 

In /scratch/pawsey1193/lleclerc/CUHK_new/trees, run _blast1.sh_, _blast2.sh_ and _blast3.sh_

These scripts also remove spaces and convert the BLAST output from a .csv to a .fasta to ensure the following steps run smoothly.

### Remove duplicate sequences and align the hits
This script combines the myriapod GHs, BALST outputs, the Conserved Protein Domain representatives and bacterial contaminants (if present). It then removes duplicate sequences and does an alignment with MAFFT.  

Run _mafft.sh_
