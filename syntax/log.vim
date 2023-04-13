" Log Settings
" github.com/mike325/.vim

if exists('b:current_syntax')
  finish
endif

syn match LogURL        "[[:blank:]]\+\zs\(http\(s\)\?\|ftp\(s\)\?\):\/\/[^[:blank:]]\+\ze"
syn match LogSpecial    "\(.\|$\|@\|\\\)"
syn match LogIdentifier "\<\i+"

syn match LogNumber "\<\d\+"
syn match LogNumber "\<0\[xX]\[a-fA-F0-9]\+"

" TODO: This does not highlight correctly, need to check why
" format YYYY-MM-DD (HH:MM:(SS)?)?
syn match LogDate "\d\{4}\[/-]\d\{2}\[/-]\d\{2}\(\s\+\d\{2}:\d\{2}\(:\d\{2}\)\?\)\?"
" format DD-MM-YYYY (HH:MM:(SS)?)?
syn match LogDate "\d\{2}\[/-]\d\{2}\[/-]\d\{4}\(\s\+\d\{2}:\d\{2}\(:\d\{2}\)\?\)\?"

syn keyword LogError error err ERROR Error fail Fail FAIL FAILED failed
syn keyword LogWarn  warn warning WARN WARNING
syn keyword LogPass  pass PASS passed PASSED
syn keyword LogPass  start START started STARTED

syn keyword LogBool  true false TRUE FALSE True False

syn region LogString start=+"\|'+ end=+"\|'+

hi def link LogError DiagnosticError
hi def link LogWarn  DiagnosticWarn
hi def link LogPass  DiagnosticOk

hi def link LogBool   Boolean
hi link LogNumber Number

hi link LogURL  Special
hi link LogDate Special

hi link LogString String

let b:current_syntax = 'log'
