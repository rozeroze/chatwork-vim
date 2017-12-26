" Vim plugin script
" File: chatwork.vim
" Summary: kick chatwork api from Vim
" Authors: rozeroze <rosettastone1886@gmail.com>
" License: MIT
" Version: 1.1.0


if exists('g:loaded_chatwork')
   finish
endif
let g:loaded_chatwork = 1

let s:save_cpo = &cpo
set cpo&vim

command! -nargs=1 -complete=customlist,chatwork#complete ChatworkGet :call chatwork#get(<f-args>)
command! -nargs=+ -complete=customlist,chatwork#complete ChatworkPost :call chatwork#post(<f-args>)
command! -nargs=0 ChatworkList :call chatwork#list()

" #2 unread
command! -nargs=0 ChatworkUnread :call chatwork#unreads()

let &cpo = s:save_cpo
unlet s:save_cpo


" vim: set ts=3 sts=3 sw=3 et :
