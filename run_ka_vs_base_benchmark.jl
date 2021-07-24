using BenchmarkTools
using BSON

include("stencil_calculations.jl")

Nx = Ny = Nz = parse(Int, ARGS[1])

grid = RegularRectilinearGrid(size=(Nx, Ny, Nz), extent=(2π, 2π, 2π))

ϕ = CenterField(CPU(), grid)
∇²ϕ = CenterField(CPU(), grid)

set!(ϕ, (x, y, z) -> randn())

# warm up
∇²_KA!(∇²ϕ, ϕ)
∇²_base_threads!(∇²ϕ, ϕ)

nthreads = Base.Threads.nthreads()
@info "Benchmarking on $nthreads threads"

KA_trial = @benchmark begin
    ∇²_KA!(∇²ϕ, ϕ)
end samples=10

base_trial = @benchmark begin
    ∇²_base_threads!(∇²ϕ, ϕ)
end samples=10

trials = Dict(:KernelAbstractions => KA_trial, :Base_threads => base_trial)
bson("multithreading_benchmark_$nthreads.bson", trials)
     
