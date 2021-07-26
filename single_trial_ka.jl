using BenchmarkTools
using BSON

include("stencil_calculations.jl")

Nx = Ny = Nz = parse(Int, ARGS[1])

grid = RegularRectilinearGrid(size=(Nx, Ny, Nz), extent=(2π, 2π, 2π))

ϕ = CenterField(CPU(), grid)
∇²ϕ = CenterField(CPU(), grid)

set!(ϕ, (x, y, z) -> randn())

workgroups = [(16, 16), (Nx, Ny)]

# warm up
nthreads = Base.Threads.nthreads()

trials = Dict()

for workgroup in workgroups
    ∇²_KA!(∇²ϕ, ϕ, workgroups)

    @info "Benchmarking KernelAbstractions on $nthreads threads with workgroup $workgroup"
    
    KA_trial = @benchmark begin
        ∇²_KA!(∇²ϕ, ϕ, workgroup)
    end samples=10

    trials[workgroup] = KA_trial
end

bson("multithreading_benchmark_KernelAbstractions_$nthreads.bson", trials)
     
