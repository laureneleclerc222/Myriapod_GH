#!/bin/bash
#SBATCH --job-name=iqtree
#SBATCH --account=pawsey1193
#SBATCH --cpus-per-task=16
#SBATCH --mem=10G
#SBATCH --time=2:00:00
#SBATCH --output=logs/iqtree_%j.out
#SBATCH --error=logs/iqtree_%j.err

#change directory
cd /scratch/pawsey1193/lleclerc/CUHK_new/trees

#load modules
module load singularity/4.1.0-nompi

GH=5

#make sequence names all unique
awk '
/^>/ {
    name=substr($0,2)
    count[name]++
    if(count[name]>1)
        print ">" name "_" count[name]
    else
        print
    next
}
{print}
' \
/scratch/pawsey1193/lleclerc/CUHK_new/trees/blast_outputs/${GH}/GH${GH}_mafft.fasta \
> /scratch/pawsey1193/lleclerc/CUHK_new/trees/blast_outputs/${GH}/GH${GH}_mafft_unique.fasta

#make tree in iqtree
singularity exec /software/projects/pawsey1193/iqtree_3.1.2--h8471819_0.sif \
    iqtree \
    -s blast_outputs/${GH}/GH${GH}_mafft_unique.fasta \
    -m TEST \
    -bb 1000 \
    -alrt 1000 \
    -nt AUTO
