# frozen_string_literal: true

require 'csv'

csv = CSV.open(Rails.root.join('master/platforms.csv').to_s, headers: true)

csv.each do |r|
  Platform.seed do |s|
    s.id = r['id']
    s.name = r['name']
  end
end
