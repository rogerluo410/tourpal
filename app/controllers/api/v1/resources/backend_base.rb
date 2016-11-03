module API
  class V1::Resources::BackendBase < API::V1::Base
    prefix :api

    namespace :backend do

      desc 'Returns test Entity.' do
        detail 'more details'
        params  nil
        success API::V1::Entities::TestEntity
        failure [[401, 'Unauthorized', 'Entities::Error']]
        named 'test grape api'
      end
      get 'test' do
        users = User.all
        present :data, API::V1::Entities::TestEntity.represent(users), type: Hash
      end

    end # end of namespace

  end # end of class
end # end of module
