clip() {
  if [[ -z "$CLIP" ]]; then
    echo "error: CLIP environment variable is not defined. Please set it to a file path."
    return 1
  fi
  if [[ -t 0 ]]; then
    # 如果没有从标准输入读取数据，则是输出剪贴板内容到文件
    if [[ -f "$CLIP" ]]; then
      # 如果文件存在但为空
      if [[ ! -s "$CLIP" ]]; then
        echo "Clipboard is empty"
      else
        cat "$CLIP"
      fi
    else
      echo "error: .clip file not found"
    fi
  else
    # 如果从标准输入读取数据，则将数据写入剪贴板文件
    cat >"$CLIP"
  fi
}

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

  local get=false
  local reg='"'
  local tee=false
  case "$1" in
  --get | -g)
    get=true
    shift
    ;;
  --list | -l)
    get=true
    reg='--list'
    shift
    ;;
  --tee | -t)
    tee=true
    shift
    ;;
  *) ;;
  esac
  [ "${reg}" != '--list' ] && [ $# -gt 0 ] && reg=$1
  local file
  file=$(mktemp -u)
  # shellcheck disable=SC2064
  trap "rm -f '${file}'" EXIT INT TERM
  if ${get}; then
    mkfifo "${file}"
    __call_tapi_reg get "${reg}" "${file}"
    cat "${file}"
  else
    if ${tee}; then
      tee "${file}"
    else
      cat >"${file}"
    fi
    __call_tapi_reg set "${reg}" "${file}"
  fi
}

__call_tapi_reg() {
  local cmd
  local arg1
  local arg2
  # -n 输出参数的值，不添加换行符
  # -R 表示原始输入模式，直接处理原始输入
  # --slurp 将所有输入合并为一个数组
  # . 表示输入的原始内容
  cmd=$(echo -n "$1" | jq -R --slurp .)
  arg1=$(echo -n "$2" | jq -R --slurp .)
  arg2=$(echo -n "$3" | jq -R --slurp .)
  # \e]51; 这是一个控制字符序列，表示终端的自定义控制序列
  # \x07 这是 ASCII 控制字符 BEL（响铃），用于标识控制序列的结束
  # 通过向终端发送一个特定的控制序列来调用 Vim 内部的函数。
  printf '\e]51;["call","Tapi_reg",[%s,%s,%s]]\x07' "${cmd}" "${arg1}" "${arg2}"
}
