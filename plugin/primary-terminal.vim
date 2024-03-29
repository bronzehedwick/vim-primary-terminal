" primary-terminal.vim - Simple terminal management
" Maintainer: Chris DeLuca <https://www.chrisdeluca.me/>

if exists('g:loaded_primaryterminal') || &cp || v:version < 800 || !has('nvim') " {{{
  finish
endif
let g:loaded_primaryterminal = 1 " }}}

" Set global variables to identify the primary terminal in other functions.
" These variables track the terminal's:
" - Neovim job id, for sending commands
" - Buffer id, for mappings to switch buffers
" - Buffer file path, for opening the preview window
function! s:Setup() " {{{
  if !exists('b:terminal_job_id') && !exists('g:primary_terminal_job_id')
    :split
    :terminal
  endif
  if !exists('g:primary_terminal_job_id')
    let g:primary_terminal_job_id = b:terminal_job_id
    let g:primary_terminal_buffer_file = expand('%:p')
    let g:primary_terminal_buffer_id = bufnr('%')
  endif
endfunction " }}}

" Unset all the global variables set in s:Setup().
" This cleans up the plugin artifacts if the primary terminal is closed,
" and allows the primary terminal to be re-created without conflict.
function! s:Teardown() " {{{
  if bufnr('%') == g:primary_terminal_buffer_id
    unlet! g:primary_terminal_job_id g:primary_terminal_buffer_id g:primary_terminal_buffer_file
  endif
endfunction " }}}

" Function to send arbitrary commands to the primary terminal.
" Opens the result in the preview window if ! is supplied.
function! s:PrimaryTerminalCommand(bang, command) " {{{
  call s:Setup()
  if a:bang
    :execute 'pedit ' . g:primary_terminal_buffer_file
  endif
  call jobsend(g:primary_terminal_job_id, a:command . "\<CR>")
endfunction " }}}

" Function to open the primary terminal, using the variables set in s:Setup().
" Takes an argument to change the window splitting behavior.
" Should be one of 'buffer', 'sbuffer', or 'vertical sbuffer'.
function! s:Open(window_type) " {{{
  if a:window_type ==# 'dynamic'
    if winwidth(0) < 120
      call s:Open('sbuffer')
    else
      call s:Open('vert sbuffer')
    endif
    return
  endif
  if exists('g:primary_terminal_buffer_id')
    :execute a:window_type . ' ' . g:primary_terminal_buffer_id
  else
    if a:window_type ==# 'sbuffer'
      :split
    elseif a:window_type ==# 'vert sbuffer'
      :vertical split
    endif
    :terminal
  endif
  setlocal filetype=primary-terminal
endfunction " }}}

" Autocommands registered when the terminal opens and closes,
" which calls the s:Setup and s:Teardown functions.
augroup primaryterminal " {{{
  autocmd!
  " Setup primary terminal.
  autocmd TermOpen * call s:Setup()
  " Remove primary terminal if it's closed.
  autocmd TermClose * call s:Teardown()
augroup END " }}}

" Mappings {{{
command! -nargs=1 -complete=file_in_path -bang T call s:PrimaryTerminalCommand(<bang>0, <q-args>)
command! Tkill call jobsend(g:primary_terminal_job_id, "\<c-c>")

command! PrimaryTerminalOpen call <SID>Open('buffer')
command! PrimaryTerminalOpenSplit call <SID>Open('sbuffer')
command! PrimaryTerminalOpenVsplit call <SID>Open('vert sbuffer')
command! PrimaryTerminalOpenDynamic call <SID>Open('dynamic')

nnoremap <Plug>(PrimaryTerminalOpen) :call <SID>Open('buffer')<CR>
nnoremap <Plug>(PrimaryTerminalOpenSplit) :call <SID>Open('sbuffer')<CR>
nnoremap <Plug>(PrimaryTerminalOpenVsplit) :call <SID>Open('vert sbuffer')<CR>
nnoremap <Plug>(PrimaryTerminalOpenDynamic) :call <SID>Open('dynamic')<CR>

" }}}

" vim: fdm=marker: sw=2
