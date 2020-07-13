require 'csv'

csv = CSV.open("#{Rails.root.join('master', 'games.csv')}", headers: true)

def find_platform_id(name)
    id = case name
    when /PS4/
        1
    when /Nswitch|NS/
        2
    else
        nil
    end
end

def cover_google_file(id, name)
  { io: URI.open("https://drive.google.com/thumbnail?id=#{id}"), filename: "#{name}.jpg" }
end

csv.each do |r|
  Game.seed do |s|
    s.id = r['id']
    s.name = r['name']
    s.price = r['price']
    s.platform_id = find_platform_id(r['platform_name'])
    s.cover = cover_google_file(r['cover_id'], r['name'])
  end
end