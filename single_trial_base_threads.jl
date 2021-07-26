using BenchmarkTools
using BSON

include("stencil_calculations.jl")

Nx = Ny = Nz = parse(Int, ARGS[1])

grid = RegularRectilinearGrid(size=(Nx, Ny, Nz), extent=(2π, 2π, 2π))

ϕ = CenterField(CPU(), grid)
∇²ϕ = CenterField(CPU(), grid)

set!(ϕ, (x, y, z) -> randn())

# warm up
∇²_base_threads!(∇²ϕ, ϕ)

nthreads = Base.Threads.nthreads()
@info "Benchmarking Base.Threads on $nthreads threads"

base_trial = @benchmark begin
    ∇²_base_threads!(∇²ϕ, ϕ)
end samples=10

trial_dict = Dict(:BaseThreads => base_trial)
bson("multithreading_benchmark_BaseThreads_$nthreads.bson", trial_dict)
     
