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

for group in workgroups
    @info "Benchmarking KernelAbstractions on $nthreads threads with workgroup $group"

    @info "Compiling KernelAbstractions Lapacian kernel..."
    start_time = time_ns()

    ∇²_KA!(∇²ϕ, ϕ, group)

    compute_time = (time_ns() - start_time) * 1e-9
    @info "    ... compilation + one kernel launch took $compute_time seconds."

    KA_trial = @benchmark begin
        ∇²_KA!(∇²ϕ, ϕ, $group)
    end samples=10

    trials[group] = KA_trial
end

bson("multithreading_benchmark_KernelAbstractions_$nthreads.bson", trials)
     
