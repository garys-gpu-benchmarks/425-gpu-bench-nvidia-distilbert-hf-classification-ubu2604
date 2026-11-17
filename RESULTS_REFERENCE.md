# Results: 425 DistilBERT NLP Training Baseline

**Main goal:** Measure DistilBERT classification training throughput  
**Tools:** Run gpu-bench-distilbert-sst2-train.py via collect_distilbert_train.py

Reference results measured by the maintainer on the system shown in each section (generator TEMPLATE_00_145 · recorded 2026-11-17). Your own runs write `results/RESULTS_ACTUAL.md` in the same format.

> Smoke runs use deliberately small sizes. They check that the workload installs and runs end to end; their numbers are not performance results. Baseline and extended are.

<!-- profile:smoke -->
## smoke

- **System:** 1× NVIDIA H100 NVL (95830 MiB) · AMD EPYC 9374F 32-Core Processor · Ubuntu 26.04.1 LTS · kernel 6.8.0-138-generic · driver 595.112.07
- **Run:** 2026-11-17T11:25:45Z · status **PASS** (exit 0)
- **Time (mm:ss):** setup 01:16 · benchmark 00:01 · whole run 01:26
- **Source:** run 425_20261117_112545
- **Command:** `bash run_benchmark.sh --smoke --model-name distilbert-base-uncased --sequence-len 32 --batch-size 2 --learning-rate 5.0000000000000002E-5 --weight-decay 0.01 --num-iterations 2 --gradient-accumulation 1 --warmup-iters 1`

| # | Metric | Result |
|---|---|---|
| 1 | Training throughput (samples_per_sec) | 53.501958 |
| 2 | Training step time, ms (step_time_ms) | 37.381809 |
| 3 | Token throughput (tokens_per_sec) | 1712.062667 |
| 4 | Peak GPU memory (peak_gpu_memory_gb) | 1.411881 |
<!-- /profile:smoke -->
