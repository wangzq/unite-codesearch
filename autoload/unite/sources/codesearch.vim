let s:save_cpo = &cpo
set cpo&vim

call unite#util#set_default('g:unite_source_codesearch_command', 'csearch')
call unite#util#set_default('g:unite_source_codesearch_max_candidates', 30)
call unite#util#set_default('g:unite_source_codesearch_ignore_case', 0)

let s:unite_source = {
      \ 'name': 'codesearch',
      \ "description": 'codesearch search results',
      \ 'max_candidates': g:unite_source_codesearch_max_candidates,
      \ 'hooks': {},
      \ 'required_pattern_length': 1,
      \ 'matchers' : 'matcher_codesearch',
      \ 'is_volatile': 1,
      \ }

let s:codesearch_command = g:unite_source_codesearch_command
if g:unite_source_codesearch_ignore_case
  let s:codesearch_command .= ' -i '
endif
let s:codesearch_command .= ' -n -m %d "%s"'
echomsg s:codesearch_command

if has('win16') || has('win32') || has('win64') || has('win95') || has('gui_win32') || has('gui_win32s')
  let s:filter_expr = 'v:val =~ "^[a-z]:[^:]\\+:[^:]\\+:.\\+$"'
  let s:map_expr = '[v:val, [join(split(v:val, ":")[:1], ":"), split(v:val, ":")[2]]]'
else
  let s:filter_expr = 'v:val =~ "^/[^:]\\+:[^:]\\+:.\\+$"'
  let s:map_expr = '[v:val, split(v:val, ":", 1)[0:1]]'
endif

function! s:unite_source.gather_candidates(args, context)
  return map(
        \  map(
        \    filter(
        \      split(
        \        unite#util#system(printf(
        \          s:codesearch_command,
        \          s:unite_source.max_candidates,
        \          a:context.input)),
        \        '[\n\r]'),
        \      s:filter_expr),
        \    s:map_expr),
        \  '{
        \  "word": v:val[0],
        \  "source": "codesearch",
        \  "kind": "jump_list",
        \  "action__path": v:val[1][0],
        \  "action__line": v:val[1][1],
        \  }'
        \)
endfunction

function! unite#sources#codesearch#define()
  return exists('s:codesearch_command') ? s:unite_source : []
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
