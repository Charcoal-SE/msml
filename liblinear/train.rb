require 'json'
require 'liblinear'

fh = open('posts.json', 'r')
reasons, posts = JSON.load(fh)
fh.close

# Set aside test data
#test_set = posts.values.take(posts.size / 5)

# Training data
train_data = []
train_labels = []

posts.values.each do |post|
  input, label = post

  train_data.push input
  train_labels.push label ? 1 : -1
end

model = Liblinear.train({ solver_type: Liblinear::L2R_LR }, train_labels, train_data)
model.save('net.dat')