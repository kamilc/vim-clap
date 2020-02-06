" Author: liuchengxu <xuliuchengxlc@gmail.com>
" Description: List the tags based on vista.vim.

let s:save_cpo = &cpoptions
set cpoptions&vim

let s:tags = {}

function! s:tags.source(...) abort
  let [bufnr, winnr, fname, fpath] = [
        \ g:clap.start.bufnr,
        \ g:clap.start.winid,
        \ bufname(g:clap.start.bufnr),
        \ expand('#'.g:clap.start.bufnr.':p')
        \ ]

  try
    call vista#source#Update(bufnr, winnr, fname, fpath)
  catch
    return [v:exception, 'Ensure you have installed https://github.com/liuchengxu/vista.vim']
  endtry

  let [data, _, _] = call('vista#finder#GetSymbols', a:000)

  if empty(data)
    return ['No symbols found via vista.vim']
  endif

  return vista#finder#PrepareSource(data)
endfunction

function! s:tags.on_move() abort
  try
    let [lnum, tag] = vista#finder#fzf#extract(g:clap.display.getcurline())
  catch
    return
  endtry
  let [start, end, hi_lnum] = clap#preview#get_line_range(lnum, 5)
  let lines = getbufline(g:clap.start.bufnr, start, end)
  call clap#preview#show_with_line_highlight(lines, s:origin_syntax, hi_lnum+1)
endfunction

function! s:tags.on_enter() abort
  let s:origin_syntax = getbufvar(g:clap.start.bufnr, '&syntax')
  call g:clap.display.setbufvar('&syntax', 'clap_tags')
endfunction

let s:tags.sink = function('vista#finder#fzf#sink')

let g:clap#provider#tags# = s:tags

let &cpoptions = s:save_cpo
unlet s:save_cpo
