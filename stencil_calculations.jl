using KernelAbstractions: @kernel, @index

using Oceananigans
using Oceananigans.Operators: ∇²ᶜᶜᶜ
using Oceananigans.Architectures: device
using Oceananigans.BoundaryConditions: fill_halo_regions!

@kernel function _∇²_KA!(∇²f, grid, f)
    i, j, k = @index(Global, NTuple)
    @inbounds ∇²f[i, j, k] = ∇²ᶜᶜᶜ(i, j, k, grid, f)
end

function _∇²_base_threads!(∇²f, grid, f)

    Nx, Ny, Nz = size(grid)

    Base.Threads.@threads for k = 1:Nz
        for j = 1:Ny
            for i = 1:Nx
                @inbounds ∇²f[i, j, k] = ∇²ᶜᶜᶜ(i, j, k, grid, f)
            end
        end
    end

    return nothing
end

function ∇²_KA!(∇²ϕ, ϕ, workgroup=(ϕ.grid.Nx, ϕ.grid.Ny))
    arch = ϕ.architecture
    grid = ϕ.grid

    Nx, Ny, Nz = worksize = size(grid)

    fill_halo_regions!(ϕ, arch)
    loop! = _∇²_KA!(device(arch), workgroup, worksize)
    event = loop!(∇²ϕ, grid, ϕ)
    wait(device(arch), event)

    return nothing
end

function ∇²_base_threads!(∇²ϕ, ϕ)
    arch = ϕ.architecture
    fill_halo_regions!(ϕ, arch)
    _∇²_base_threads!(∇²ϕ, grid, ϕ)
    return nothing
end
