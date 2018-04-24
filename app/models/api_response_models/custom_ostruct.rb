require "ostruct"
module ApiResponseModels
  class CustomOstruct < OpenStruct
    def as_json(options = nil)
      @table.as_json(options)
    end

    def as_serialized_json
      serializer.serialized_json
    end

    def serializer
      keys = @table.keys
      c = Class.new do
        def self.name
          'CustomOstructSerializer'
        end
        include FastJsonapi::ObjectSerializer
        keys.each do |key|
          attribute key.to_sym
        end
      end
      c.new(self)
    end
  end
end
