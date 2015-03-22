grooveshark.vim
===
You can enjoy grooveshark music with Vim.


Dependencies
---

* Vim
* Ruby
* grooveshark gem (https://github.com/sosedoff/grooveshark)
* Unite.vim (https://github.com/Shougo/unite.vim)
* mplayer

`$GEM_HOME` should be set correct path.

Usage
---

* `:GroovesharkPlay <song_id>` : Play the song.
* `:GroovesharkStop` : Stop the song.
* `:Unite grooveshark` : Search songs with Unite interface.


Config
---

You can choose which `ruby` command will be used in this plugin by adding like below in `~/.vimrc`.

    let g:grooveshark#ruby_cmd_path = expand('$HOME/.rbenv/shims/ruby')


License
---
MIT License


References
---

* https://github.com/supermomonga/jazzradio.vim
* https://github.com/vim-jp/vital.vim
* https://github.com/sosedoff/grooveshark

