" Vim syntax file
" Language:     Haskell with literate comments, Bird style,
"           TeX style and plain text surrounding
"           \begin{code} \end{code} blocks
" Maintainer:       Haskell Cafe mailinglist <haskell-cafe@haskell.org>
" Original Author:  Arthur van Leeuwen <arthurvl@cs.uu.nl>
" Last Change:      Jan 05, 2008 by Kalman Noel
" Version:      1.02
"
" Thanks to Ian Lynagh for thoughtful comments on initial versions and
" for the inspiration for writing this in the first place.
"
" This style guesses as to the type of markup used in a literate haskell
" file and will highlight (La)TeX markup if it finds any
" This behaviour can be overridden, both glabally and locally using
" the lhs_markup variable or b:lhs_markup variable respectively.
"
" lhs_markup        must be set to either  tex  or  none  to indicate that
"           you always want (La)TeX highlighting or no highlighting
"           must not be set to let the highlighting be guessed
" b:lhs_markup      must be set to eiterh  tex  or  none  to indicate that
"           you want (La)TeX highlighting or no highlighting for
"           this particular buffer
"           must not be set to let the highlighting be guessed
"
"
" 2004 February 18: New version, based on Ian Lynagh's TeX guessing
"           lhaskell.vim, cweb.vim, tex.vim, sh.vim and fortran.vim
" 2004 February 20: Cleaned up the guessing and overriding a bit
" 2004 February 23: Cleaned up syntax highlighting for \begin{code} and
"           \end{code}, added some clarification to the attributions
" 2008 January 05:  Fixed broken highlighting when some totally common TeX 
"                   environments or commands are used (document, section, ...)


" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

" First off, see if we can inherit a user preference for lhs_markup
if !exists("b:lhs_markup")
    if exists("lhs_markup")
    if lhs_markup =~ '\<\%(tex\|none\)\>'
        let b:lhs_markup = matchstr(lhs_markup,'\<\%(tex\|none\)\>')
    else
        echohl WarningMsg | echo "Unknown value of lhs_markup" | echohl None
        let b:lhs_markup = "unknown"
    endif
    else
    let b:lhs_markup = "unknown"
    endif
else
    if b:lhs_markup !~ '\<\%(tex\|none\)\>'
    let b:lhs_markup = "unknown"
    endif
endif

" Remember where the cursor is, and go to upperleft
let s:oldline=line(".")
let s:oldcolumn=col(".")
call cursor(1,1)

" If no user preference, scan buffer for our guess of the markup to
" highlight. We only differentiate between TeX and plain markup, where
" plain is not highlighted. The heuristic for finding TeX markup is if
" one of the following occurs anywhere in the file:
"   - \documentclass
"   - \begin{env}       (for env != code)
"   - \part, \chapter, \section, \subsection, \subsubsection, etc
if b:lhs_markup == "unknown"
    if search('%\|\\documentclass\|\\begin{\(code}\)\@!\|\\\(sub\)*section\|\\chapter|\\part','W') != 0
    let b:lhs_markup = "tex"
    else
    let b:lhs_markup = "plain"
    endif
endif

" If user wants us to highlight TeX syntax, read it.
if b:lhs_markup == "tex"
    if version < 600
    source <sfile>:p:h/tex.vim
    set isk+=_
    else
    runtime! syntax/tex.vim
    unlet b:current_syntax
    " Tex.vim removes "_" from 'iskeyword', but we need it for Haskell.
    setlocal isk+=_
    endif
endif

" Literate Haskell is Haskell in between text, so at least read Haskell
" highlighting
if version < 600
    syntax include @haskellTop <sfile>:p:h/haskell.vim
else
    syntax include @haskellTop syntax/haskell.vim
endif


" Where Haskell is nested within TeX
syntax cluster lhstex contains=tex.*Zone,texAbstract

syntax region lhsHaskellBirdTrack start="^>" end="\%(^[^>]\)\@=" contains=@haskellTop,lhsBirdTrack containedIn=@lhstex
syntax region lhsHaskellBeginEndBlock start="^\\begin{code}\s*$" matchgroup=NONE end="\%(^\\end{code}.*$\)\@=" contains=@haskellTop,@beginCode containedIn=@lhstex

syntax match lhsBirdTrack "^>" contained

syntax match beginCodeBegin "^\\begin" nextgroup=beginCodeCode contained
syntax region beginCodeCode  matchgroup=texDelimiter start="{" end="}"
syntax cluster beginCode    contains=beginCodeBegin,beginCodeCode

" Define the default highlighting.
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_tex_syntax_inits")
  if version < 508
    let did_tex_syntax_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  HiLink lhsBirdTrack Comment

  HiLink beginCodeBegin       texCmdName
  HiLink beginCodeCode        texSection

  delcommand HiLink
endif

" Restore cursor to original position, as it may have been disturbed
" by the searches in our guessing code
call cursor (s:oldline, s:oldcolumn)

unlet s:oldline
unlet s:oldcolumn

let b:current_syntax = "lhaskell"

" vim: ts=8
