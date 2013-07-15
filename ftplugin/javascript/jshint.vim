" JSHint Vim plugin
" Version: 0.10.0
" Maintainers: 
" Based on:
" License: MIT

" Line continuation and avoiding side effects
let s:save_cpo = &cpo
set cpo&vim


" This plugin should only be loaded once
if exists("b:loaded_jshint_vim")
  finish
endif
let b:loaded_jshint_vim = 0.10.0


" Allow hotkey configurations
" if !hasmapto('<Plug>JSHintVim_Check')
" 	map <unique> <Leader>jsu  <Plug>JSHintVim_Check
" endif
" if !hasmapto('<Plug>JSHintVim_Clear')
" 	map <unique> <Leader>jsc  <Plug>JSHintVim_Clear
" endif
" if !hasmapto('<Plug>JSHintVim_Toggle')
" 	map <unique> <Leader>jst  <Plug>JSHintVim_Toggle
" endif
" if !hasmapto('<Plug>JSHintVim_QuickFix')
" 	map <unique> <Leader>jsq  <Plug>JSHintVim_QuickFix
" endif
" if !hasmapto('<Plug>JSHintVim_ReloadConfig')
"   map <unique> <Leader>j  <Plug>JSHintVim_ReloadConfig
" endif


" Setup functions
"findJSHintRC
"reloadJSHintRC
"toggleJSHint

" Run functions
"JSHint
"JSHintClear
"JSHintQuickFix
"JSHintQuickFixClear

" find_options will try to locate a .jshintrc file. It will search the current
" directory first. If not found, it will move up the directory tree all the way
" to the computer root directory. If it doesn't find one, it will look in the
" user's home directory (~). If it still can't find one, it will use JSHint's
" default options
fun! s:find_options(path)
  let l:jshintrc_file = expand(a:path) . '.jshintrc'
  " if filereadable(l:jshintrc_file)
  "   let s:JSHintVim_RC_File = l:jshintrc_file
  " elseif len(a:path) > 1
  "   call s:find_options(fnamemodify(expand(a:path), ":h"))
  " else 
  "   let l:jshintrc_file = expand('~') . '.jshintrc'
  "   if filereadable(l:jshintrc_file)
  "     let s:JSHintVim_RC_File = l:jshintrc_file
  "   else
  "     let s:JSHintVim_RC_File = 'null'
  "   end
  " endif	
  redraw
  echo l:jshintrc_file
  echo
endfun
call s:find_options(expand("%:p:h"))


" Line continuation and avoiding side effects (cont'd)
let &cpo = s:save_cpo
unlet s:save_cpo
