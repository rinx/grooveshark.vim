scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

function! unite#sources#grooveshark#define()
  return s:source
endfunction


let s:source = {
      \   'name' : 'grooveshark',
      \   'hooks' : {},
      \   'action_table' : {
      \     'play' : {
      \       'description' : 'Play this song',
      \     }
      \   },
      \   'default_action' : 'play',
      \   '__counter' : 0
      \ }

function! s:source.action_table.play.func(candidate)
  let songdetail = substitute(a:candidate.word, '\s\+', ' ', 'g')
  call grooveshark#play(a:candidate.action__song_id, songdetail)
endfunction

function! s:source.gather_candidates(args, context)
  let songs = grooveshark#search_song(a:args[0])
  let max_name_len = max(map(copy(songs), 'len(v:val["name"])'))
  let format = '%-' . max_name_len . 's - %s (%s)'
  let a:context.source.unite__cached_candidates = []
  return map(songs, '{
        \   "word" : printf(format, v:val["name"], v:val["artist"], v:val["album"]),
        \   "action__song_id" : v:val["id"],
        \ }')
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
