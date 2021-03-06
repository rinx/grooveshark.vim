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

function! s:source.change_candidates(args, context)
  let word = matchstr(a:context.input, '^\S\+')
  if word == ''
      return []
  endif

  let songs = grooveshark#search_song(word)
  let max_name_len = max(map(copy(songs), 'grooveshark#get_str_disp_len(v:val["name"])'))
  let a:context.source.unite__cached_candidates = []
  return map(songs, '{
        \   "word" : printf(grooveshark#name_formatter(v:val["name"], max_name_len), v:val["name"], v:val["artist"], v:val["album"]),
        \   "action__song_id" : v:val["id"],
        \ }')
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
