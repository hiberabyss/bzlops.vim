" if g:bzlops_callbacks->has_key("proto")
"   finish
" endif

let g:bzlops_callbacks.proto = {}

function! g:bzlops_callbacks.proto.get_kind() abort
  return "proto_library"
endfunction

function! s:new_cc_proto() abort
  let dir = expand('%:h')
  let base = expand('%:t:r')

  let name = base . "_cc_proto"
  
  call bzlops#dozer('new cc_proto_library ' .name, dir.':'.'__pkg__')

  let rule = printf("//%s:%s", dir, name)
  call bzlops#dozer('add deps :' . base, rule)
endfunction

function! g:bzlops_callbacks.proto.new_after() abort
  call bzlops#add_deps()

  call s:new_cc_proto()
endfunction

function! g:bzlops_callbacks.proto.add_deps() abort
  silent g/^import/call bzlops#add_dep()
endfunction

function! g:bzlops_callbacks.proto.get_dep() abort
  let line = getline('.')
  if match(line, 'import') >= 0
    let path = matchstr(line, '[''"]\zs.*\ze[''"]')
    return bzlops#get_rule(path)
  endif

  return ""
endfunction
