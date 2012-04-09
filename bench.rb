require "rubygems"
require "bundler/setup"

require "benchmark"
require "eventmachine"
require "em-http"
require "net/http"
require "uri"

times = 200
Benchmark.bm do |x|
  x.report("#{times} requisições tipo GET de forma assincrona") do
    times.times do
      EventMachine.run {
        http = EventMachine::HttpRequest.new('http://google.com/?q=redu').get
        http.errback { EM.stop }
        http.callback { EM.stop }
      }
    end
  end
  x.report("#{times} requisições tipo GET de forma assincrona reaproveitando o bloco EM") do
    EventMachine.run {
      times.times do
        http = EventMachine::HttpRequest.new('http://google.com/?q=redu').get
      end
      EM.stop
    }
  end
  x.report("#{times} requisições tipo GET usando o net/http") do
    times.times do
      uri = URI.parse("http://google.com/?q=redu")
      Net::HTTP.get_response(uri)
    end
  end
end
