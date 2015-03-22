require 'grooveshark'

client = Grooveshark::Client.new

id = ARGV[0]

begin
  songurl = client.get_song_url_by_id(id)
end

puts songurl

