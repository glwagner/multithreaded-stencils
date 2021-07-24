# multithreaded-stencils

This repo implements multithreaded three-dimensional loops over simple three-dimensional Laplacian
stencil calculations in Julia, using both `Base.Threads.@threads` and [`KernelAbstractions.jl`](https://github.com/JuliaGPU/KernelAbstractions.jl).

First, a sanity check that the stencils work (and we get some diffusion):

![image](https://user-images.githubusercontent.com/15271942/126853537-220f146e-7945-4dd3-8d31-eed50bdb208e.png)

Next, benchmarks for multithreaded, looped, three-dimensional stencil computations (KA = `KernelAbstractions.jl`).
Note that "`size=512`" means `Nx = Ny = Nz = 512`, or a total size `512^3 = 134217728`.
This is realistic or even somewhat large (and therefore favorable for multithreading) with respect to typical
fluid dynamics computations.

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
