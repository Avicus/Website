Types::Base::MutationType = GraphQL::ObjectType.define do
  name 'Mutation'

  # Users
  field :userLogin, Mutations::Users::Login.field

  # Gadgets
  field :gadgetPurchase, Mutations::Gadgets::Purchase.field
  field :gadgetUpdate, Mutations::Gadgets::Update.field

  # Friends
  field :friendAdd, Mutations::Friends::Add.field
  field :friendRemove, Mutations::Friends::Remove.field

  # Alerts
  field :alertDelete, Mutations::Alerts::Delete.field
  field :alertSend, Mutations::Alerts::Send.field

  # Presents
  field :presentFind, Mutations::Presents::Find.field
end
