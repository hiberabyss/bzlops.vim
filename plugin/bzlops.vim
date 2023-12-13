let g:bzlops_custom = {}

" Will delete current file and corresponding rule
command! -nargs=0 BzlDelete call bzlops#delete()

command! -nargs=? BzlNew call bzlops#new(<q-args>)

command! -nargs=? BzlAddDep call bzlops#add_dep(<q-args>)

command! -nargs=? BzlRmDep call bzlops#rm_dep(<q-args>)

command! -nargs=0 BzlLoadDeps call bzlops#add_deps()
