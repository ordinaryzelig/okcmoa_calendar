module OKCMOA
  module Verbose

    def puts(obj)
      Kernel.puts obj if OKCMOA.config.verbose
    end

  end

  extend Verbose
end
