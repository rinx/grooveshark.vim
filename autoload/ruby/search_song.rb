require 'grooveshark'

client = Grooveshark::Client.new

query = $*.join(" ").to_s

begin
  songs = client.search_songs(query)
end

songs.each do |s|
  slist = "{'id': '#{s.id}', 'name': '#{s.name.gsub("'", "''")}', 'artist': '#{s.artist.gsub("'", "''")}', 'album': '#{s.album.gsub("'", "''")}'}"
  puts slist
end

