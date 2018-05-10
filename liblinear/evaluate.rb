require 'json'
require 'liblinear'
require 'net/http'

KEY = '062faaae07c2d864f25c4177ae2a73118cc9bf7e6aa7bd4ec2a1df2c7f6d16a0'
HOST = 'https://metasmoke.erwaysoftware.com'
FILTER = 'GHFNOHKNGOLGJLHOGMJMFLGML'

fh = open('posts.json', 'r')
reason_data, _ = JSON.load(fh)
fh.close

model = Liblinear::Model.load('net.dat')

id = ARGV.first
reasons = JSON.parse(Net::HTTP.get(URI.parse("#{HOST}/api/v2.0/posts/#{id}/reasons?key=#{KEY}&filter=#{FILTER}")))

input = [0] * reason_data.size

reasons['items'].each do |reason|
    reason_id = reason_data[reason['id'].to_s]

    if reason_id
        input[reason_id] = 1
    end
end

p Liblinear.predict_probabilities(model, input)