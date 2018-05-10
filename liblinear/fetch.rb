require 'json'
require 'net/http'

KEY = '062faaae07c2d864f25c4177ae2a73118cc9bf7e6aa7bd4ec2a1df2c7f6d16a0'
HOST = 'https://metasmoke.erwaysoftware.com'
POST_FILTER = 'GFGJGIKOKJJIIFMJKNNJKFMONNFIIKIL'
REASON_FILTER = 'GJIKKOOJGFMOHIMHGJJOLIKNJ'

# Fetch current reasons
has_more = true
page = 1
reasons = {}

while has_more
  reason_page = JSON.parse(Net::HTTP.get(URI.parse("#{HOST}/api/v2.0/reasons?key=#{KEY}&filter=#{REASON_FILTER}&page=#{page}&per_page=100")))

  reason_page['items'].each do |reason|
    if !reason['inactive'] && reason['weight'] > 1 && reason['id'] != 16 && reason['id'] != 1
      reasons[reason['id']] = reasons.size
    end
  end

  has_more = reason_page['has_more']
  page += 1
end

# Begin fetching posts
posts = {}

reasons.each do |id, index|
  has_more = true
  page = 1

  while has_more
    begin
      puts "Reason #{id}, Page #{page}, Posts #{posts.size}"

      next_page = JSON.parse(Net::HTTP.get(URI.parse("#{HOST}/api/v2.0/reasons/#{id}/posts?key=#{KEY}&filter=#{POST_FILTER}&page=#{page}&per_page=100")))

      next_page['items'].each do |post|
        post_id = post['id']

        if !posts[post_id]
          posts[post_id] = [[0] * reasons.size, post['is_tp']]
        end

        posts[post_id][0][index] = 1
      end
    rescue
      has_more = true
    else
      has_more = next_page['has_more']
      page += 1
    ensure
      sleep(1)
    end
  end
end

fh = open('posts.json', 'w')
JSON.dump([reasons, posts], fh)
fh.close


