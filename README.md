# multithreaded-stencils

This repo implements multithreaded three-dimensional loops over simple three-dimensional Laplacian
stencil calculations in Julia, using both `Base.Threads.@threads` and [`KernelAbstractions.jl`](https://github.com/JuliaGPU/KernelAbstractions.jl).
It borrows some tools from [`Oceananigans.jl`](https://github.com/CliMA/Oceananigans.jl) for benchmarking.

First, a sanity check that the stencils work (and we get some diffusion):

![image](https://user-images.githubusercontent.com/15271942/126853537-220f146e-7945-4dd3-8d31-eed50bdb208e.png)

Next, running

```julia
julia> include("benchmark_suite_ka_vs_base.jl")
```

performs benchmarks for multithreaded, looped, three-dimensional stencil computations (KA = `KernelAbstractions.jl`).
Note that "`size=512`" means `Nx = Ny = Nz = 512`, or a total size `512^3 = 134217728`.
This is realistic or even somewhat large (and therefore favorable for multithreading) with respect to typical
fluid dynamics computations. The results:

```
                                KA (16, 16) multithreading benchmarks
┌──────┬─────────┬────────────┬────────────┬────────────┬────────────┬────────────┬────────┬─────────┐
│ size │ threads │        min │     median │       mean │        max │     memory │ allocs │ samples │
├──────┼─────────┼────────────┼────────────┼────────────┼────────────┼────────────┼────────┼─────────┤
│  512 │       1 │    1.024 s │    1.025 s │    1.027 s │    1.032 s │  15.98 KiB │     90 │       5 │
│  512 │       2 │ 534.300 ms │ 536.166 ms │ 536.634 ms │ 540.036 ms │  45.62 KiB │   1490 │      10 │
│  512 │       4 │ 338.654 ms │ 410.999 ms │ 419.084 ms │ 491.699 ms │  41.69 KiB │    705 │      10 │
│  512 │       8 │ 217.120 ms │ 219.267 ms │ 219.526 ms │ 223.006 ms │  56.30 KiB │    557 │      10 │
│  512 │      16 │ 126.409 ms │ 128.308 ms │ 127.908 ms │ 129.468 ms │  90.00 KiB │    553 │      10 │
│  512 │      32 │ 142.570 ms │ 144.993 ms │ 145.224 ms │ 147.846 ms │ 161.69 KiB │    824 │      10 │
│  512 │      48 │ 123.640 ms │ 138.208 ms │ 140.238 ms │ 159.005 ms │ 234.97 KiB │   1144 │      10 │
└──────┴─────────┴────────────┴────────────┴────────────┴────────────┴────────────┴────────┴─────────┘
       KA (16, 16) Multithreading speedup
┌──────┬─────────┬─────────┬─────────┬─────────┐
│ size │ threads │ speedup │  memory │  allocs │
├──────┼─────────┼─────────┼─────────┼─────────┤
│  512 │       1 │     1.0 │     1.0 │     1.0 │
│  512 │       2 │ 1.91225 │ 2.85435 │ 16.5556 │
│  512 │       4 │ 2.49462 │ 2.60802 │ 7.83333 │
│  512 │       8 │ 4.67595 │ 3.52199 │ 6.18889 │
│  512 │      16 │  7.9908 │  5.6305 │ 6.14444 │
│  512 │      32 │ 7.07128 │ 10.1153 │ 9.15556 │
│  512 │      48 │ 7.41841 │ 14.6999 │ 12.7111 │
└──────┴─────────┴─────────┴─────────┴─────────┘

                               KA (512, 512) multithreading benchmarks
┌──────┬─────────┬────────────┬────────────┬────────────┬────────────┬────────────┬────────┬─────────┐
│ size │ threads │        min │     median │       mean │        max │     memory │ allocs │ samples │
├──────┼─────────┼────────────┼────────────┼────────────┼────────────┼────────────┼────────┼─────────┤
│  512 │       1 │ 595.422 ms │ 596.265 ms │ 596.411 ms │ 597.666 ms │  15.98 KiB │     90 │       9 │
│  512 │       2 │ 307.391 ms │ 309.081 ms │ 313.656 ms │ 350.842 ms │  42.17 KiB │   1270 │      10 │
│  512 │       4 │ 162.528 ms │ 169.486 ms │ 176.088 ms │ 197.538 ms │  41.38 KiB │    683 │      10 │
│  512 │       8 │  97.543 ms │ 165.511 ms │ 161.364 ms │ 280.741 ms │  56.64 KiB │    581 │      10 │
│  512 │      16 │  76.864 ms │  81.888 ms │  81.110 ms │  85.295 ms │  91.16 KiB │    628 │      10 │
│  512 │      32 │  90.844 ms │  96.675 ms │ 112.433 ms │ 158.859 ms │ 161.64 KiB │    818 │      10 │
│  512 │      48 │  89.020 ms │  95.051 ms │  94.529 ms │ 102.653 ms │ 234.95 KiB │   1143 │      10 │
└──────┴─────────┴────────────┴────────────┴────────────┴────────────┴────────────┴────────┴─────────┘

      KA (512, 512) Multithreading speedup
┌──────┬─────────┬─────────┬─────────┬─────────┐
│ size │ threads │ speedup │  memory │  allocs │
├──────┼─────────┼─────────┼─────────┼─────────┤
│  512 │       1 │     1.0 │     1.0 │     1.0 │
│  512 │       2 │ 1.92916 │ 2.63832 │ 14.1111 │
│  512 │       4 │ 3.51808 │ 2.58847 │ 7.58889 │
│  512 │       8 │ 3.60256 │  3.5435 │ 6.45556 │
│  512 │      16 │ 7.28145 │ 5.70283 │ 6.97778 │
│  512 │      32 │ 6.16772 │ 10.1124 │ 9.08889 │
│  512 │      48 │ 6.27313 │ 14.6989 │    12.7 │
└──────┴─────────┴─────────┴─────────┴─────────┘

                               Base.threads multithreading benchmarks
┌──────┬─────────┬────────────┬────────────┬────────────┬────────────┬───────────┬────────┬─────────┐
│ size │ threads │        min │     median │       mean │        max │    memory │ allocs │ samples │
├──────┼─────────┼────────────┼────────────┼────────────┼────────────┼───────────┼────────┼─────────┤
│  512 │       1 │ 600.868 ms │ 603.544 ms │ 606.353 ms │ 630.858 ms │  8.28 KiB │     77 │       9 │
│  512 │       2 │ 309.589 ms │ 310.387 ms │ 317.909 ms │ 364.766 ms │ 30.97 KiB │   1352 │      10 │
│  512 │       4 │ 164.613 ms │ 172.718 ms │ 207.071 ms │ 314.639 ms │ 22.16 KiB │    620 │      10 │
│  512 │       8 │  97.978 ms │ 109.125 ms │ 108.635 ms │ 120.838 ms │ 24.62 KiB │    436 │      10 │
│  512 │      16 │  86.358 ms │  98.160 ms │  97.708 ms │ 103.978 ms │ 37.06 KiB │    547 │      10 │
│  512 │      32 │  75.168 ms │  77.228 ms │  77.223 ms │  79.089 ms │ 61.30 KiB │    728 │      10 │
│  512 │      48 │ 101.534 ms │ 103.528 ms │ 104.326 ms │ 109.657 ms │ 87.64 KiB │   1014 │      10 │
└──────┴─────────┴────────────┴────────────┴────────────┴────────────┴───────────┴────────┴─────────┘

      Base.threads Multithreading speedup
┌──────┬─────────┬─────────┬─────────┬─────────┐
│ size │ threads │ speedup │  memory │  allocs │
├──────┼─────────┼─────────┼─────────┼─────────┤
│  512 │       1 │     1.0 │     1.0 │     1.0 │
│  512 │       2 │ 1.94449 │ 3.73962 │ 17.5584 │
│  512 │       4 │ 3.49439 │ 2.67547 │ 8.05195 │
│  512 │       8 │ 5.53076 │ 2.97358 │ 5.66234 │
│  512 │      16 │  6.1486 │ 4.47547 │  7.1039 │
│  512 │      32 │  7.8151 │ 7.40189 │ 9.45455 │
│  512 │      48 │ 5.82975 │  10.583 │ 13.1688 │
└──────┴─────────┴─────────┴─────────┴─────────┘
```

## Key points:

With a `KernelAbstractions` group size of (Nx, Ny):
1. `Base.Threads.@threads` is comparable to `KernelAbstractions` (modulo some variability), though `KernelAbstractions` allocates more memory.

With a `KernelAbstractions` group size of (16, 16):
1. `Base.Threads.@threads` is faster than `KernelAbstractions` every time.
2. `Base.Threads.@threads` is nearly 2x as fast on a single thread.
3. `Base.Threads.@threads` saturates at 16 threads (for this 512^3 problem) and slows down afterwards. 512^3 is _huge_ (though the stencil is simple).
4. `KernelAbstractions` speeds up monotonically, but is still slower with 48 threads than `Base.Threads.@threads` with 16 threads.

## Machine details

The machine has 2x 12-core NUMA nodes. Each core has 2 threads, so the machine has 48 threads total:

```
greg@tartarus:~/Projects/multithreaded-stencils$ lscpu
Architecture:                    x86_64
CPU op-mode(s):                  32-bit, 64-bit
Byte Order:                      Little Endian
Address sizes:                   46 bits physical, 48 bits virtual
CPU(s):                          48
On-line CPU(s) list:             0-47
Thread(s) per core:              2
Core(s) per socket:              12
Socket(s):                       2
NUMA node(s):                    2
Vendor ID:                       GenuineIntel
CPU family:                      6
Model:                           85
Model name:                      Intel(R) Xeon(R) Silver 4214 CPU @ 2.20GHz
Stepping:                        7
CPU MHz:                         1160.904
CPU max MHz:                     3200.0000
CPU min MHz:                     1000.0000
BogoMIPS:                        4400.00
Virtualization:                  VT-x
L1d cache:                       768 KiB
L1i cache:                       768 KiB
L2 cache:                        24 MiB
L3 cache:                        33 MiB
NUMA node0 CPU(s):               0-11,24-35
NUMA node1 CPU(s):               12-23,36-47
Vulnerability Itlb multihit:     KVM: Mitigation: VMX disabled
Vulnerability L1tf:              Not affected
Vulnerability Mds:               Not affected
Vulnerability Meltdown:          Not affected
Vulnerability Spec store bypass: Mitigation; Speculative Store Bypass disabled via prctl and seccomp
Vulnerability Spectre v1:        Mitigation; usercopy/swapgs barriers and __user pointer sanitization
Vulnerability Spectre v2:        Mitigation; Enhanced IBRS, IBPB conditional, RSB filling
Vulnerability Srbds:             Not affected
Vulnerability Tsx async abort:   Mitigation; TSX disabled
Flags:                           fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb rdtscp lm con
                                 stant_tsc art arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 sdbg
                                 fma cx16 xtpr pdcm pcid dca sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm 3dnowprefetch cpuid_fault epb cat
                                 _l3 cdp_l3 invpcid_single intel_ppin ssbd mba ibrs ibpb stibp ibrs_enhanced tpr_shadow vnmi flexpriority ept vpid ept_ad fsgsbase tsc_adjust bmi1 avx2 s
                                 mep bmi2 erms invpcid cqm mpx rdt_a avx512f avx512dq rdseed adx smap clflushopt clwb intel_pt avx512cd avx512bw avx512vl xsaveopt xsavec xgetbv1 xsaves
                                 cqm_llc cqm_occup_llc cqm_mbm_total cqm_mbm_local dtherm ida arat pln pts pku ospke avx512_vnni md_clear flush_l1d arch_capabilities
```
