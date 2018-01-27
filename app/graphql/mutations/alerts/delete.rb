Mutations::Alerts::Delete = GraphQL::Relay::Mutation.define do
  name 'AlertDelete'
  description 'Delete an alert.'

  input_field :alert_id, !types.Int do
    description 'ID of the alert to delete.'
  end

  return_field :success, !types.Boolean do
    description 'If the alert was delete.'
  end

  resolve ->(obj, args, ctx) {
    response = {
        success: Alert.where(id: args[:alert_id]).destroy_all
    }
  }
end
