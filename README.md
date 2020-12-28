# vim-rotate-related-files

## Installation

For Vundle, put the following in your `.vimrc` and then run `:PluginInstall`.
Customize the binding to your liking.
```
Plugin 'yuhanfang/vim-rotate-related-files'

noremap \r :call fang#RotateRelatedFiles()<CR>
```

## Usage

Rotates between different related files. For example, if you install the plugin
with the above binding, then hitting `\r` while editing `foo.xyz` will edit
`foo_test.xyz`. Hitting `\r` while editing `foo_test.xyz` will edit `foo.xyz`.
Of course, this is only useful if your code follows an opinionated bazel-like
layout.

As a specific exception to this rule, C/C++ files are assumed to take the form
`name.h`, `name.cc`, and `name_test.cc`. 

C++ header and implementation file extensions can be customized as follows:
```
" Prefer name.h and name.cpp but also find name.H and name.cc, name.C if they
" exist.
let g:fang#c_header_extensions = ["h", "H"]
let g:fang#c_impl_extensions = ["cpp", "cc", "C"]
```

Tests are assumed to be `name_test.xyz` or `nameTest.xyz` by default. This can
be customized as follows:
```
" Prefer name_test.xyz but also find name-test.xyz if it exists.
let g:fang#test_suffixes = ["_test", "-test"]
```
