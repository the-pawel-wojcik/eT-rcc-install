# How to compile
This document describes how to get a working version of the
[eT](https://etprogram.org/) program on your [RCC](https://its.fsu.edu/research)
account.

## Place to work
```sh
mkdir -p apps/eT2  # it's "eT2" not "eT" because it didn't work the first time
cd eT2
```
the rest of the instructions will assume you are in the `eT2` dir.

This will be an intel installation and the programs will be installed to this
directory
```sh
mkdir intel21
```

## Setup environment
Python will be used at various stages of the install. Setup the venv
```sh
python -m venv et
```

Before any next steps call these lines to clean your environment
```sh
conda deactivate
module purge
module load intel/21
. et/bin/activate
```

## Get eT
Get the [eT](https://etprogram.org/) website and click the red Download
button from the top menu. It will take you to a
[gitlab](https://gitlab.com/eT-program/eT/-/releases) releases page. Download
the program from there. At the time of writing, the January 2024 version
(1.9.13) was the most recent one.
```bash
mkdir downloads
wget https://gitlab.com/eT-program/eT/-/archive/v1.9.13/eT-v1.9.13.tar.bz2
tar xvf eT-v1.9.13.tar.bz2
mv eT-v1.9.13 ..
```
read the readme.

## Install libint
`eT` does not work with recent version of libint! (I learned it the hard way).
Use the legacy version from the eT's website. The link to the download was in
the readme of the eT release.

1. Download the old libint version which works with eT.
```sh
cd downloads
wget https://www.etprogram.org/libint/libint-2.7.0-beta.6.tgz
tar xvf libint-2.7.0-beta.6.tgz
mkdir ../libint
mv libint-2.7.0-beta.6 ../libint
```

2. Build libint (takes a lot of time). Instructions for Intel compilers.

As the installation is very long use the compute node for it
```sh
srun --pty --mem 80G -t 4:00:00 -n12 -A backfill2 /bin/bash
# setup the environment
conda deactivate
module purge
module load intel/21
. et/bin/activate
```
And build with 
```bash
cd libint/libint-2.7.0-beta.6
mkdir build
cmake\
    -S . -B build -G Ninja\
    -D CMAKE_INSTALL_PREFIX:PATH=${HOME}/apps/eT2/intel21\
    -D CMAKE_C_COMPILER:STRING=icc\
    -D CMAKE_CXX_COMPILER:STRING=icpc\
    -D CMAKE_CXX_FLAGS:STRING=-std=c++11
cmake --build build --target check --parallel 12
cmake --build build --target install
```
or submit the build job to the queue using the script `compile-libint.sh`

## Install eT
The eT authors made it "easier" for the users and wrapped `cmake` call into the
`setup.py` script. Run it like this
```sh
./setup.py\
    --clean-dir\
    --int64\
    --Fortran-compiler=ifort\
    --CXX-compiler=icpc\
    --C-compiler=icc\
    --omp\
    --blas-type=MKL\
    --extra-cmake-flags=" -GNinja -D LIBINT2_ROOT:PATH=~/apps/eT2/intel21"\
    build
```
After this step compile the program with
```sh
cmake --build build
```
The eT readme file does not share information on the program installation. It is
recommended to include the `build` in the `PATH`, instead.
