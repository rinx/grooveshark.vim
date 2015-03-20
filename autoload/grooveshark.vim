

" Load vital modules
let s:V = vital#of('grooveshark')
let s:PM = s:V.import('ProcessManager')


" Player
function! grooveshark#play(key)
  if executable('mplayer')
    if s:PM.is_available()
      let songurl = grooveshark#get_song_url_by_id(a:key)
      let play_command = substitute(g:grooveshark#play_command, '%%URL%%', songurl, '')
      call grooveshark#stop()
      call s:PM.touch('grooveshark_play', play_command)
      echo 'Playing ' . '.'
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

if has("ruby")
    function! grooveshark#createsession(...)
        if g:grooveshark#session
            " Nothing to do
        else
            " create session
            ruby << EOF
            require 'grooveshark'

            $client = Grooveshark::Client.new
EOF

            let g:grooveshark#session = 1
        endif
    endfunction
    function! grooveshark#search_song(query)
        call grooveshark#createsession()
        let songs = []
        ruby << EOF
            query = VIM.evaluate('a:query').force_encoding(Encoding::UTF_8)
            songs = $client.search_songs(query)

            songs.each do |s|
                slist = "{'id': '#{s.id}', 'name': '#{s.name}', 'artist': '#{s.artist}', 'album': '#{s.album}'}"
                VIM.command("call add(songs, #{slist})")
            end
EOF
        return songs
    endfunction
    function! grooveshark#get_song_url_by_id(id)
        call grooveshark#createsession()
        ruby << EOF
            id = VIM.evaluate('a:id').to_s.force_encoding(Encoding::UTF_8)
            songurl = $client.get_song_url_by_id(id)

            VIM.command('let res = "' + songurl + '"')
EOF
        return res
    endfunction
endif


let g:grooveshark#session = 0
let g:grooveshark#play_command = get(g:, 'grooveshark#play_command', "mplayer -slave -really-quiet %%URL%%")

