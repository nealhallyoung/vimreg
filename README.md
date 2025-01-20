# vimreg

# Install

## Server

- Install [`jq`](https://stedolan.github.io/jq/) command
- git clone repo
    ```
    git clone https://github.com/nealhallyoung/vimreg.git
    ```
- Add `vimreg.sh` and `.clip` in your `.bashrc`
    ```
    # absolute path
    source /path/to/vimreg.sh
    export CLIP=/path/to/.clip
    ```
- Create `~/.clip`
    ```
    touch ~/.clip
    ```
- Setup vim config `~/vimrc`
    ```
    set encoding=utf-8         
    set fileencodings=utf-8    
    set fileencoding=utf-8     
    ```
- Add `tapi_reg.vim` and `vimreg.sh`
    ```
    cp plugin/tapi_reg.vim  ~/.vim/plugin
    # You can specify the path
    cp macros/vimreg.sh ~/.scripts
    ```
- Setup ssh config `/etc/ssh/sshd_config`
    ```
    # enable ssh ENV feature
    ermitUserEnvironment yes
    ```
- Create `~/.ssh/environment`
    ```
    vimreg=/home/hall/.clip
    ```

## Client

It is recommended to use a public key for SSH login. 
This saves you from having to type many commands.

- reference [how-to-use-ssh-with-a-given-public-key](https://superuser.com/questions/543405/how-to-use-ssh-with-a-given-public-key)
- Setup ssh config `~/.ssh/config`

    ```
    # Let's say your server ip is 192.168.3.145, username is hall
    Host dev
        HostName 192.168.3.145
        User hall
        Port 22
        IdentityFile /Users/hall/.ssh/remote
    ```
- Then you can login server 
    ```
    ssh dev
    ```
# Usage 

## Server
### `vimreg`
`vimreg` cmd only used on vim terminal mode.

```
# Enter vim terminal mode
:terminal
```

Setup register.
```
# unnamed register
$ echo 'send this text to vim register!' | vimreg

# Specify register name
$ echo 'send this text to register a!' | vimreg a
```

Get register. `vimreg` supports `--get` or `-g` option.

```
$ vimreg -g
Hello this is vim unnamed register content.
$ vimreg -get a
this is "a" register content.
```


List all vim register contents.

```
$ vimreg -l
--- Registers ---
""   --- Registers ---^J""   ^J^J"0       if a:args[1] ==# '--list'^J^J"1   ^J^J"2       if a:args[1] =~# '\v^(-l|--list)$'^J^J"3     local reg='"'^J^J"4     set +x^J^J"5     set -x^J^J"6     set -x^J^J"7  
"0   --- Registers ---^J""   ^J^J"0       if a:args[1] ==# '--list'^J^J"1   ^J^J"2       if a:args[1] =~# '\v^(-l|--list)$'^J^J"3     local reg='"'^J^J"4     set +x^J^J"5     set -x^J^J"6     set -x^J^J"7  
"1   ^J
"2       if a:args[1] =~# '\v^(-l|--list)$'^J
"3     local reg='"'^J
"4     set +x^J
"5     set -x^J
"6     set -x^J
"7       content=^J
"8       printf '\e]51;["call","Tapi_reg",["set",%s,%s]]\x07' \^J        "$(to_json_string "$reg")" "$(to_json_string "$content")"^J
"9   $(to_json_string "$3")
"a   degure
"s   "
"-   $list || 
".   --list
":   call system('clip.exe', execute('registers'))
"%   macros/vimreg.sh
"#   plugin/tapi_reg.vim
"/   --list
```

Use `vimreg` as the `tee` command.

```
#  `--tee` (`-t`) 
$ ping google.com | vimreg -t
```

Note that `vimreg` sends request(s) to vim **after standard input is fully
received (it doesn't append input to vim register incrementally).**
That means, if Ctrl-C was pressed before standard input was closed, vimreg
doesn't sets vim register.

```
$ while :; do echo 'something heavy task ...'; sleep 1; done | vimreg -t
something heavy task ...
something heavy task ...
something heavy task ...
^C
$ # vim register is not updated here!
```



### `clip`

```
# Set clip
echo "Hello" > clip
# Get clip 
clip
Hello 
```

# Client

```
# Get clip
ssh dev 'cat > $vimreg' < text.txt
# Set clip
ssh dev 
ssh cn_gd_tencent 'cat $vimreg'
Hello
```

You can wrapper these cmd to simplfy work.

# WSL and macOS (experimental)

In Windows Subsystem Linux environment, even if `has('clipboard') == 0`, you can use clipboard registers (`+` or `*`)

```
$ vimreg +
Send
this
text
to
clipboard
^D
$
```

NOTE: if your vim returns `1` for `:echo has('clipboard')`, `vimreg` can also manipulate clipboard registers as usual.

# FQA

[vscode-remote-ssh-extension-tmux-bash-vsc-prompt-cmd-original-command-n](https://stackoverflow.com/questions/73421978/vscode-remote-ssh-extension-tmux-bash-vsc-prompt-cmd-original-command-n)