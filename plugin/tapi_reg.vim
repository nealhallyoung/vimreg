scriptencoding utf-8

" 避免重复加载
if exists('g:loaded_tapi_reg') && g:loaded_tapi_reg
  finish
endif

let g:loaded_tapi_reg = 1

" 记录当前 vim 的兼容性，在使用完脚本后，再还原回去
let s:save_cpo = &cpo
" 将 cpoptions 的值重置为 Vim 的默认值。
set cpo&vim

" 自动加载 VIMREG 中的内容到 " 寄存器
function! LoadVimRegToUnnamedRegister() abort
  " 获取环境变量 CLIP 指定的文件路径
  let vimreg_file = getenv('CLIP')
  if vimreg_file == ''
    echo 'VIMREG environment variable is not set.'
    return
  endif

  " 检查文件是否存在
  if filereadable(vimreg_file)
    " 读取文件的内容并将其加载到无名寄存器 "
    let file_content = join(readfile(vimreg_file), "\n")
    call setreg('"', file_content)
  else
    echo 'No VIMREG file found at ' . vimreg_file
  endif
endfunction

" 每次启动 Vim 时将 VIMREG 环境变量指定的文件内容加载到无名寄存器 "
autocmd VimEnter * call LoadVimRegToUnnamedRegister()

" 定义全局变量来保存寄存器的初始内容
let g:last_register_content = getreg('"')

" 监听 'registers' 命令来检测寄存器变化
function! WriteRegisterToFile() abort
  " 获取寄存器 " 的当前内容
  let current_content = getreg('"')

  " 检查寄存器的内容是否变化
  if current_content != g:last_register_content
    " 将内容写入指定的文件
    let vimreg_file = getenv('CLIP')
    call writefile([current_content], vimreg_file)

    " 更新记录的内容
    let g:last_register_content = current_content
    echo '寄存器 " 的内容已更新，并写入到文件中'
  endif
endfunction

" 设置一个定时器来定期检查寄存器的变化
" 每秒检查一次
set updatetime=1000  " 设置为 1 秒
autocmd CursorHold,CursorHoldI * call WriteRegisterToFile()



function! Tapi_reg(bufnr, args) abort
  if empty(a:args)
    return
  endif
  " ==# 是 Vim 中用于字符串比较的操作符，==# 表示不区分大小写的比较
  if a:args[0] ==# 'set' && len(a:args) >= 3
    if !s:set_clipboard(a:args[1], a:args[2])
      let [reg, file] = a:args[1:2]
      " join 将列表中的元素连接成一个字符串
      let value = join(readfile(file), "\n")
      " write value to vim reg
      call setreg(reg, value)
    endif
  elseif a:args[0] ==# 'get' && len(a:args) >= 3
    if a:args[1] ==# '--list'
      let lines = split(execute('registers', 'silent'), '\n')
      let filename = a:args[2]
    else
      let lines = getreg(a:args[1], 1, 1)
      let filename = a:args[2]
    endif
    call writefile(lines, filename)
  endif
endfunction

" Use the system Clipboard (macOS or WSL )
function! s:set_clipboard(reg, file) abort
  if (a:reg ==# '+' || a:reg ==# '*') && !has('clipboard')
    let cmd = s:is_wsl() ? 'clip.exe' : has('macunix') ? 'pbcopy' : ''
    if !empty(cmd)
      let value = join(readfile(a:file), "\n")
      call system('clip.exe', value)
      return !v:shell_error
    endif
  endif
  return 0
endfunction

" 检查当前环境是否是 WSL 
" 当使用 function! 而不是 function 时，如果该函数已存在，Vim 会覆盖旧的定义并重新定义新函数，而不会报错
" abort 是用来确保函数在出现错误时立即终止执行的一个关键词
function! s:is_wsl() abort
  if exists('s:is_wsl')
    return s:is_wsl
  endif
  let s:is_wsl = (filereadable('/proc/sys/kernel/osrelease') && join(readfile('/proc/sys/kernel/osrelease'), "\n") =~? 'Microsoft')
  return s:is_wsl
endfunction

" 还原
let &cpo = s:save_cpo