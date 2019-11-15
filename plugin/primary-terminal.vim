" primary-terminal.vim - Simple terminal management
" Maintainer: Chris DeLuca <https://www.chrisdeluca.me/>
" Version: 0.0.0

if exists('g:loaded_primaryterminal') || &cp || v:version < 700 || !has('nvim') " {{{
  finish
endif
let g:loaded_primaryterminal = 1 " }}}

function! s:Setup() " {{{
  if !exists('g:primary_terminal_job_id')
    let g:primary_terminal_job_id = b:terminal_job_id
    let g:primary_terminal_buffer_file = expand('%:p')
    let g:primary_terminal_buffer_id = bufnr('%')
  endif
endfunction " }}}

function! s:Teardown() " {{{
  if bufnr('%') == g:primary_terminal_buffer_id
    unlet! g:primary_terminal_job_id g:primary_terminal_buffer_id g:primary_terminal_buffer_file
  endif
endfunction " }}}

function! s:PrimaryTerminalCommand(bang, command) " {{{
  if a:bang
    :execute 'pedit ' . g:primary_terminal_buffer_file
  endif
  call jobsend(g:primary_terminal_job_id, a:command . "\<CR>")
endfunction " }}}

function! s:Open() " {{{
  if exists('g:primary_terminal_buffer_id')
    :execute 'buffer' . g:primary_terminal_buffer_id
  else
    :terminal
  endif
endfunction " }}}

augroup terminal " {{{
  autocmd!
  " Setup primary terminal.
  autocmd TermOpen * call s:Setup()
  " Remove primary terminal if it's closed.
  autocmd TermClose * call s:Teardown()
augroup END " }}}

" Mappings {{{

if !exists(":T")
  command -nargs=1 -bang T call s:PrimaryTerminalCommand(<bang>0, <q-args>)
endif

nnoremap <Plug>PrimaryTerminalOpen :call <SID>Open()<CR>
" nnoremap <SID>PrimaryTerminalOpen :call <SID>PrimaryTerminalOpen()<CR>

" }}}

" vim: fdm=marker: sw=2