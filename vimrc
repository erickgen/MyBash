"智能对齐方式 
set smartindent
"一个tab是4个字符 
set tabstop=4
"按一次tab前进4个字符 
set softtabstop=4
"用空格代替tab 
set expandtab
"设置自动缩进 
set ai!
"缩进的字符个数 
set cindent shiftwidth=4
"set autoindent shiftwidth=2 

function AddTitle()
call setline(1,"<?php")
call append(1,"/**")
call append(2," * Author: genghonghao - genghonghao@gmail.com")
call append(3," * Create time: " . strftime("%Y-%m-%d %H:%M"))
call append(4," * Last modified: " . strftime("%Y-%m-%d %H:%M"))
call append(5," * Filename: " . expand("%"))
call append(6," * Description: ")
call append(7," */")
endf

map fuck <esc>:call AddTitle()<cr><esc>:$<esc>o

map shit <esc>:/* Last modified: /s@:.*$@\=strftime(": %Y-%m-%d %H:%M")@<cr>
