# Results: 425 DistilBERT NLP Training Baseline

**Main goal:** Measure DistilBERT classification training throughput  
**Tools:** Run gpu-bench-distilbert-sst2-train.py via collect_distilbert_train.py

Reference results measured by the maintainer on the system shown in each section (generator TEMPLATE_00_140 · recorded 2026-11-13). Your own runs write `results/RESULTS_ACTUAL.md` in the same format.

> Smoke runs use deliberately small sizes. They check that the workload installs and runs end to end; their numbers are not performance results. Baseline and extended are.

<!-- profile:smoke -->
## smoke

- **System:** 1× NVIDIA H100 PCIe (81559 MiB) · Intel(R) Xeon(R) Platinum 8352Y CPU @ 2.20GHz · Ubuntu 26.04.1 LTS · kernel 6.8.0-138-generic · driver 595.91.07
- **Run:** 2026-11-13T21:11:36Z · status **PASS** (exit 0)
- **Time (mm:ss):** setup 02:12 · benchmark 00:07 · whole run 02:37
- **Source:** run 425_20261113_211136
- **Command:** `bash run_benchmark.sh --smoke --model-name distilbert-base-uncased --sequence-len 32 --batch-size 2 --learning-rate 5.0000000000000002E-5 --weight-decay 0.01 --num-iterations 2 --gradient-accumulation 1 --warmup-iters 1`

| # | Metric | Result |
|---|---|---|
| 1 | Training throughput (samples_per_sec) | 36.33497 |
| 2 | Training step time, ms (step_time_ms) | 55.043392 |
| 3 | Token throughput (tokens_per_sec) | 1162.719038 |
| 4 | Peak GPU memory (peak_gpu_memory_gb) | 1.411881 |
<!-- /profile:smoke -->
