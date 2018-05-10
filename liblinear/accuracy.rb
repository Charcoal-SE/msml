require 'json'
require 'liblinear'

fh = open('posts.json', 'r')
reason_data, posts = JSON.load(fh)
fh.close

model = Liblinear::Model.load('net.dat')

threshold = ARGV.first.to_f
tps = 0.0
fps = 0.0

posts.values.each do |post|
    post, label = post

    if Liblinear.predict_probabilities(model, post)[0] > threshold
        if label
            tps += 1
        else
            fps += 1
        end
    end
end

puts "#{tps}/#{fps} = #{tps/(tps+fps) * 100}%"