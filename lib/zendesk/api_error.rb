module Zendesk

  class ApiError < ::StandardError
    attr_reader :error, :description, :details

    def initialize(api_error = {})
      # {"error"=>"RecordInvalid", "description"=>"Record validation errors", "details"=>{"base"=>[{"description"=>"Users must have at least one identity"}]}}]}
      @error = api_error['error']
      @description = api_error['description']
      @details = Zendesk::ApiError::Details.new(api_error['details'])
      super
    end
  end

  class ApiError::Details
    def initialize(details = [])
      @details = details
    end

    def to_s
      total = []
      @details.each_pair do |k,v|
        v.each { |x| total << "#{x['description']}" }
      end
      "#{total.join("\n")}"
    end
  end

end
