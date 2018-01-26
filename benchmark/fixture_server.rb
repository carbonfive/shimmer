require "webrick"

class FixtureServer
  DEFAULT_PORT = 8345

  attr_reader :server_pid, :port

  def initialize(port: DEFAULT_PORT)
    @server_pid = nil
    @port = port
  end

  def start!
    puts "Starting WEBrick fixture server at port #{port}..."
    @server_pid = Process.fork do
      server = WEBrick::HTTPServer.new(
        Port: port,
        DocumentRoot: File.expand_path("fixtures", __dir__),
        Logger: WEBrick::Log.new(open(File::NULL, "w")),
        AccessLog: [File::NULL, WEBrick::AccessLog::COMMON_LOG_FORMAT]
      )
      trap("INT") { server.shutdown }
      server.start
    end
    @server_pid
  end

  def stop!
    puts "Stopping WEBrick fixture server..."
    Process.kill("INT", server_pid)
  end
end
