# == Serviceable
#
# Provide a simple convension to write service object.
#
# Typically a service object does just ONE thing. You can use a +call+ method to trigger it.
#
# Then you can:
#
# * Use +success?+ or +failure?+ to check if it's success.
# * Use +result+ to see the return value of +call+ instance method.
# * Use +errors+ to check errors or +error+ to check base error.
#
# Example
#
#   service = Auth::LoginUser.call(login_params)
#
#   # If everything goes fine
#   service.success?  # => true
#   service.result    # => #<User>
#
#   # If there's something wrong
#   service.success?  # => false
#   service.error     # => "Invalid email or password"
#
# To implement the service, you need to implement two instance methods like this
#
#   module Auth
#     class LoginUser
#       include Serviceable
#
#       # The arguments are the same as class method +call+
#       def initialize(params)
#       end
#
#       # This method has no arguments!
#       # The return value becomes +service.result+
#       def call
#       end
#     end
#   end
#
module Serviceable
  extend ActiveSupport::Concern
  include ActiveModel::Validations

  included do
    attr_reader :result
  end

  class_methods do
    def call(*args)
      service = new(*args)
      service.send(:call_wrapper)
      service
    end
  end

  def success?
    !!@success
  end

  def failure?
    !success?
  end

  def error
    errors[:base].try(:first)
  end

  private

  def call_wrapper
    begin
      @result = call
    rescue ActiveModel::StrictValidationFailed
      errors.add :base, $!.message
    end
    @success = errors.empty?
  end

  def fail!(message)
    raise ActiveModel::StrictValidationFailed, message
  end
  alias_method :strict_validation_failed!, :fail!

  def transform_ids(ids)
    if ids.is_a?(Array)
      ids.map(&:to_i)
    else
      ids
    end
  end

  def transaction(&block)
    ActiveRecord::Base.transaction(&block)
  end

  def validate_schema!(schema, params)
    # Get raw params for ActionController::Parameters
    # Because we already use dry-validation, it's safe.
    if params.is_a?(ActionController::Parameters)
      params = params.to_unsafe_h
    end

    re = schema.(params)
    return re.output if re.success?

    # The `messages` is like this: { exp_year: ["is missing"] }
    key = re.messages.keys.first
    msg = re.messages[key].first
    fail! "#{key} #{msg}"
  end
end
