require 'yaml'
require 'erubis'

def load_song( song )
  # Check for files that match song in csml
  fnames = Dir.entries("csml")
  matches = []
  fnames.each do |name|
    if name.include? song
      matches.push name
    end
  end
  # Get the content of matched files
  data = {}
  matches.each do |match|
    lang = match.split(/\./)
    # Get the text of the matched file
    data[lang[1]] = load_file(match)
  end
  data
end

def chorus?( line )
  if line[0,1] == "*"
    return true
  end
  false
end

def cleanup( line )
  nope = [ '#', '*' ]
  if nope.include?( line[0] )
    line[0] = ''
  end
  line
end

def load_file( file )
  # Initialize config
  data = {}
  stanza = nil
  data["stanzas"] = []
  # Get the text from the file
  text = File.read("csml/#{file}")
  text.each_line do |line|
    # Get rid of newlines
    line.delete!("\n")
    # Find the title
    if line[0,1] == "#"
      data["title"] = cleanup( line )
      next
    end
    # Check for empty lines
    if line == ""
      stanza = stanza == nil ? 0 : stanza+1
      data["stanzas"][stanza] = []
      next
    end
    # Add the line
    item = { "chorus" => chorus?(line), "line" => cleanup(line) }
    data["stanzas"][stanza].push(item)
  end
  data
end

def parse_template( data )
  erb = File.read("songs.html.erb")
  output = Erubis::Eruby.new(erb).result(:data=>data)
  File.open("../songs.html","w") { |f| f.write(output) }
end

config = YAML.load( File.read('config.yaml'))
data = {}
config['songs'].each do |song|
  data[song] = load_song( song )
end
parse_template( data )
