helios_log_to_stdout() {
  [[ ${HELIOS_LOG_TO_STDOUT:-} == "1" || -z ${HELIOS_INSTALL_LOG_FILE:-} ]]
}

helios_log_line() {
  if helios_log_to_stdout; then
    echo "$1"
  else
    echo "$1" >>"$HELIOS_INSTALL_LOG_FILE"
  fi
}

start_install_log() {
  if ! helios_log_to_stdout; then
    mkdir -p "$(dirname "$HELIOS_INSTALL_LOG_FILE")"
    touch "$HELIOS_INSTALL_LOG_FILE"
    chmod 666 "$HELIOS_INSTALL_LOG_FILE" 2>/dev/null || true
  fi

  export HELIOS_START_TIME="${HELIOS_START_TIME:-$(date '+%Y-%m-%d %H:%M:%S')}"
  export HELIOS_START_EPOCH="${HELIOS_START_EPOCH:-$(date +%s)}"

  helios_log_line "=== HeliOS Setup Started: $HELIOS_START_TIME ==="
}

stop_install_log() {
  local end_time end_epoch duration mins secs
  end_time=$(date '+%Y-%m-%d %H:%M:%S')
  end_epoch=$(date +%s)

  helios_log_line "=== HeliOS Setup Completed: $end_time ==="

  if [[ -n ${HELIOS_START_EPOCH:-} ]]; then
    duration=$((end_epoch - HELIOS_START_EPOCH))
    mins=$((duration / 60))
    secs=$((duration % 60))
    helios_log_line "HeliOS setup: ${mins}m ${secs}s"
  fi
}

run_logged() {
  local script="$1"
  local exit_code errexit_was_set=0

  helios_log_line "[$(date '+%Y-%m-%d %H:%M:%S')] Starting: $script"

  case $- in
    *e*)
      errexit_was_set=1
      set +e
      ;;
  esac

  local runner=(bash -eE)
  if [[ ${HELIOS_INSTALL_DEBUG:-} == "1" ]]; then
    runner=(bash -x -eE)
  fi

  if helios_log_to_stdout; then
    PS4='+ ${BASH_SOURCE[0]##*/}:${LINENO}:${FUNCNAME[0]:-main}: ' \
      "${runner[@]}" -c 'source "$1"' bash "$script" </dev/null 2>&1
  else
    PS4='+ ${BASH_SOURCE[0]##*/}:${LINENO}:${FUNCNAME[0]:-main}: ' \
      "${runner[@]}" -c 'source "$1"' bash "$script" </dev/null >>"$HELIOS_INSTALL_LOG_FILE" 2>&1
  fi

  exit_code=$?
  (( errexit_was_set )) && set -e

  if (( exit_code == 0 )); then
    helios_log_line "[$(date '+%Y-%m-%d %H:%M:%S')] Completed: $script"
  else
    helios_log_line "[$(date '+%Y-%m-%d %H:%M:%S')] Failed: $script (exit code: $exit_code)"
  fi

  return $exit_code
}
