using UnicodePlots

include("stencil_calculations.jl")

Nx = Ny = 256
Nz = 1

grid = RegularRectilinearGrid(size=(Nx, Ny, Nz), extent=(2π, 2π, 2π))

ϕ = CenterField(CPU(), grid)
∇²ϕ = CenterField(CPU(), grid)

ϕ = CenterField(CPU(), grid)
∇²ϕ = CenterField(CPU(), grid)

set!(ϕ, (x, y, z) -> randn())

Δt = 1e-4

for i = 1:1000
    ∇²_KA!(∇²ϕ, ϕ)
    ϕ .= ϕ .+ Δt .* ∇²ϕ
end

@info "With a KA-based kernel:"

pl = heatmap(interior(ϕ)[:, :, 1])
display(pl)

@info "With a Base.Threads-based kernel:"

set!(ϕ, (x, y, z) -> randn())

for i = 1:1000
    ∇²_base_threads!(∇²ϕ, ϕ)
    ϕ .= ϕ .+ Δt .* ∇²ϕ
end

pl = heatmap(interior(ϕ)[:, :, 1])
display(pl)
