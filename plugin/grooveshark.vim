" grooveshark.vim
" Version: 0.0.1
" Author: Rintaro Okamura
" License: 

if exists('g:loaded_grooveshark')
  finish
endif
let g:loaded_grooveshark= 1

let s:save_cpo = &cpo
set cpo&vim

if has("ruby")

    command! -nargs=1 GroovesharkPlay call grooveshark#play(<f-args>, '')
    command! GroovesharkStop call grooveshark#stop()

    augroup Grooveshark
        autocmd!
        autocmd Grooveshark VimLeave * call grooveshark#stop()
    augroup END

endif

let &cpo = s:save_cpo
unlet s:save_cpo

