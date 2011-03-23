require 'guard'
require 'guard/guard'

module Guard
  class Forku < Guard

    def start
      UI.info "Loading test_helper"
      require 'test_helper'
      ActiveRecord::Base.connection.disconnect! if defined?(ActiveRecord::Base)
      UI.info "Ready"
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

      fork do
        ActiveRecord::Base.establish_connection if defined?(ActiveRecord::Base)
        $0 = paths.join(' ') # test/unit uses this
        if paths.empty?
          UI.info "No tests found. Skipping."
          exit! # skip test/unit autorun
        else
          paths.each {|p| load p }
        end
      end
    end
    private :load_in_fork

  end
end
