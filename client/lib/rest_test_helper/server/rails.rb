module RestTestHelper
  module Server
    class Rails
      attr_accessor :server_path, :environment, :port, :ip

      def initialize(server_path, environment = 'development', port = '3000', ip = '0.0.0.0')
        @server_path = server_path
        @environment = environment
        @port = port
        @ip = ip
      end

      def start
        cmd = "unset BUNDLE_GEMFILE; cd #{server_path}; thin start -d -e #{environment} -p #{port}"
        execute(cmd)
        wait_for_server
      end

      def stop
        if File.exist?(pidfile)
          pid = File.read(pidfile)
          cmd = "kill -9 #{pid}"
          execute(cmd)
        end
      end

      private

      def execute(cmd)
        puts cmd
        puts `#{cmd}`
      end

      def rails_script
        File.join(server_path, 'script', 'rails')
      end

      def pidfile
        File.join(server_path, 'tmp', 'pids', 'thin.pid')
      end

      def wait_for_server
        tries = 20
        while(!ping)
          raise "#{server_path} did not come up!" if tries == 0
          sleep (20 - tries)
          tries -= 1
        end
      end

      def ping(timeout = 5)
        begin
          timeout(timeout) do
            puts "pinging #{ip}:#{port}"
            s = TCPSocket.new(ip, port)
            s.close
            true
          end
        rescue Errno::ECONNREFUSED
          false
        rescue Timeout::Error, StandardError
          false
        end
      end
    end
  end
end
