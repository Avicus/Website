Mutations::Gadgets::Purchase = GraphQL::Relay::Mutation.define do
  name 'GadgetPurchase'
  description 'When a gadget is attempting to be purchased by a user.'

  input_field :user_id, !types.Int do
    description 'ID of the user who is attempting to purchase.'
  end

  input_field :gadget_id, !types.Int do
    description 'ID of the gadget that is being purchased.'
  end

  return_field :failed, !types.Boolean do
    description 'If the purchase failed.'
  end

  return_field :fail_reason, !FailReason do
    description 'Information about why the purchase failed.'
  end

  resolve ->(obj, args, ctx) {
    # TODO: define resolve function
  }
end

FailReason = GraphQL::ObjectType.define do
  name 'FailReason'
  description 'The reason the purchase failed.'

  field :money, !types.Boolean do
    description 'If the purchase failed due to a lack of currency.'
  end
  field :rank, !types.Boolean do
    description 'If the purchase failed due to a lack of rank.'
  end

end