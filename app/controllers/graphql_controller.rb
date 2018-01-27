class GraphqlController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :setup, :set_announcement, :check_bans, :notify_appealable

  def self.permission_definition
  end

  def execute
    user = User.find_by_api_key(params[:key])
    (render json: {errors: [{:message => 'An invalid API key was specified'}]}; return if performed?) if user.nil?
    variables = ensure_hash(params[:variables])
    query = params[:query]
    operation_name = params[:operationName]
    context = {
        user: user
    }
    result = AvicusSchema.execute(query, variables: variables, context: context, operation_name: operation_name)
    render json: result
  end

  private

  # Handle form data, JSON body, or a blank value
  def ensure_hash(ambiguous_param)
    case ambiguous_param
      when String
        if ambiguous_param.present?
          ensure_hash(JSON.parse(ambiguous_param))
        else
          {}
        end
      when Hash, ActionController::Parameters
        ambiguous_param
      when nil
        {}
      else
        raise ArgumentError, "Unexpected parameter: #{ambiguous_param}"
    end
  end
end
