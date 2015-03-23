" Load vital modules
let s:V = vital#of('grooveshark')
let s:PM = s:V.import('ProcessManager')
let s:SF = s:V.import('System.Filepath')

" config
let g:grooveshark#ruby_cmd_path = get(g:, 'grooveshark#ruby_cmd_path', 'ruby')
let g:grooveshark#process_wait_sec = get(g:, 'grooveshark#process_wait_sec', '5.0')
let g:grooveshark#play_command = get(g:, 'grooveshark#play_command', "mplayer -slave -really-quiet %%URL%%")

" helper scripts
let s:ruby_path_search_songs = printf(
            \ '%s%s%s%ssearch_song.rb',
            \ expand('<sfile>:p:h'),
            \ s:SF.separator(),
            \ 'ruby',
            \ s:SF.separator()
            \)
let s:ruby_path_get_song_url_by_id = printf(
            \ '%s%s%s%sget_song_url_by_id.rb',
            \ expand('<sfile>:p:h'),
            \ s:SF.separator(),
            \ 'ruby',
            \ s:SF.separator()
            \)

" Player
function! grooveshark#play(key, detail)
  if executable('mplayer')
    if s:PM.is_available()
      let songurl = grooveshark#get_song_url_by_id(a:key)
      if a:detail == ''
        let songdetail = 'Grooveshark music'
      else
        let songdetail = a:detail
      endif
      let play_command = substitute(g:grooveshark#play_command, '%%URL%%', songurl, '')
      call grooveshark#stop()
      call s:PM.touch('grooveshark_play', play_command)
      echo 'Playing ' . songdetail . '.'
    else
      echo 'Error: vimproc is unavailable.'
    endif
  else
    echo 'Error: Please install mplayer to listen streaming music.'
  endif
endfunction

function! grooveshark#is_playing(...)
  " Process status
  let status = 'dead'
  try
    let status = s:PM.status('grooveshark_play')
  catch
  endtry

  if status == 'inactive' || status == 'active'
    return 1
  else
    return 0
  endif
endfunction

function! grooveshark#stop()
  if grooveshark#is_playing()
    return s:PM.kill('grooveshark_play')
  endif
endfunction

" format functions for unite
function! grooveshark#get_str_disp_len(str)
    let stdlen = len(a:str)
    let mltlen = len(substitute(a:str, '.', 'x', 'g'))
    if stdlen != mltlen
        return stdlen - ((stdlen - mltlen) / 2)
    else
        return stdlen
    endif
endfunction

function!grooveshark#name_formatter(name, max_name_len)
    let stdlen = len(a:name)
    let mltlen = len(substitute(a:name, '.', 'x', 'g'))
    if stdlen != mltlen
        let ret_len = ((stdlen - mltlen) / 2) + a:max_name_len
    else
        let ret_len = a:max_name_len
    endif
    return '%-' . ret_len . 's - %s (%s)'
endfunction

" Using Ruby functions
function! grooveshark#search_song(query)
    if s:PM.is_available()
        if executable(g:grooveshark#ruby_cmd_path)
            let cmd = [g:grooveshark#ruby_cmd_path, s:ruby_path_search_songs, a:query]
            let t = s:PM.touch('grooveshark_search_songs', cmd)
            if t !=# 'new'
                call s:PM.kill('grooveshark_search_songs')
                call s:PM.touch('grooveshark_search_songs', cmd)
            endif
            let [out, err, type] = s:PM.read_wait('grooveshark_search_songs', g:grooveshark#process_wait_sec, ['$'])
            if type ==# 'inactive'
                call s:PM.term('grooveshark_search_songs')
                throw 'ruby had died...!'
            endif
            let songs = map(split(out, "\r\\?\n"), 'eval(v:val)')
            return songs
        else
            echo 'Error: ruby does not exist in ''' . g:grooveshark#ruby_cmd_path . '''.'
        endif
    else
        echo 'Error: vimproc is unavailable.'
    endif
endfunction

function! grooveshark#get_song_url_by_id(id)
    if s:PM.is_available()
        if executable(g:grooveshark#ruby_cmd_path)
            let cmd = [g:grooveshark#ruby_cmd_path, s:ruby_path_get_song_url_by_id, a:id]
            call s:PM.touch('grooveshark_get_song_url', cmd)
            let [out, err, type] = s:PM.read_wait('grooveshark_get_song_url', g:grooveshark#process_wait_sec, ['$'])
            if type ==# 'inactive'
                call s:PM.term('grooveshark_get_song_url')
                throw 'ruby had died...!'
            endif
            call s:PM.term('grooveshark_get_song_url')
            return out
        else
            echo 'Error: ruby does not exist in ''' . g:grooveshark#ruby_cmd_path . '''.'
        endif
    else
        echo 'Error: vimproc is unavailable.'
    endif
endfunction

