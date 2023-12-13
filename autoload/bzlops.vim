function! bzlops#get_rule(path) abort
  if empty(a:path)
    return a:path
  endif

  let custom_rule = bzlops#callback('custom_rule', a:path)
  if !empty(custom_rule)
    return custom_rule
  endif

  let dir = fnamemodify(a:path, ':h')
  let base = fnamemodify(a:path, ':t:r')

  return printf("//%s:%s", dir, base)
endfunction

function! bzlops#cur_rule() abort
  return bzlops#get_rule(expand('%'))
endfunction

function! bzlops#dozer(cmd, rule) abort
  call system(printf("buildozer '%s' '%s'", a:cmd, a:rule))
endfunction

function! bzlops#cur_dozer(cmd) abort
  call system(printf("buildozer '%s' '%s'", a:cmd, bzlops#cur_rule()))
endfunction

function! bzlops#get(key, default = '') abort
  if !g:bzlops_custom->has_key(&filetype)
    return a:default
  endif

  let ft_dict = g:bzlops_custom[&ft]
  if ft_dict->has_key(a:key)
    return ft_dict[a:key]
  endif

  return a:default
endfunction

function! bzlops#callback(name, ...) abort
  if g:bzlops_custom->has_key(&filetype) &&
        \ g:bzlops_custom[&ft]->has_key(a:name)
    if a:0 > 0
      return g:bzlops_custom[&ft][a:name](a:000)
    endif

    return g:bzlops_custom[&ft][a:name]()
  endif

  return ''
endfunction

function! s:dep_line_pattern() abort
  return bzlops#get('dep_line_pattern', '^\s*import')
endfunction

function! s:dep_extract_pattern() abort
  return bzlops#get('dep_extract_pattern', '"\zs.*\ze"')
endfunction


function! bzlops#add_deps() abort
  silent exec printf("g/%s/call bzlops#add_dep()", s:dep_line_pattern())
  nohlsearch
endfunction

function! bzlops#extract_path() abort
  let line = getline('.')

  if match(line, s:dep_line_pattern()) >= 0
    let path = matchstr(line, s:dep_extract_pattern())
    return path
  endif

  return ""
endfunction

function! bzlops#add_dep(dep = '') abort
  let dep = a:dep
  if empty(dep)
    let dep = bzlops#get_rule(bzlops#extract_path())
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
  call bzlops#cur_dozer(printf('add srcs %s', expand('%:t')))
  call bzlops#add_deps()
  call bzlops#callback('new_after')
endfunction

" Will delete current file and related bazel rule
function! bzlops#delete() abort
  let rule = bzlops#cur_rule()
  call system(printf("buildozer 'delete' '%s'", rule))
  Delete!
endfunction
