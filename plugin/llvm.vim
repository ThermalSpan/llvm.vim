"
" llvm.vim
" forked by ThermalSpan from Superbill/llvm.vim
"

filetype on

" Optional
" C/C++ programming helpers
augroup csrc
  au!
  autocmd FileType *      set nocindent smartindent
  autocmd FileType c,cpp  set cindent
augroup END
" Set a few indentation parameters. See the VIM help for cinoptions-values for
" details.  These aren't absolute rules; they're just an approximation of
" common style in LLVM source.
set cinoptions=:0,g0,(0,Ws,l1

" LLVM Makefiles can have names such as Makefile.rules or TEST.nightly.Makefile,
" so it's important to categorize them as such.
augroup filetype
  au! BufRead,BufNewFile *Makefile* set filetype=make
augroup END

" Enable syntax highlighting for LLVM files. To use, copy
" utils/vim/llvm.vim to ~/.vim/syntax .
augroup filetype
  au! BufRead,BufNewFile *.ll     set filetype=llvm
augroup END

" Enable syntax highlighting for tablegen files. To use, copy
" utils/vim/tablegen.vim to ~/.vim/syntax .
augroup filetype
  au! BufRead,BufNewFile *.td     set filetype=tablegen
augroup END

" Clang code-completion support. This is somewhat experimental!

" A path to a clang executable.
let g:clang_path = "clang++"

" A list of options to add to the clang commandline, for example to add
" include paths, predefined macros, and language options.
let g:clang_opts = [
  \ "-x","c++",
  \ "-D__STDC_LIMIT_MACROS=1","-D__STDC_CONSTANT_MACROS=1",
  \ "-Iinclude" ]

function! ClangComplete(findstart, base)
   if a:findstart == 1
      " In findstart mode, look for the beginning of the current identifier.
      let l:line = getline('.')
      let l:start = col('.') - 1
      while l:start > 0 && l:line[l:start - 1] =~ '\i'
         let l:start -= 1
      endwhile
      return l:start
   endif

   " Get the current line and column numbers.
   let l:l = line('.')
   let l:c = col('.')

   " Build a clang commandline to do code completion on stdin.
   let l:the_command = shellescape(g:clang_path) .
                     \ " -cc1 -code-completion-at=-:" . l:l . ":" . l:c
   for l:opt in g:clang_opts
      let l:the_command .= " " . shellescape(l:opt)
   endfor

   " Copy the contents of the current buffer into a string for stdin.
   " TODO: The extra space at the end is for working around clang's
   " apparent inability to do code completion at the very end of the
   " input.
   " TODO: Is it better to feed clang the entire file instead of truncating
   " it at the current line?
   let l:process_input = join(getline(1, l:l), "\n") . " "

   " Run it!
   let l:input_lines = split(system(l:the_command, l:process_input), "\n")

   " Parse the output.
   for l:input_line in l:input_lines
      " Vim's substring operator is annoyingly inconsistent with python's.
      if l:input_line[:11] == 'COMPLETION: '
         let l:value = l:input_line[12:]

        " Chop off anything after " : ", if present, and move it to the menu.
        let l:menu = ""
        let l:spacecolonspace = stridx(l:value, " : ")
        if l:spacecolonspace != -1
           let l:menu = l:value[l:spacecolonspace+3:]
           let l:value = l:value[:l:spacecolonspace-1]
        endif

        " Chop off " (Hidden)", if present, and move it to the menu.
        let l:hidden = stridx(l:value, " (Hidden)")
        if l:hidden != -1
           let l:menu .= " (Hidden)"
           let l:value = l:value[:l:hidden-1]
        endif

        " Handle "Pattern". TODO: Make clang less weird.
        if l:value == "Pattern"
           let l:value = l:menu
           let l:pound = stridx(l:value, "#")
           " Truncate the at the first [#, <#, or {#.
           if l:pound != -1
              let l:value = l:value[:l:pound-2]
           endif
        endif

         " Filter out results which don't match the base string.
         if a:base != ""
            if l:value[:strlen(a:base)-1] != a:base
               continue
            end
         endif

        " TODO: Don't dump the raw input into info, though it's nice for now.
        " TODO: The kind string?
        let l:item = {
          \ "word": l:value,
          \ "menu": l:menu,
          \ "info": l:input_line,
          \ "dup": 1 }

        " Report a result.
        if complete_add(l:item) == 0
           return []
        endif
        if complete_check()
           return []
        endif

      elseif l:input_line[:9] == "OVERLOAD: "
         " An overload candidate. Use a crazy hack to get vim to
         " display the results. TODO: Make this better.
         let l:value = l:input_line[10:]
         let l:item = {
           \ "word": " ",
           \ "menu": l:value,
           \ "info": l:input_line,
           \ "dup": 1}

        " Report a result.
        if complete_add(l:item) == 0
           return []
        endif
        if complete_check()
           return []
        endif

      endif
   endfor


   return []
endfunction ClangComplete

set omnifunc=ClangComplete
