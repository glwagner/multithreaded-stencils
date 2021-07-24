include("benchmark_utils.jl")

using BSON

# Benchmark parameters

N = 512
n_threads = min.(2 .^ (0:10), Sys.CPU_THREADS) |> unique

# Run and collect benchmarks

for t in n_threads
    @info "Benchmarking KernelAbstractions versus Base.Threads multithreading (N=$N, threads=$t)..."
    julia = Base.julia_cmd()
    run(`$julia -t $t --project run_ka_vs_base_benchmark.jl $N`)
end

ka_suite = BenchmarkGroup(["size", "threads"])
base_threads_suite = BenchmarkGroup(["size", "threads"])

for t in n_threads
    ka_suite[(N, t)] = BSON.load("multithreading_benchmark_$t.bson")[:KernelAbstractions]
    base_threads_suite[(N, t)] = BSON.load("multithreading_benchmark_$t.bson")[:Base_threads]
end

# Summarize benchmarks

for (name, suite) in zip(("KA", "Base.threads"), (ka_suite, base_threads_suite))
    df = benchmarks_dataframe(suite)
    sort!(df, :threads)
    benchmarks_pretty_table(df, title="$name multithreading benchmarks")

    suite_Δ = speedups_suite(suite, base_case=(N, 1))
    df_Δ = speedups_dataframe(suite_Δ)
    sort!(df_Δ, :threads)
    benchmarks_pretty_table(df_Δ, title="$name Multithreading speedup")
end
