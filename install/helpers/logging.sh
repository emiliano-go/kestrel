kestrel_log_to_stdout() {
  [[ ${KESTREL_LOG_TO_STDOUT:-} == "1" || -z ${KESTREL_INSTALL_LOG_FILE:-} ]]
}

kestrel_log_line() {
  if kestrel_log_to_stdout; then
    echo "$1"
  else
    echo "$1" >>"$KESTREL_INSTALL_LOG_FILE"
  fi
}

start_install_log() {
  if ! kestrel_log_to_stdout; then
    mkdir -p "$(dirname "$KESTREL_INSTALL_LOG_FILE")"
    touch "$KESTREL_INSTALL_LOG_FILE"
    chmod 666 "$KESTREL_INSTALL_LOG_FILE" 2>/dev/null || true
  fi

  export KESTREL_START_TIME="${KESTREL_START_TIME:-$(date '+%Y-%m-%d %H:%M:%S')}"
  export KESTREL_START_EPOCH="${KESTREL_START_EPOCH:-$(date +%s)}"

  kestrel_log_line "=== Kestrel Setup Started: $KESTREL_START_TIME ==="
}

stop_install_log() {
  local end_time end_epoch duration mins secs
  end_time=$(date '+%Y-%m-%d %H:%M:%S')
  end_epoch=$(date +%s)

  kestrel_log_line "=== Kestrel Setup Completed: $end_time ==="

  if [[ -n ${KESTREL_START_EPOCH:-} ]]; then
    duration=$((end_epoch - KESTREL_START_EPOCH))
    mins=$((duration / 60))
    secs=$((duration % 60))
    kestrel_log_line "Kestrel setup: ${mins}m ${secs}s"
  fi
}

run_logged() {
  local script="$1"
  local exit_code errexit_was_set=0

  kestrel_log_line "[$(date '+%Y-%m-%d %H:%M:%S')] Starting: $script"

  case $- in
    *e*)
      errexit_was_set=1
      set +e
      ;;
  esac

  local runner=(bash -eE)
  if [[ ${KESTREL_INSTALL_DEBUG:-} == "1" ]]; then
    runner=(bash -x -eE)
  fi

  if kestrel_log_to_stdout; then
    PS4='+ ${BASH_SOURCE[0]##*/}:${LINENO}:${FUNCNAME[0]:-main}: ' \
      "${runner[@]}" -c 'source "$1"' bash "$script" </dev/null 2>&1
  else
    PS4='+ ${BASH_SOURCE[0]##*/}:${LINENO}:${FUNCNAME[0]:-main}: ' \
      "${runner[@]}" -c 'source "$1"' bash "$script" </dev/null >>"$KESTREL_INSTALL_LOG_FILE" 2>&1
  fi

  exit_code=$?
  (( errexit_was_set )) && set -e

  if (( exit_code == 0 )); then
    kestrel_log_line "[$(date '+%Y-%m-%d %H:%M:%S')] Completed: $script"
  else
    kestrel_log_line "[$(date '+%Y-%m-%d %H:%M:%S')] Failed: $script (exit code: $exit_code)"
  fi

  return $exit_code
}
