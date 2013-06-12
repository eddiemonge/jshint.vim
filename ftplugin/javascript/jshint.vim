" Event handlers.

" Clear the errors when leaving a buffer
au BufLeave <buffer> call <SID>JSHintClear()

" Call JSHint when entering a buffer, leaving insert mode or when saving
au BufEnter <buffer> call <SID>:JSHint()
au InsertLeave <buffer> call <SID>:JSHint()
au BufWritePost <buffer> call <SID>:JSHint()




" Function

" Clear the list of errors
function! s:JSHintClear()
  " Only run this if jshine is not disabled
  if exists("b:jshint_disabled") && b:jshint_disabled == 1
    return
  endif
    
  " Delete previous matches
  let s:matches = getmatches()
  for s:matchId in s:matches
    if s:matchId['group'] == 'JSHintError'
      call matchdelete(s:matchId['id'])
    endif
  endfor
  let b:matched = []
  let b:matchedlines = {}
  let b:cleared = 1
endfunction

" The bulk of the plugin work
function! s:JSHint()
  " Only run this if jshine is not disabled
  if exists("b:jshint_disabled") && b:jshint_disabled == 1
    return
  endif

  " Set the errors to highlight the same as SpellBad (:help highlight link for
  " more info)
  highlight link JSHintError SpellBad

  " Clear the previous errors
  if exists("b:cleared")
    if b:cleared == 0
      call s:JSHintClear()
    endif
    let b:cleared = 1
  endif

  " Some variables needed for later
  let b:matched = []
  let b:matchedlines = {}
  let b:qf_list = []
  let b:qf_window_count = -1

  " Detect range
  if a:firstline == a:lastline
    " Skip a possible shebang line, e.g. for node.js script.
    if getline(1)[0:1] == "#!"
      let b:firstline = 2
    else
      let b:firstline = 1
    endif
    let b:lastline = '$'
  else
    let b:firstline = a:firstline
    let b:lastline = a:lastline
  endif

  " Get the file contents and make sure there is some code to check
  let lines = join(getline(b:firstline, b:lastline), "\n")
  if len(lines) == 0
    return
  endif

  " Run JSHint on the code. Store the results
  let b:jshint_output = system(s:cmd . " " . s:jshintrc_file, lines . "\n")
  if v:shell_error
    echoerr 'could not invoke JSHint!'
    let b:jshint_disabled = 1
  end

  " Loop through the error code
  for error in split(b:jshint_output, "\n")
    " Match {line}:{char}:{message}
    let b:parts = matchlist(error, '\v(\d+):(\d+):(.*)')
    if !empty(b:parts)
      " Get line relative to selection
      let l:line = b:parts[1] + (b:firstline - 1) 
      let l:errorMessage = b:parts[3]

      " Store the error for an error under the cursor
      let s:matchDict = {}
      let s:matchDict['lineNum'] = l:line
      let s:matchDict['message'] = l:errorMessage
      let b:matchedlines[l:line] = s:matchDict
      let l:errorType = 'W'
      if g:JSHintHighlightErrorLine == 1
        let s:mID = matchadd('JSHintError', '\v%' . l:line . 'l\S.*(\S|$)')
      endif
      " Add line to match list
      call add(b:matched, s:matchDict)

      " Store the error for the quickfix window
      let l:qf_item = {}
      let l:qf_item.bufnr = bufnr('%')
      let l:qf_item.filename = expand('%')
      let l:qf_item.lnum = l:line
      let l:qf_item.text = l:errorMessage
      let l:qf_item.type = l:errorType

      " Add line to quickfix list
      call add(b:qf_list, l:qf_item)
    endif
  endfor

  if exists("s:jshint_qf")
    " if jshint quickfix window is already created, reuse it
    call s:ActivateJSHintQuickFixWindow()
    call setqflist(b:qf_list, 'r')
  else
    " one jshint quickfix window for all buffers
    call setqflist(b:qf_list, '')
    let s:jshint_qf = s:GetQuickFixStackCount()
  endif
  let b:cleared = 0
endfunction


