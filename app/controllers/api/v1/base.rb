module API
  module V1
    class Base < Grape::API
      format :json
      helpers API::Helpers

      rescue_from :all do |e|
        case e
        when ActiveRecord::RecordNotFound
          error_response({:status=>404, :message=>"该记录不存在"})
        else
          error_response({:status=>500, :message=>"服务器错误"})
        end
      end

      mount API::V1::Resources::BackendBase
    end # end of class Base
  end # end of module V1
end # end of module API
