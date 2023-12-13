if has_key(g:bzlops_callbacks, "cpp")
  finish
endif
let g:bzlops_callbacks.cpp = {}
let s:bzlops_cur = g:bzlops_callbacks.cpp

let s:bzlops_cur.dep_line_pattern = '^\s*#include'
let s:bzlops_cur.dep_extract_pattern = '"\zs.*\ze"'

function! s:is_binary() abort
  let main_pattern = '\<main\>'
  
  return search(main_pattern, 'n') > 0
endfunction

function! s:bzlops_cur.new_after() abort
  if s:is_binary()
    call bzlops#cur_dozer('set stamp 1')
  endif
endfunction

function! s:bzlops_cur.get_kind() abort
  if s:is_binary()
    return "cc_binary"
  endif

  return "cc_library"
endfunction

function! s:bzlops_cur.custom_rule(args) abort
  let path = a:args[0]

  " For protobuf header
  if path =~ '\.pb\.h$'
    let items = matchlist(path, '\v(.*)/(.*)(\.pb\.h$)')
    if len(items) >= 4
      return printf("//%s:%s_cc_proto", items[1], items[2])
    endif

    return ''
  endif

  return ''
endfunction
