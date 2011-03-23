require 'guard'
require 'guard/guard'

module Guard
  class Forku < Guard

    def start
      UI.info "Loading..."
      require 'test_helper'
      ActiveRecord::Base.connection.disconnect! if defined?(ActiveRecord::Base)
      UI.info "Ready."
      notify 'Ready', image: :pending
    end

    # Called on Ctrl-/ signal
    #
    # Run each set of tests serially, as running them together can cause
    # problems with overlapping DB connections and other wonkiness.
    def run_all
      %w[unit functional integration performance].each do |test|
        load_in_fork("test/#{test}/**/*_test.rb")
        Process.wait
      end
    end

    # Called on file(s) modifications
    def run_on_change(paths)
      load_in_fork(*paths)
    end

    def load_in_fork(*paths)
      paths.collect! {|p|
        p = File.join(p,'**/*_test.rb') if File.directory?(p)
        Dir.glob(p)
      }.flatten!

      pid = fork do
        ActiveRecord::Base.establish_connection if defined?(ActiveRecord::Base)
        $0 = paths.join(' ') # test/unit uses this
        if paths.empty?
        then exit!(2) # skip test/unit autorun
        else paths.each {|p| load p }
        end
      end

      Process.wait(pid)
      case status = $?.exitstatus
      when 0 then notify paths.join(' '),  image: :success
      when 1 then notify paths.join(' '),  image: :failed
      when 2 then notify 'No tests found', image: :pending
      end
    end
    private :load_in_fork

    def notify(message, opts={})
      Notifier.notify(message, opts) if options[:notify]
    end

  end
end
