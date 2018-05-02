module Actions
  module ForemanAnsible
    module RunHostJobExtensions
      extend ActiveSupport::Concern

      included do
        def finalize(*args)
          super(*args)
          binding.pry
          puts "HEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEY"
        end
      end
    end
  end
end
