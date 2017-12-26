" Vim plugin script
" File: chatwork.vim
" Summary: kick chatwork api from Vim
" Authors: rozeroze <rosettastone1886@gmail.com>
" License: MIT
" Version: 1.0.0

if exists('b:current_syntax')
   finish
endif

let s:cpo_save = &cpo
set cpo&vim

syntax clear

" chatwork.vim
syntax match chatworkAccount "-- .\{-} --"
highlight link chatworkAccount String
syntax match chatworkSendTime "\[send_time: .\{-}]"
highlight link chatworkSendTime Number

" chatwork util
syntax match chatworkInfoStart "\[info]" conceal cchar=!
syntax match chatworkInfoStop "\[/info]" conceal
highlight link chatworkInfoStart PreProc
highlight link chatworkInfoStop PreProc

syntax match chatworkTitleStart "\[title]" conceal cchar=%
syntax match chatworkTitleStop "\[/title]" conceal
highlight link chatworkTitleStart Title
highlight link chatworkTitleStop Title

syntax match chatworkSysTxt "\[dtext:.\{-}]" conceal cchar=?
highlight link chatworkSysTxt Identifier

syntax match chatworkUpload "\[dtext:file_uploaded]" conceal cchar=^
syntax match chatworkDownload "\[download:.\{-}].\{-}\[/download]"
syntax match chatworkPreview "\[preview.\{-}]" conceal
highlight link chatworkUpload Directory
highlight link chatworkDownload Directory
highlight link chatworkPreview NonText

syntax match chatworkLine "\[hr]"
highlight link chatworkLine SpecialKey

syntax region chatworkCode start="\[code]" end="\[/code]"
highlight link chatworkCode NonText

syntax match chatworkTaskAdd "\[dtext:task_added]" conceal cchar=$
syntax match chatworkTaskStart "\[task.\{-}]" conceal cchar=+
syntax match chatworkTaskStop "\[/task]" conceal cchar=/
"syntax region chatworkTask start="\[task.\{-}]"ms=e end="\[/task]"he=e-7 contains=chatworkTaskStart,chatworkTaskStop
highlight link chatworkTaskAdd Exception
highlight link chatworkTaskStart SpecialKey
highlight link chatworkTaskStop SpecialKey
"highlight link chatworkTask Underlined

syntax match chatworkCreate "\[dtext:chatroom_groupchat_created]"
highlight link chatworkCreate PreProc

syntax region chatworkMember start="\[dtext:chatroom_member_is]" end="\[dtext:chatroom_added]" contains=chatworkMemberPic
syntax match chatworkMemberPic "\[piconname:.\{-}]"
highlight link chatworkMember PreProc
highlight link chatworkMemberPic String

syntax match chatworkTo "\[To:.\{-}]" conceal cchar=T
syntax match chatworkToName "\[To:.\{-}]\zs.*$"
highlight link chatworkTo SpecialKey
highlight link chatworkToName String

syntax match chatworkRe "\[rp.\{-}]" conceal cchar=R
syntax match chatworkReName "\[rp.\{-}]\zs.*$"
highlight link chatworkRe SpecialKey
highlight link chatworkReName String

syntax match chatworkQtStart "\[qt]" conceal cchar="
syntax match chatworkQtStop "\[/qt]" conceal cchar=/
syntax match chatworkQtMeta "\[qtmeta.\{-}]" conceal cchar=|
"syntax region chatworkQtInner start="\[qtmeta.\{-}]"ms=e end="\[/qt]"he=e-5 contains=chatworkQtStart,chatworkQtStop
highlight link chatworkQtStart SpecialKey
highlight link chatworkQtStop SpecialKey
highlight link chatworkQtMeta SpecialKey
"highlight link chatworkQtInner Visual

syntax match chatworkDelete "\[deleted]"
highlight link chatworkDelete SpecialKey

let b:current_syntax = 'chatwork'

let &cpo = s:cpo_save
unlet s:cpo_save

" vim: set ts=3 sts=3 sw=3 et :
