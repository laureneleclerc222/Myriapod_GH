## Make directories 
For the 11 myriapod genomes:\
&nbsp;&nbsp;&nbsp;&nbsp; mkdir /scratch/pawsey1193/lleclerc/CUHK_new/genome

For the corresponding .gff3 files for the 11 myriapod genomes:\
&nbsp;&nbsp;&nbsp;&nbsp; mkdir /scratch/pawsey1193/lleclerc/CUHK_new/gff

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

## count number of exons in each glycoside hydrolase gene
_exon_number.sh_ is a  script that uses the .gff3 file to determine the number of exons in all the protein-coding genes (CDS) for each myriapod genome. 
Change the name of the input_gff3 and output_file to correspond to the myriapod species you want to analyse. 
The output is a table that gives you the gene ID, the number of exons and reports 'yes' if there are more than 1 exons. 

e.g. Gene_ID	
Exon_Count	Multiple_Exons\
Gma_018636-T1	5	yes\
Gma_018593-T1	8	yes\
Gma_018489-T1	4	yes\
Gma_018467-T1	6	yes

