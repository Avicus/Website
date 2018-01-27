Mutations::Gadgets::Update = GraphQL::Relay::Mutation.define do
  name 'GadgetUpdate'
  description 'When a gadget is used by a user, returned usages remaining and if the gadget should be removed.'

  input_field :user_id, !types.Int do
    description 'ID of the user who is using the gadget.'
  end

  input_field :gadget_id, !types.Int do
    description 'ID of the gadget that is being used.'
  end

  return_field :usages_remaining, !types.Int do
    description 'Amount of usages remaining AFTER the current use.'
  end

  return_field :remove, !types.Boolean do
    description "If the gadget should be removed from the user's backpack."
  end

  resolve ->(obj, args, ctx) {
    # TODO: define resolve function
  }
end