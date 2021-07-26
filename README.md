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

                                     KA multithreading benchmarks
┌──────┬─────────┬────────────┬────────────┬────────────┬────────────┬────────────┬────────┬─────────┐
│ size │ threads │        min │     median │       mean │        max │     memory │ allocs │ samples │
├──────┼─────────┼────────────┼────────────┼────────────┼────────────┼────────────┼────────┼─────────┤
│  512 │       1 │ 986.203 ms │ 986.372 ms │ 986.947 ms │ 988.908 ms │  15.95 KiB │     89 │       6 │
│  512 │       2 │ 518.000 ms │ 576.111 ms │ 569.696 ms │ 625.940 ms │  43.91 KiB │   1382 │       9 │
│  512 │       4 │ 359.508 ms │ 391.474 ms │ 389.643 ms │ 401.889 ms │  41.62 KiB │    702 │      10 │
│  512 │       8 │ 212.261 ms │ 213.524 ms │ 213.981 ms │ 217.207 ms │  56.30 KiB │    560 │      10 │
│  512 │      16 │ 122.431 ms │ 125.420 ms │ 125.283 ms │ 127.609 ms │  90.20 KiB │    568 │      10 │
│  512 │      32 │ 131.944 ms │ 134.191 ms │ 138.178 ms │ 176.105 ms │ 161.70 KiB │    820 │      10 │
│  512 │      48 │ 108.312 ms │ 118.316 ms │ 117.029 ms │ 122.711 ms │ 234.97 KiB │   1144 │      10 │
└──────┴─────────┴────────────┴────────────┴────────────┴────────────┴────────────┴────────┴─────────┘
[ Info: Writing KA_multithreading_benchmarks.html...
           KA Multithreading speedup
┌──────┬─────────┬─────────┬─────────┬─────────┐
│ size │ threads │ speedup │  memory │  allocs │
├──────┼─────────┼─────────┼─────────┼─────────┤
│  512 │       1 │     1.0 │     1.0 │     1.0 │
│  512 │       2 │ 1.71212 │  2.7522 │ 15.5281 │
│  512 │       4 │ 2.51964 │ 2.60921 │ 7.88764 │
│  512 │       8 │ 4.61949 │ 3.52889 │ 6.29213 │
│  512 │      16 │ 7.86452 │ 5.65426 │ 6.38202 │
│  512 │      32 │  7.3505 │ 10.1361 │ 9.21348 │
│  512 │      48 │ 8.33676 │ 14.7287 │ 12.8539 │
└──────┴─────────┴─────────┴─────────┴─────────┘
[ Info: Writing KA_Multithreading_speedup.html...
                               Base.threads multithreading benchmarks
┌──────┬─────────┬────────────┬────────────┬────────────┬────────────┬───────────┬────────┬─────────┐
│ size │ threads │        min │     median │       mean │        max │    memory │ allocs │ samples │
├──────┼─────────┼────────────┼────────────┼────────────┼────────────┼───────────┼────────┼─────────┤
│  512 │       1 │ 567.135 ms │ 570.299 ms │ 580.880 ms │ 624.192 ms │  8.28 KiB │     77 │       9 │
│  512 │       2 │ 296.352 ms │ 298.581 ms │ 300.574 ms │ 312.279 ms │ 29.84 KiB │   1279 │      10 │
│  512 │       4 │ 168.154 ms │ 170.621 ms │ 180.186 ms │ 247.044 ms │ 22.30 KiB │    627 │      10 │
│  512 │       8 │  97.255 ms │  98.949 ms │  99.506 ms │ 104.764 ms │ 25.92 KiB │    517 │      10 │
│  512 │      16 │  75.043 ms │  75.468 ms │  76.056 ms │  80.112 ms │ 36.11 KiB │    487 │      10 │
│  512 │      32 │  92.208 ms │  93.905 ms │  93.877 ms │  96.127 ms │ 60.97 KiB │    710 │      10 │
│  512 │      48 │  88.974 ms │  93.369 ms │  93.362 ms │  97.865 ms │ 87.73 KiB │   1017 │      10 │
└──────┴─────────┴────────────┴────────────┴────────────┴────────────┴───────────┴────────┴─────────┘
[ Info: Writing Base.threads_multithreading_benchmarks.html...
      Base.threads Multithreading speedup
┌──────┬─────────┬─────────┬─────────┬─────────┐
│ size │ threads │ speedup │  memory │  allocs │
├──────┼─────────┼─────────┼─────────┼─────────┤
│  512 │       1 │     1.0 │     1.0 │     1.0 │
│  512 │       2 │ 1.91003 │ 3.60377 │ 16.6104 │
│  512 │       4 │  3.3425 │ 2.69245 │ 8.14286 │
│  512 │       8 │ 5.76356 │ 3.13019 │ 6.71429 │
│  512 │      16 │ 7.55687 │ 4.36038 │ 6.32468 │
│  512 │      32 │ 6.07314 │ 7.36226 │ 9.22078 │
│  512 │      48 │ 6.10799 │ 10.5943 │ 13.2078 │
└──────┴─────────┴─────────┴─────────┴─────────┘
```

## Key points:

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
