vimreg() {
  if ! command -v jq >/dev/null 2>&1; then
    echo 'error: jq is not installed' >&2
    return 1
  fi
  # shellcheck disable=SC2154
  if [ -z "${VIM_TERMINAL}" ]; then
    echo 'error: you are running vimreg outside vim terminal' >&2
    return 2
  fi
}
