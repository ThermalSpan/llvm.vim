# llvm.vim
I forked Superbill/llvm.vim, which uses files created by the llvm team. I dunno if Superbill is on that team. I wanted to change it a  bit so that llvm.vim only deals with llvm stuff. The old version had did things that I would prefer to deal with in my .vimrc like setting the tab width, and highlighting trailing whitespace. 

### How?
I suggest using a plugin manager with vim. I personally use NeoBundle, so all you need to do is add the following line to your .vimrci in the appropriate place:
```
NeoBundle 'ThermalSpan/llvm.vim'
```
This repository includes:
#### llvm.vim

Syntax highlighting mode for LLVM assembly files. To use, copy `llvm.vim' to ~/.vim/syntax and add this code to your ~/.vimrc :
```
augroup filetype
    au! BufRead,BufNewFile *.ll     set filetype=llvm
augroup END
```
##### tablegen.vim

Syntax highlighting mode for TableGen description files. To use, add this code to your ~/.vimrc :
```
augroup filetype
     au! BufRead,BufNewFile *.td     set filetype=tablegen
augroup END
```

### Additional info
Note: If you notice missing or incorrect syntax highlighting, please contact
<llvmbugs [at] cs.uiuc.edu>; if you wish to provide a patch to improve the
functionality, it will be most appreciated. Thank you.

If you find yourself working with LLVM Makefiles often, but you don't get syntax
highlighting (because the files have names such as Makefile.rules or
TEST.nightly.Makefile), add the following to your ~/.vimrc:
```
augroup filetype
    au! BufRead,BufNewFile *Makefile*     set filetype=make
augroup END
```
