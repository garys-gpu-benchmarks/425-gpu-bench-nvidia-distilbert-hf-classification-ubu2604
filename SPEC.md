# SPEC.md: "The Human How"; Exact technical requirements, environment setup, implementation details, etc.

## Execution Description

Runs gpu-bench-distilbert-sst2-train.py twice on distilbert-base-uncased with synthetic SST-2-style batches. sequence_len, batch_size, warmup_iters, and num_iterations come from yaml. Parses samples/s, step time, tokens/s, and peak memory, averages a summary row, and sets status_ok to 1.0. This is not pytest test_bench.py. Sweep dimensions: model_name, dataset_name, num_gpus, sequence_len, batch_size, optimizer, learning_rate, weight_decay.

## Parameters

| Parameter | CLI Flag | Tested Values | Default | Description |
| --- | --- | --- | --- | --- |
| model_name | `--model-name` | smoke=distilbert-base-uncased, baseline=distilbert-base-uncased, extended=distilbert-base-uncased | distilbert-base-uncased | From Parameter list; see Execution Description With Parameters. |
| dataset_name | `--dataset-name` | smoke=glue-sst2-synthetic, baseline=glue-sst2-synthetic, extended=glue-sst2-synthetic | glue-sst2-synthetic | From Parameter list; see Execution Description With Parameters. |
| num_gpus | `--num-gpus` | smoke=1, baseline=1, extended=1 | 1 | From Parameter list; see Execution Description With Parameters. |
| sequence_len | `--sequence-len` | smoke=32, baseline=128, extended=128 | 128 | From Parameter list; see Execution Description With Parameters. |
| batch_size | `--batch-size` | smoke=2, baseline=16, extended=16 | 16 | From Parameter list; see Execution Description With Parameters. |
| optimizer | `--optimizer` | smoke=adamw, baseline=adamw, extended=adamw | adamw | From Parameter list; see Execution Description With Parameters. |
| learning_rate | `--learning-rate` | smoke=5e-05, baseline=5e-05, extended=5e-05 | 5e-05 | From Parameter list; see Execution Description With Parameters. |
| weight_decay | `--weight-decay` | smoke=0.01, baseline=0.01, extended=0.01 | 0.01 | From Parameter list; see Execution Description With Parameters. |
| gradient_accumulation | `--gradient-accumulation` | smoke=1, baseline=1, extended=1 | 1 | From Parameter list; see Execution Description With Parameters. |
| warmup_iters | `--warmup-iters` | smoke=1, baseline=2, extended=5 | 2 | From Parameter list; see Execution Description With Parameters. |
| num_epochs | `--num-epochs` | smoke=1, baseline=1, extended=1 | 1 | From Parameter list; see Execution Description With Parameters. |
| num_iterations | `--num-iterations` | smoke=2, baseline=4130, extended=12300 | 4130 | From Parameter list; see Execution Description With Parameters. |

## Invocation

```bash
Run gpu-bench-distilbert-sst2-train.py via collect_distilbert_train.py
```

## Raw Output Format

raw_results.csv with pass1, pass2, and summary from two runs of the DistilBERT trainer

check,model_name,sequence_len,batch_size,status,samples_per_sec,step_time_ms,step_time_msec,tokens_per_sec,peak_gpu_memory_gb,status_ok
pass1,distilbert-base-uncased,128,16,ok,80,200,200,10240,3,1

## Metrics

- **#1: Training throughput** — stored as `samples_per_sec`.
- **#2: Training step time, ms** — stored as `step_time_ms`.
- **#3: Token throughput** — stored as `tokens_per_sec`.
- **#4: Peak GPU memory** — stored as `peak_gpu_memory_gb`.

## Framework

Runs gpu-bench-distilbert-sst2-train.py twice on distilbert-base-uncased with synthetic SST-2-style batches. sequence_len, batch_size, warmup_iters, and num_iterations come from yaml. Parses samples/s, step time, tokens/s, and peak memory, averages a summary row, and sets status_ok to 1.0.

## Installation and Execution Summary

Run gpu-bench-distilbert-sst2-train.py twice on Hugging Face distilbert-base-uncased with synthetic glue-sst2-synthetic batches, parse RESULT samples/s, step_time_msec, tokens/s, and peak memory, average a summary row, and set status_ok=1.0, to measure DistilBERT training throughput. This is not pytest test_bench.py

## Platform Portability

- **AMD (primary):** ```bash
Run gpu-bench-distilbert-sst2-train.py via collect_distilbert_train.py
```
- **NVIDIA:** Native NVIDIA CUDA workload. Execute on the stated Ubuntu release with the host NVIDIA driver and CUDA userspace. ROCm porting notes do not apply.

## Model Context Protocols

- **Active:** None

## Execution-Loop Validation Contract

EXECUTION CHAIN: `run_benchmark.sh` ➔ raw output ➔ `scripts/parse_results.py` ➔ `results/benchmark.db` ➔ `scripts/validate_results.py`

This benchmark uses a lightweight, SQLite-integrated execution loop for result validation. All validation is performed by `scripts/validate_results.py`.

### Validation script usage

```bash
export BENCHMARK_PYTHON=/usr/bin/python3.13  # optional; select the installed interpreter

# After a live run:
".venv/bin/python" scripts/validate_results.py --db results/benchmark.db

# CI / no-GPU path (seeds fixture and validates it):
".venv/bin/python" scripts/validate_results.py --seed-fixture --quiet

# Override DB path via environment variable:
BENCHMARK_DB=tests/fixtures/benchmark.db \
  ".venv/bin/python" scripts/validate_results.py
```

### Run artifact contract

raw_results.csv with pass1, pass2, and summary from two runs of the DistilBERT trainer

check,model_name,sequence_len,batch_size,status,samples_per_sec,step_time_ms,step_time_msec,tokens_per_sec,peak_gpu_memory_gb,status_ok
pass1,distilbert-base-uncased,128,16,ok,80,200,200,10240,3,1

```bash
bash run_benchmark.sh --help
bash run_benchmark.sh --profile smoke --validate
bash run_benchmark.sh --profile baseline --validate
bash run_benchmark.sh --profile extended --validate
```
`run_benchmark.sh --help` prints usage and exits. The harness calls `scripts/ensure_setup.sh` when `.setup_state` is absent.

### Required integrity checks (built into `validate_results.py`)

1. Latest run exists and `runs.status = 'ok'`.
2. `run.error_message` is NULL.
3. `started_at` and `finished_at` are valid ISO-8601 UTC strings.
4. All required aggregate metrics in `runs` are non-NULL and finite.
5. All required aggregate metrics are physically sensible (positive values). Runs gpu-bench-distilbert-sst2-train.py twice on distilbert-base-uncased with synthetic SST-2-style batches. sequence_len, batch_size, warmup_iters, and num_iterations come from yaml. Parses samples/s, step time, tokens/s, and peak memory, averages a summary row, and sets status_ok to 1.0.
6. At least 2 sample rows exist for the latest `run_id` (sweep coverage).
7. No sample has `status = 'error'`.
8. Runs gpu-bench-distilbert-sst2-train.py twice on distilbert-base-uncased with synthetic SST-2-style batches. sequence_len, batch_size, warmup_iters, and num_iterations come from yaml. Parses samples/s, step time, tokens/s, and peak memory, averages a summary row, and sets status_ok to 1.0.

### Baseline / Threshold configuration (`config/benchmark_config.yaml`)

Expected ranges and gates live in `config/benchmark_config.yaml` under `baselines:` or `thresholds:`. To update them, edit that file — never edit validation code directly.

Threshold key suffixes encode comparison direction when `thresholds:` is present: `_min` → observed value must be ≥ threshold. `_max` → observed value must be ≤ threshold. Informational `baselines:` ranges are not pass/fail gates.
