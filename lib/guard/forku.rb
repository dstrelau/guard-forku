require 'guard'
require 'guard/guard'

module Guard
  class Forku < Guard

    def start
      require 'test_helper'
      ActiveRecord::Base.connection.disconnect! if defined?(ActiveRecord::Base)
      notify 'Ready to test. Code away.'
    end

    # Called on Ctrl-/ signal
    #
    # Run each set of tests serially, as running them together can cause
    # problems with overlapping DB connections and other wonkiness.
    def run_all
      %w[unit functional integration performance].each do |test|
        load_in_fork("test/#{test}/**/*_test.rb")
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

      fork do
        ActiveRecord::Base.establish_connection if defined?(ActiveRecord::Base)
        $0 = paths.join(' ') # test/unit uses this
        if paths.empty?
          notify "No tests found", image: :pending
          exit! # skip test/unit autorun
        else
          paths.each {|p| load p }
        end
      end
      if Process.wait > 0
        notify "PASS"
      else
        notify "FAIL", image: :failed
      end
    end
    private :load_in_fork


    def notify(message, opts={})
      if options[:notify]
        Notifier.notify(message, opts)
      else
        UI.info("*** " << message)
      end
    end
  end
end
