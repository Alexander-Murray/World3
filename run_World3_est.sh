#!/usr/bin/bash
#SBATCH --job-name="world3_estimation"
#SBATCH -o /home/mfa/mrra/World3_dynare/estimation_output.out
#SBATCH -e error_file.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=3G
#SBATCH --time=30:00:00
#SBATCH -p long
#SBATCH --mail-type=ALL
#SBATCH --mail-user=mrra@bankofcanada.ca


module load matlab
matlab -nodisplay -nosplash -nodesktop < est_World3_low_var_version4.m
