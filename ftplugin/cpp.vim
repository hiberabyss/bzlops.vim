if has_key(g:bzlops_callbacks, "cpp")
  finish
endif
let g:bzlops_callbacks.cpp = {}

function! g:bzlops_callbacks.cpp.new_after() abort
  call bzlops#cur_dozer('set stamp 1')

  call bzlops#add_deps()
endfunction

function! g:bzlops_callbacks.cpp.add_deps() abort
  silent g/^#include/call bzlops#add_dep()
endfunction

function! g:bzlops_callbacks.cpp.get_dep() abort
  let line = getline('.')
  if match(line, '#include') >= 0
    let path = matchstr(line, '"\zs.*\ze"')
    return bzlops#get_rule(path)
  endif

  return ""
endfunction
  
function! g:bzlops_callbacks.cpp.get_kind() abort
  let main_pattern = '\<main\>'

  if search(main_pattern, 'n') > 0
    return "cc_binary"
  endif

  return "cc_library"
endfunction
