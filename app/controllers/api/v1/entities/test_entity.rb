module API
  module V1
    class Entities::TestEntity < Grape::Entity
      expose :id, documentation: { type: 'Integer' }
      expose :open_id, documentation: { type: 'Integer' }
    end
  end
end
