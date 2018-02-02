" Vim plugin script
" File: chatwork.vim
" Summary: kick chatwork api from Vim
" Authors: rozeroze <rosettastone1886@gmail.com>
" License: MIT
" Last Change: 2018 Feb 2


" MEMO: http://developer.chatwork.com/ja/endpoints.html


""" setting
" util {{{
let s:url = 'https://api.chatwork.com/v2/'
let s:showtype = 'tabnew'
if exists('g:chatwork_type')
   let s:showtype = g:chatwork_type
endif
let s:strftime = exists('*strftime')
let s:rooms = []
" }}}
" secret {{{
let s:token = '00112233445566778899aabbccddeeff'
let s:roomids = {}
let s:roomids.myroom = '12345678'
let s:roomids.thomas = '11111111'
let s:roomids.michaela = '22222222'
let s:roomids.john = '33333333'
try
   " NOTE: secret.vimを別に作成 token等の情報を定義している
   let s:token = secret#get_chatwork_token()
   let s:roomids = secret#get_chatwork_roomids()
catch
   echo 'chatwork.vim disabled'
   finish
endtry
" }}}


""" functions
" common
" chatwork#check(name) 指定の宛先が存在するか判定 {{{
function! chatwork#check(name)
   let name = tolower(a:name)
   if !has_key(s:roomids, name)
      return v:false
   endif
   return v:true
endfunction
" }}}
" chatwork#getid(name) 宛先からroomidを取得 {{{
function! chatwork#getid(name)
   let name = tolower(a:name)
   return s:roomids[name]
endfunction
" }}}
" chatwork#open(name) フィールドを開く {{{
function! chatwork#open(name)
   call execute(s:showtype)
   let &l:statusline = a:name . ' - chatwork'
   setlocal filetype=chatwork
endfunction
" }}}
" chatwork#complete(ArgLead, CmdLine, CursorPos) 宛先のcommand-complete {{{
function! chatwork#complete(ArgLead, CmdLine, CursorPos)
   let filter_cmd = printf('v:val =~ "^%s"', a:ArgLead)
   return filter(keys(s:roomids), filter_cmd)
endfunction
" }}}
" list
" chatwork#list() 宛先一覧を表示 {{{
function! chatwork#list()
   echo keys(s:roomids)
endfunction
" }}}
" get
" chatwork#get(name) メッセージを受信する {{{
function! chatwork#get(name)
   " check
   if !g:chatwork#check(a:name)
      echo 'the destination is wrong'
      return
   endif
   let roomid = g:chatwork#getid(a:name)
   " get
   let res = webapi#http#get(s:url . 'rooms/' . roomid . '/messages?force=1', {}, { 'x-ChatWorkToken': s:token })
   let json = webapi#json#decode(res.content)
   " show messages
   call chatwork#show(a:name, json)
endfunction
" }}}
" chatwork#show(name, json) メッセージを表示する {{{
function! chatwork#show(name, json)
   call g:chatwork#open(a:name)
   " check
   if type(a:json) != v:t_list
      echo 'error: An error has occureed!'
      call append(0, string(a:json))
      return
   endif
   " show
   for ite in a:json
      let line = ' -- ' . ite.account.name . ' --'
      if s:strftime
          " MEMO: strftime() の format はシステムに依存する
          let line .= ' [send_time: ' . strftime("%m/%d %H:%M", ite.send_time) . ']'
      endif
      call append(line('$'), line)
      for b in split(ite.body, '\n')
         call append(line('$'), b)
      endfor
      call append(line('$'), '') " line space
   endfor
endfunction
" }}}
" post
" chatwork#post(...) メッセージを送信する {{{
function! chatwork#post(...)
   " check
   if !g:chatwork#check(a:1)
      echo 'the destination is wrong'
      return
   endif
   let roomid = g:chatwork#getid(a:1)
   " post
   if a:0 == 1
      call g:chatwork#input(a:1, roomid)
   else
      let messages = join(a:000[1:], "\n")
      call g:chatwork#send(roomid, messages)
   endif
endfunction
" }}}
" chatwork#send(roomid, messages) メッセージを送信する {{{
function! chatwork#send(roomid, messages)
   " send
   let res = webapi#http#post(s:url . 'rooms/' . a:roomid . '/messages', { 'body': a:messages }, { 'x-ChatWorkToken': s:token })
   let dict = webapi#json#decode(res.content)
   if has_key(dict, 'error')
      echo 'error:' . dict.error
      return
   endif
   echo 'message posted'
endfunction
" }}}
" chatwork#input(name, roomid) メッセージのinputフィールドを開く {{{
function! chatwork#input(name, roomid)
    call g:chatwork#open(a:name)
    setlocal conceallevel=0
    " NOTE: bufnr毎にroomidを設定しないと複数ウィンドウに対応できないかも？
    let s:field_bufnr = bufnr('%')
    let s:destination = a:roomid
    noremap <buffer> <S-Return> :call g:chatwork#output()<CR>
endfunction
" }}}
" chatwork#output() inputフィールドからメッセージを送信、閉じる {{{
function! chatwork#output()
    let message = join(getline(1, '$'), "\n")
    call g:chatwork#send(s:destination, message)
    q
endfunction
" }}}
" unread <local管理ではない>
" chatwork#getrooms() room情報を取得 {{{
function! chatwork#getrooms()
   let s:rooms = []
   let res = webapi#http#get(s:url . 'rooms', {}, { 'x-ChatWorkToken': s:token })
   let json = webapi#json#decode(res.content)
   let s:rooms = json
endfunction
" }}}
" chatwork#allrooms() すべてのroomを表示 {{{
function! chatwork#allrooms()
   call g:chatwork#getrooms()
   call g:chatwork#open('all rooms')
   for room in s:rooms
      let sl = []
      call add(sl, 'id: ' . room.room_id)
      call add(sl, 'name: ' . room.name)
      call append(line('$'), sl)
      call append(line('$'), '-----------------')
   endfor
endfunction
" }}}
" chatwork#unreads() 未読メッセがあるroomを表示 {{{
function! chatwork#unreads()
   call g:chatwork#getrooms()
   call filter(s:rooms, 'v:val.unread_num != 0')
   if len(s:rooms) == 0
      echo 'all messages was already read'
      return
   endif
   call g:chatwork#open('unread rooms')
   for room in s:rooms
      let sl = []
      call add(sl, 'id: ' . room.room_id)
      call add(sl, 'name: ' . room.name)
      call add(sl, 'unread: ' . room.unread_num)
      call append(line('$'), sl)
      call append(line('$'), '-----------------')
   endfor
   nnoremap <buffer> <silent> o :call chatwork#getbyline()<CR>
   nnoremap <buffer> <silent> x :call chatwork#getbyword()<CR>
endfunction
" }}}
" chatwork#roomdetail() すべてのroomの詳細を表示 {{{
function! chatwork#roomdetail()
   call g:chatwork#getrooms()
   call g:chatwork#open('test rooms')
   for room in s:rooms
      let sl = items(room)
      for s in sl
         call append(line('$'), join(s, ': '))
      endfor
      call append(line('$'), '----------------')
   endfor
endfunction
" }}}
" chatwork#getbyid(id) idを指定してメッセを表示 {{{
function! chatwork#getbyid(id)
   call g:chatwork#getrooms()
   let r = {}
   for room in s:rooms
      if room.room_id == a:id
         let r = room
      endif
   endfor
   if string(r) == string({})
      echo 'not found'
   else
      let res = webapi#http#get(s:url . 'rooms/' . a:id . '/messages?force=1', {}, { 'x-ChatWorkToken': s:token })
      let json = webapi#json#decode(res.content)
      call chatwork#show('id-' . a:id , json)
   endif
endfunction
" }}}
" chatwork#getbyline() current行の数値をidとして扱い、getbyid()を呼ぶ {{{
function! chatwork#getbyline()
   let id = substitute(getline('.'), '[^0-9]', '', 'g')
   call g:chatwork#getbyid(id)
endfunction
" }}}
" chatwork#getbyword() cursor下のwordをidとして扱い、getbyid()を呼ぶ {{{
function! chatwork#getbyword()
   let id = substitute(expand('<cword>'), '[^0-9]', '', 'g')
   call g:chatwork#getbyid(id)
endfunction
" }}}


" vim: set ts=3 sts=3 sw=3 et tw=0 fdm=marker :
