#!/bin/bash
#SBATCH -N 1
#SBATCH -p debug
#SBATCH -A m2545
#SBATCH -S 4
#SBATCH -t 00:20:00 
#SBATCH -C knl,quad,cache

# do the loop
for numprocs in 1 2 4 8 16 32 64; do
# for numprocs in 1 2 4; do

# Number of ranks x threads is constant
# pc = physical cores
numpc=$(echo ${numprocs} | awk '{print 64/$1}')
# hyper-threads
numht=1
# logical cores = OMP_NUM_TASK
numcores=$(( ${numpc}*${numht} ))
# srun reservation logical cores per mpi-task  (-c arg)
numlc=$(( ${numpc}*4 ))

    echo "Running with ${numprocs} MPI ranks and ${numpc} cores, ${numht} threads per core."

    # Intel OpenMP runtime parameters
    export OMP_NUM_THREADS=${numcores}
    export OMP_PLACES=threads
    export OMP_PROC_BIND=spread
    # export KMP_PLACE_THREADS=1s${numpc}c${numht}t

    # Run the job with this MPI + OpenMP configuration
    MPI_COMMAND="srun -n ${numprocs} -c ${numlc} --cpu_bind=cores" 
#    RUN_COMMAND="numactl -m 1 check-hybrid.intel.cori"
    RUN_COMMAND="./sw4lite_c skinny.in"
    COMMAND="${MPI_COMMAND} ${RUN_COMMAND}" 
    echo "OMP_N_T="${OMP_NUM_THREADS}
    echo ${COMMAND}
#    echo ${COMMAND} > timing_mpi${numprocs}_omp${numpc}_ht${numht}.txt
    ${COMMAND} > c_std_mpi${numprocs}_pc${numpc}_ht${numht}.dat

done
