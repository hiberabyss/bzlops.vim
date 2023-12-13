" if g:bzlops_custom->has_key("proto")
"   finish
" endif

let g:bzlops_custom.proto = {}
let s:bzlops_cur = g:bzlops_custom.proto

let s:bzlops_cur.dep_extract_pattern = '[''"]\zs.*\ze[''"]'

function! s:bzlops_cur.get_kind() abort
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

function! s:bzlops_cur.new_after() abort
  call s:new_cc_proto()
endfunction

function! s:bzlops_cur.custom_rule(args) abort
  let path = a:args[0]

  if path =~ '^google\/protobuf'
    let base = fnamemodify(path, ":t:r")
    return printf("@com_google_protobuf//:%s_proto", base)
  endif

  return ''
endfunction
