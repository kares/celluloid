require 'rubygems'
require 'bundler/setup'
require 'celluloid/io'
require 'celluloid/rspec'

class ExampleActor
  include Celluloid::IO

  def wrap
    yield
  end
end

EXAMPLE_PORT = 12345

def example_addr; '127.0.0.1'; end
def example_port; EXAMPLE_PORT; end
def example_ssl_port; EXAMPLE_PORT + 1; end

def fixture_dir; Pathname.new File.expand_path("../fixtures", __FILE__); end

def within_io_actor(&block)
  actor = ExampleActor.new
  actor.wrap(&block)
ensure
  actor.terminate if actor.alive?
end

def with_tcp_server
  server = Celluloid::IO::TCPServer.new(example_addr, example_port)
  begin
    yield server
  ensure
    server.close
  end
end

def with_connected_sockets
  with_tcp_server do |server|
    # FIXME: client isn't actually a Celluloid::IO::TCPSocket yet
    client = ::TCPSocket.new(example_addr, example_port)
    peer = server.accept

    begin
      yield peer, client
    ensure
      begin
        client.close
        peer.close
      rescue
      end
    end
  end
end
