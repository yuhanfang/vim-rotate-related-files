" Given filename like foo_test without the extension, strips the _test or Test
" suffix to get foo.
function! s:stripTestSuffixFromRoot()
  let l:root = expand('%:r')
  let l:base = expand('%:t')
  for suffix in g:fang#test_suffixes
    if l:root =~# suffix . '$'
      return l:root[:-(len(suffix) + 1)]
    endif
  endfor
  return l:root
endfunction

" For C and C++, the rotation uses potentially different suffixes. The first
" suffix in each array is the preferred suffix that will be opened when no
" matching files exist.
if !exists("g:fang#c_header_extensions")
  let g:fang#c_header_extensions = ["h", "H", "hpp", "hxx"]
endif

if !exists("g:fang#c_impl_extensions")
  let g:fang#c_impl_extensions = ["cc", "cpp", "cxx"]
endif

" For all languages, assume that foo.xyz is matched with foo${suffix}.xyz
" where the suffix is one of the following. If none of the potential files
" exists, then use the first element of the array as the preferred suffix.
if !exists("g:fang#test_suffixes")
  let g:fang#test_suffixes = ["_test", "Test"]
endif

" Returns true if the file is a C++ header file.  
function! s:isCppHeader() 
  let l:ext = expand('%:e')
  for extension in g:fang#c_header_extensions
    if l:ext ==# extension
      return 1
    endif
  endfor
  return 0
endfunction

" Edits the file if it exists, and returns true.
function! s:editIfExists(filename)
  if filereadable(a:filename)
    execute "edit " . a:filename
    return 1
  endif
  return 0
endfunction

" As a special case, C++ rotates across 3 categories, test -> header -> impl,
" where the header does not share the same extension as the others.
function! s:rotateRelatedCppFiles()
  let l:root_stripped = s:stripTestSuffixFromRoot()
  let l:is_test = expand('%:r') !=# l:root_stripped
  if l:is_test
    for ext in g:fang#c_header_extensions
      if s:editIfExists(l:root_stripped . "." . ext)
        return
      endif
    endfor
    execute "edit " . l:root_stripped . "." . g:fang#c_header_extensions[0]
  elseif s:isCppHeader()
    for ext in g:fang#c_impl_extensions
      if s:editIfExists(l:root_stripped . "." . ext)
        return
      endif
    endfor
    execute "edit " . l:root_stripped . "." . g:fang#c_impl_extensions[0]
  else
    for suffix in g:fang#test_suffixes
      for ext in g:fang#c_impl_extensions
        if s:editIfExists(l:root_stripped . suffix . "." . ext)
          return
        endif
      endfor
    endfor
    execute "edit " . l:root_stripped . g:fang#test_suffixes[0] . "." . g:fang#c_impl_extensions[0]
  endif
endfunction

" Edits the next in a chain of related files. Assume that C/C++ files have a
" header and implementation that match names except for the extension. Assume
" that all files generally have an implementation and a test with the same
" file extension, where the test has a suffix of _test or Test.
function! fang#RotateRelatedFiles()
  if &filetype ==# "c" || &filetype ==# "cpp"
    call s:rotateRelatedCppFiles()
  else
    let l:ext = expand('%:e')
    let l:root_stripped = s:stripTestSuffixFromRoot()
    let l:is_test = expand('%:r') !=# l:root_stripped
    " Rotate from test -> impl
    if l:is_test
      execute "edit " . l:root_stripped . "." . l:ext
    else
      for suffix in g:fang#test_suffixes
        if s:editIfExists(l:root_stripped . suffix . "." . l:ext)
          return
        endif
      endfor
      execute "edit " . l:root_stripped . g:fang#test_suffixes[0] . "." . l:ext
    endif
  endif
endfunction
