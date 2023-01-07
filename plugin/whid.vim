
" in plugin/whid.vim
if exists("g:loaded_whid") | finish | endif " prevent loading twice

let s:save_cpo = &cpo " save the current 'cpo' option 
set cpo&vim " reset them to Vim defaults

" command to run whid
command! Whid lua require'whid'.whid()

let &cpo = s:save_cpo " and restore the original 'cpo' option
unlet s:save_cpo

let g:loaded_whid = 1


