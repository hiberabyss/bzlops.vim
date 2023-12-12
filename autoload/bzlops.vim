function! bzlops#get_rule(path) abort
  let dir = fnamemodify(a:path, ':h')
  let base = fnamemodify(a:path, ':t:r')

  return printf("//%s:%s", dir, base)
endfunction

function! bzlops#cur_rule() abort
  return bzlops#get_rule(expand('%'))
endfunction

function! bzlops#cur_dozer(cmd) abort
  call system(printf("buildozer '%s' '%s'", a:cmd, bzlops#cur_rule()))
endfunction

function! bzlops#callback(name) abort
  if g:bzlops_callbacks->has_key(&filetype) && g:bzlops_callbacks[&ft]->has_key(a:name)
    return g:bzlops_callbacks[&ft][a:name]()
  endif

  return ''
endfunction

function! bzlops#add_deps() abort
  silent g/^#include/call bzlops#add_dep()
  nohlsearch
endfunction

function! bzlops#add_dep(dep = '') abort
  let dep = a:dep
  if empty(dep)
    let dep = bzlops#callback('get_dep')
  endif

  if empty(dep)
    echoerr "ERR: get empty dependency"
    return
  endif

  call bzlops#cur_dozer(printf('add deps %s', dep))
endfunction

function! bzlops#new(kind = '') abort
  let kind = a:kind
  if empty(kind)
    let kind = bzlops#callback('get_kind')
  endif

  let dir = expand('%:h')
  let base = expand('%:t:r')

  call system(printf('touch %s/BUILD', dir))

  call system(printf("buildozer 'new %s %s' '%s:__pkg__'", kind, base, dir))
  call bzlops#callback('new_after')
endfunction

" Will delete current file and related bazel rule
function! bzlops#delete() abort
  let rule = bzlops#cur_rule()
  call system(printf("buildozer 'delete' '%s'", rule))
  Delete!
endfunction
