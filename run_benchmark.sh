#!/usr/bin/env bash
# File: run_benchmark.sh
# Description: Runs gpu-bench-distilbert-sst2-train.
# Execution: bash run_benchmark.sh [--smoke|--baseline|--extended]
# Options: --smoke, --baseline, --extended, --config, --help
# Requirements: bash, python3, repository-local .venv
# Dependencies: common.sh, collect_workload.py
# License: Apache-2.0
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_NAME="$(basename "${REPO_ROOT}")"
cd "${REPO_ROOT}"
# shellcheck disable=SC1091
source scripts/lib/common.sh
capture_benchmark_run_command_submitted "$@"

usage() {
  cat <<'USAGE'

Usage: bash run_benchmark.sh [OPTIONS]

Workload Name:          DistilBERT NLP Training Baseline
Main Goal:              Measure DistilBERT classification training throughput
Command Tools Executed: Run gpu-bench-distilbert-sst2-train.py via collect_distilbert_train.py

Profiles (default: --smoke):
  --smoke                       Run smoke profile
  --baseline                    Run baseline profile
  --extended                    Run extended profile

Parameters (override the profile's value):
  --model-name <value>          Model or weights identifier to load
                                  all profiles: distilbert-base-uncased
  --sequence-len <n>            Total input sequence or context length
                                  smoke:             32
                                  baseline/extended: 128
  --batch-size <n>              Number of items processed together
                                  smoke:             2
                                  baseline/extended: 16
  --learning-rate <n>           Optimizer step size (smoke/baseline/extended: 5e-05)
  --weight-decay <value>        Shared workload parameter (smoke/baseline/extended: 0.01)
  --num-iterations <n>          Number of timed repetitions (smoke 2, baseline 2880, extended 9420)
  --gradient-accumulation <n>   Number of forward/backward passes accumulated per optimizer update
                                  all profiles: 1
  --warmup-iters <n>            Untimed warm-up repetitions before measurement
                                  smoke:    1
                                  baseline: 2
                                  extended: 5

General options:
  --config <file>               Config file (default: config/benchmark_config.yaml)
  --quiet                       Suppress nonessential stdout
  --log-level <level>           ERROR|WARN|INFO|DEBUG (default: INFO; DEBUG also prints [RUN] commands)
  --specification               Print this workload's specification and exit
  --help                        Show this help and exit

Examples:
  bash run_benchmark.sh --smoke
  bash run_benchmark.sh --baseline
  bash run_benchmark.sh --extended
  bash run_benchmark.sh --baseline --batch-size 8
USAGE
}

for _help_arg in "$@"; do
  case "${_help_arg}" in
    --help) usage; exit 0 ;;
    --specification)
      python3 scripts/print_benchmark_definition.py
      exit 0
      ;;
  esac
done

run_profiles_in_order "${REPO_ROOT}/run_benchmark.sh" "$@"

PROFILE="smoke"
CONFIG_FILE="config/benchmark_config.yaml"
QUIET=0
LOG_LEVEL_VALUE="INFO"
MODEL_NAME=""
SEQUENCE_LEN=""
BATCH_SIZE=""
LEARNING_RATE=""
WEIGHT_DECAY=""
NUM_ITERATIONS=""
GRADIENT_ACCUMULATION=""
WARMUP_ITERS=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --smoke) PROFILE="smoke"; shift ;;
    --baseline) PROFILE="baseline"; shift ;;
    --extended) PROFILE="extended"; shift ;;
    --config) CONFIG_FILE="${2:-}"; shift 2 ;;
    --validate) shift ;;  # ignored; result validation always runs
    --quiet) QUIET=1; shift ;;
    --log-level) LOG_LEVEL_VALUE="${2:-}"; shift 2 ;;
    --model-name) MODEL_NAME="${2:-}"; shift 2 ;;
    --sequence-len) SEQUENCE_LEN="${2:-}"; shift 2 ;;
    --batch-size) BATCH_SIZE="${2:-}"; shift 2 ;;
    --learning-rate) LEARNING_RATE="${2:-}"; shift 2 ;;
    --weight-decay) WEIGHT_DECAY="${2:-}"; shift 2 ;;
    --num-iterations) NUM_ITERATIONS="${2:-}"; shift 2 ;;
    --gradient-accumulation) GRADIENT_ACCUMULATION="${2:-}"; shift 2 ;;
    --warmup-iters) WARMUP_ITERS="${2:-}"; shift 2 ;;
    --help|--specification) shift ;;
    *) die "Unknown option: $1" ;;
  esac
done


set_log_level "${LOG_LEVEL_VALUE}"
begin_benchmark_run "${PROFILE}"
bash scripts/ensure_setup.sh
mark_benchmark_measure_start
PYTHON_BIN="${REPO_ROOT}/.venv/bin/python"
[[ -x "${PYTHON_BIN}" ]] || die "Missing ${PYTHON_BIN}; run bash setup.sh --assume-yes first."

yaml_get() {
  "${PYTHON_BIN}" - "${CONFIG_FILE}" "${PROFILE}" "$1" <<'PY'
import sys
from pathlib import Path
import yaml
key = sys.argv[3]
profile = sys.argv[2]
cfg = yaml.safe_load(Path(sys.argv[1]).read_text(encoding="utf-8")) or {}
sweep = cfg.get("sweep") or {}
raw_value = sweep.get(key, "")
if isinstance(raw_value, dict):
    raw_value = raw_value.get(profile, next(iter(raw_value.values()), ""))
if isinstance(raw_value, list):
    raw_value = ",".join(str(item) for item in raw_value)
print("" if raw_value is None else raw_value)
PY
}

MODEL_NAME="${MODEL_NAME:-$(yaml_get model_name)}"
SEQUENCE_LEN="${SEQUENCE_LEN:-$(yaml_get sequence_len)}"
BATCH_SIZE="${BATCH_SIZE:-$(yaml_get batch_size)}"
LEARNING_RATE="${LEARNING_RATE:-$(yaml_get learning_rate)}"
WEIGHT_DECAY="${WEIGHT_DECAY:-$(yaml_get weight_decay)}"
NUM_ITERATIONS="${NUM_ITERATIONS:-$(yaml_get num_iterations)}"
GRADIENT_ACCUMULATION="${GRADIENT_ACCUMULATION:-$(yaml_get gradient_accumulation)}"
WARMUP_ITERS="${WARMUP_ITERS:-$(yaml_get warmup_iters)}"
OUTPUT_FORMAT="$(yaml_get output_format)"
OUTPUT_FORMAT="${OUTPUT_FORMAT:-csv}"

BENCHMARK_RUN_COMMAND="bash run_benchmark.sh --${PROFILE}"
[[ -n "${MODEL_NAME}" ]] && BENCHMARK_RUN_COMMAND+=" --model-name $(printf %q "${MODEL_NAME}")"
[[ -n "${SEQUENCE_LEN}" ]] && BENCHMARK_RUN_COMMAND+=" --sequence-len $(printf %q "${SEQUENCE_LEN}")"
[[ -n "${BATCH_SIZE}" ]] && BENCHMARK_RUN_COMMAND+=" --batch-size $(printf %q "${BATCH_SIZE}")"
[[ -n "${LEARNING_RATE}" ]] && BENCHMARK_RUN_COMMAND+=" --learning-rate $(printf %q "${LEARNING_RATE}")"
[[ -n "${WEIGHT_DECAY}" ]] && BENCHMARK_RUN_COMMAND+=" --weight-decay $(printf %q "${WEIGHT_DECAY}")"
[[ -n "${NUM_ITERATIONS}" ]] && BENCHMARK_RUN_COMMAND+=" --num-iterations $(printf %q "${NUM_ITERATIONS}")"
[[ -n "${GRADIENT_ACCUMULATION}" ]] && BENCHMARK_RUN_COMMAND+=" --gradient-accumulation $(printf %q "${GRADIENT_ACCUMULATION}")"
[[ -n "${WARMUP_ITERS}" ]] && BENCHMARK_RUN_COMMAND+=" --warmup-iters $(printf %q "${WARMUP_ITERS}")"
set_benchmark_run_command "${BENCHMARK_RUN_COMMAND}"

HOSTNAME_VALUE="$(hostname -s 2>/dev/null || hostname)"
RUN_DIR="${REPO_ROOT}/results/raw/$(benchmark_raw_run_dir_name "${REPO_NAME}" "${HOSTNAME_VALUE}")"
mkdir -p "${RUN_DIR}"
RAW_FILE="${RUN_DIR}/raw_output.txt"
set_benchmark_run_dir "${RUN_DIR}"
COMMAND_LOG="${RUN_DIR}/commands_executed.sh"
{ echo "#!/usr/bin/env bash"; echo "set -euo pipefail"; } > "${COMMAND_LOG}"
chmod +x "${COMMAND_LOG}"
printf 'profile=%s\noutput_format=%s\n' "${PROFILE}" "${OUTPUT_FORMAT}" > "${RUN_DIR}/cli_options.env"
export PYTHONUNBUFFERED=1
export PATH="/opt/rocm/bin:${PATH}"
export LD_LIBRARY_PATH="/opt/rocm/lib:/opt/rocm/lib64:${LD_LIBRARY_PATH:-}"
cp run_benchmark.sh "${RUN_DIR}/script.sh"
mask_environment "${RUN_DIR}/env_variables.txt"
: > "${RUN_DIR}/run.log"

run_collection() {
  log_section "Collection"
  local help collect_cmd
  local -a collect_args=(--run-dir "${RUN_DIR}" --raw-file "${RAW_FILE}" --profile "${PROFILE}")
  help="$("${PYTHON_BIN}" scripts/collect_workload.py --help 2>&1 || true)"
  grep -q -- '--config' <<<"${help}" && collect_args+=(--config "${CONFIG_FILE}")
  grep -q -- '--output-format' <<<"${help}" && collect_args+=(--output-format "${OUTPUT_FORMAT}")
  grep -q -- '--model-name' <<<"${help}" && collect_args+=(--model-name "${MODEL_NAME}")
  grep -q -- '--sequence-len' <<<"${help}" && collect_args+=(--sequence-len "${SEQUENCE_LEN}")
  grep -q -- '--batch-size' <<<"${help}" && collect_args+=(--batch-size "${BATCH_SIZE}")
  grep -q -- '--learning-rate' <<<"${help}" && collect_args+=(--learning-rate "${LEARNING_RATE}")
  grep -q -- '--weight-decay' <<<"${help}" && collect_args+=(--weight-decay "${WEIGHT_DECAY}")
  grep -q -- '--num-iterations' <<<"${help}" && collect_args+=(--num-iterations "${NUM_ITERATIONS}")
  grep -q -- '--gradient-accumulation' <<<"${help}" && collect_args+=(--gradient-accumulation "${GRADIENT_ACCUMULATION}")
  grep -q -- '--warmup-iters' <<<"${help}" && collect_args+=(--warmup-iters "${WARMUP_ITERS}")

  printf -v collect_cmd '%q ' "${PYTHON_BIN}" scripts/collect_workload.py "${collect_args[@]}"
  log_run "${collect_cmd}"
  echo "${collect_cmd}" >> "${COMMAND_LOG}"
  set +e
  "${PYTHON_BIN}" scripts/collect_workload.py "${collect_args[@]}" 2>&1 | tee -a "${RUN_DIR}/run.log" | hide_run_lines
  command_status="${PIPESTATUS[0]}"
  set -e
  if [[ "${command_status}" -ne 0 ]]; then
    die "collection failed with status ${command_status}"
  fi
}

run_parse() {
  log_section "Parse"
  local parse_cmd
  printf -v parse_cmd '%q ' "${PYTHON_BIN}" scripts/parse_results.py --raw-file "${RAW_FILE}" --db "${REPO_ROOT}/results/benchmark.db" --summary "${REPO_ROOT}/results/summary.json" --definition "${REPO_ROOT}/benchmark_specification.json" --run-dir "${RUN_DIR}"
  log_run "${parse_cmd}"
  echo "${parse_cmd}" >> "${COMMAND_LOG}"
  "${PYTHON_BIN}" scripts/parse_results.py --raw-file "${RAW_FILE}" --db "${REPO_ROOT}/results/benchmark.db" --summary "${REPO_ROOT}/results/summary.json" --definition "${REPO_ROOT}/benchmark_specification.json" --run-dir "${RUN_DIR}" || die "parse failed"
}

run_validate() {
  log_section "Validation"
  local validate_cmd
  printf -v validate_cmd '%q ' "${PYTHON_BIN}" scripts/validate_results.py --db "${REPO_ROOT}/results/benchmark.db" --config "${CONFIG_FILE}"
  log_run "${validate_cmd}"
  echo "${validate_cmd}" >> "${COMMAND_LOG}"
  "${PYTHON_BIN}" scripts/validate_results.py --db "${REPO_ROOT}/results/benchmark.db" --config "${CONFIG_FILE}" || die "validation failed"
}

run_collection
run_parse
run_validate
record_benchmark_stop
capture_journal_warnings "${RUN_DIR}" "${BENCHMARK_START_DATETIME}" "${STOP_TIME}"
bash scripts/collect_hw_sw_info.sh "${RUN_DIR}"
START_EPOCH="$(date -u -d "${BENCHMARK_START_DATETIME}" +%s)"
STOP_EPOCH="$(date -u -d "${STOP_TIME}" +%s)"  # Ledger keeps whole seconds. The summary prints tenths.
ELAPSED="$((STOP_EPOCH - START_EPOCH))"
(( ELAPSED < 0 )) && ELAPSED=0
if [[ "${QUIET}" -eq 0 ]]; then
  bash scripts/print_run_metadata.sh "${REPO_ROOT}" || true
  echo "[INFO] ===== Benchmark Summary ====="
  echo "[INFO] Run ID: $(basename "${RUN_DIR}") | Status: ok | Samples: $(${PYTHON_BIN} -c 'import json; print(json.load(open("results/summary.json"))["sample_count"])') | Profile: ${PROFILE} | Device: $(display_device)"
  print_benchmark_summary_commands
  echo "[INFO] Start time: ${BENCHMARK_START_DATETIME}"
  echo "[INFO] Stop time: ${STOP_TIME}"
  echo "[INFO] Elapsed time: $(benchmark_elapsed_display) sec"
  echo "[INFO] Artifacts: ${RUN_DIR}"
  echo "[INFO] SQLite DB: ${REPO_ROOT}/results/benchmark.db"
  echo "[INFO]"
  "${PYTHON_BIN}" scripts/print_metric_summary.py --definition benchmark_specification.json --summary results/summary.json
  echo "[INFO]"
fi
write_metrics_summary_txt

"${PYTHON_BIN}" scripts/update_runtime_ledger.py \
  --profile "${PROFILE}" --start-datetime "${BENCHMARK_START_DATETIME}" --total-runtime "${ELAPSED}" \
  --exit-code 0 --failure-stage ok --failure-detail "" --raw-run-dir "${RUN_DIR}" \
  --runtime-root "${REPO_ROOT}" \
  --run-benchmark-command-submitted "${BENCHMARK_RUN_COMMAND_SUBMITTED}" \
  --run-benchmark-command-fully-resolved "${BENCHMARK_RUN_COMMAND}" \
  --notes "validated run" \
  || printf '[WARN] Runtime ledger update failed\n' >&2
finish_benchmark_run
