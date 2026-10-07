# PRD.md:  "The Why"; Product requirements, benchmark metadata table, high-level requirements, etc.

Product Requirements Document

"The Why"; Product requirements, benchmark metadata table, high-level requirements, etc. Defines the benchmark goal, validation objective, test name, benchmark number, category, and high-level success criteria.

## Benchmark Matrix Document Metadata (via benchmark_specification.json)

This PRD.md section is populated from benchmark_specification.json, which is the structured source of benchmark-specific product requirements.

## Workload Number
425

## Workload Name
DistilBERT NLP Training Baseline

## Execution Summary (Run and Measure)
Run gpu-bench-distilbert-sst2-train.py twice on Hugging Face distilbert-base-uncased with synthetic glue-sst2-synthetic batches, parse RESULT samples/s, step_time_msec, tokens/s, and peak memory, average a summary row, and set status_ok=1.0, to measure DistilBERT training throughput. This is not pytest test_bench.py

## Main Goal
Measure DistilBERT classification training throughput

## Validation Objective
Validates DistilBERT classification training throughput from samples/s, step time, and tokens/s

## Workload Category
Training, Inference, Model Workloads

## Validation Requirement

The benchmark must include an automated SQLite-integrated validation layer that verifies persisted results from `results/benchmark.db`. Validation must confirm:

1. The benchmark run completed successfully with no tool errors.
2. Required samples and aggregate metrics were persisted for every swept shape.
3. Metrics are finite and physically sensible (positive, within plausible bounds).
4. Measured values satisfy configured thresholds when the workload defines pass/fail gates.
5. The benchmark fails validation when required data is missing, invalid, or outside bounds.

## Non-Functional Requirements

| Requirement | Target |
|---|---|
| Automation | Runs to completion without manual intervention after `bash run_benchmark.sh` |
| Idempotency | Re-running `run_benchmark.sh` appends a new run; never corrupts existing rows |
| Persistence | All metrics survive script exit; `results/benchmark.db` is the durable record |
