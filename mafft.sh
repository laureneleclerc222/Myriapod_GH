#!/bin/bash
#SBATCH --job-name=mafft
#SBATCH --account=pawsey1193
#SBATCH --cpus-per-task=16
#SBATCH --mem=10G
#SBATCH --time=2:00:00
#SBATCH --output=logs/blast_%A_%a.out
#SBATCH --error=logs/blast_%A_%a.err

#change directory
cd /scratch/pawsey1193/lleclerc/CUHK_new/trees

#load modules
module load singularity/4.1.0-nompi

GH=5

#combine the BALST outputs, the Conserved Protein Domain representatives and bacterial contaminants (if present)
cat \
/scratch/pawsey1193/lleclerc/CUHK_new/GHs/aa/"${GH}"/contamination/GH"${GH}"_contamination.fasta \
/scratch/pawsey1193/lleclerc/CUHK_new/GHs/aa/"${GH}"/GH5_reps/GH"${GH}"_reps.fasta \
/scratch/pawsey1193/lleclerc/CUHK_new/trees/blast_outputs/"${GH}"/{Ato,Gma,Nno,Tco,Sym,Plu,Lni,Hho,Sma,Rim,Ttu}*.fasta \
> /scratch/pawsey1193/lleclerc/CUHK_new/trees/blast_outputs/"${GH}"/GH"${GH}"_combined.fasta

#remove duplicate sequences
awk '/^>/ {if(!seen[$0]++) {print; p=1} else p=0} p && !/^>/' \
/scratch/pawsey1193/lleclerc/CUHK_new/trees/blast_outputs/"${GH}"/GH"${GH}"_combined.fasta \
> /scratch/pawsey1193/lleclerc/CUHK_new/trees/blast_outputs/"${GH}"/GH"${GH}"_unique.fasta

#run mafft alignment
singularity exec /software/projects/pawsey1193/mafft_7.525--h031d066_1.sif \

mafft --amino --localpair --maxiterate 1000 --thread 16 --reorder --treeout \
/scratch/pawsey1193/lleclerc/CUHK_new/trees/blast_outputs/"${GH}"/GH"${GH}"_unique.fasta \
> /scratch/pawsey1193/lleclerc/CUHK_new/trees/blast_outputs/"${GH}"/GH"${GH}"_mafft.fasta
