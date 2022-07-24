#!/bin/bash
#SBATCH --job-name=1kg_frq
#SBATCH --output=logs/1kg_frq.out
#SBATCH --error=logs/1kg_frq.err
#SBATCH --time=03:00:00
#SBATCH --partition=broadwl
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=14
#SBATCH --mem-per-cpu=4000

module load python/cpython-3.7.0
module load plink
module load perl

echo "SLURM_JOBID="$SLURM_JOBID
cat snakefile
snakemake --cores all
