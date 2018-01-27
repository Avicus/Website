Mutations::Alerts::Send = GraphQL::Relay::Mutation.define do
  name 'AlertSend'
  description 'Send a user an alert.'

  input_field :id, !types.Int do
    description 'ID of the user.'
  end

  input_field :name, !types.String do
    description 'Name of the alert.'
  end

  input_field :url, !types.String do
    description 'URL of the alert.'
  end

  input_field :text, !types.String do
    description 'Text of the alert.'
  end

  return_field :success, !types.Boolean do
    description 'If the user was alerted.'
  end

  resolve ->(obj, args, ctx) {
    user = User.find_by_id(args[:id])
    response = {
        success: user.present? && user.alert(args[:name], args[:text], args[:url])
    }
  }
end