require 'csv'

csv = CSV.open("#{Rails.root.join('master', 'platforms.csv')}", headers: true)

csv.each do |r|
  Platform.seed do |s|
    s.id = r['id']
    s.name = r['name']
  end
end