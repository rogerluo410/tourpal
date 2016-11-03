require 'grape-swagger'

module API
  module V1
    class Base < Grape::API
      format :json
      helpers API::Helpers
      add_swagger_documentation

      rescue_from :all do |e|
        case e
        when ActiveRecord::RecordNotFound
          error_response({:status=>404, :message=>"该记录不存在"})
        else
          error_response({:status=>500, :message=>"服务器错误"})
        end
      end
    end
  end
end
