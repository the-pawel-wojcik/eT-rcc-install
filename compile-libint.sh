#!/bin/bash
#SBATCH --job-name="installLibint2"
#SBATCH -n 12
#SBATCH -N 1
#SBATCH --mem=84G
#SBATCH -A backfill2
# #SBATCH -A genacc_q
#SBATCH --mail-type="NONE"
#SBATCH -t 04:00:00
# #SBATCH -t 12:00:00

#SBATCH -o slurm-%j.stdout     # stdout
#SBATCH -e slurm-%j.stderr     # stderr

echo read and edit the script below before you submit this job
exit 0
conda deactivate
module purge
module load intel/21
cd ~/apps/eT2  # verify this path
. et/bin/activate  # verify this path
cd libint-2.7.0-beta.6/  # verify this path
# rm -fr build
mkdir build
cmake\
    -S . -B build\
    -G Ninja\
    -D CMAKE_INSTALL_PREFIX:PATH=${HOME}/apps/eT2/intel21\
    -D CMAKE_C_COMPILER:STRING=icc\
    -D CMAKE_CXX_COMPILER:STRING=icpc\
    -D CMAKE_FORTRAN_COMPILER:STRING=ifort\
    -D CMAKE_CXX_FLAGS:STRING=-std=c++11
cmake --build build --target check --parallel 12
cmake --build build --target install
