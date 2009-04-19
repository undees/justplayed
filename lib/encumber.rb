require 'enumerator'
require 'net/http'
require 'tagz'

module Net
  class HTTP
    def self.post_quick(url, body)
      url = URI.parse url
      req = Net::HTTP::Post.new url.path
      req.body = body

      http = Net::HTTP.new(url.host, url.port)

      res = http.start do |sess|
        sess.request req
      end

      res.body
    end
  end
end

module Encumber
  class GUI
    def initialize(host='localhost', port=50000)
      @host, @port = host, port

      command 'reset'
    end

    def command(name, *params)
      command = Tagz.tagz do
        plist_(:version => 1.0) do
          dict_ do
            key_ 'command'
            string_ name
            params.each_cons(2) do |k, v|
              key_ k
              string_ v
            end
          end
        end
      end

      Net::HTTP.post_quick \
        "http://#{@host}:#{@port}/", command
    end
  end
end
