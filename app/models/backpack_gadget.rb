class BackpackGadget < ActiveRecord::Base
  belongs_to :user

  include GraphQL::QLModel

  graphql_finders(:user_id, :gadget_type, :old_id)

  graphql_type description: "A gadget housed in a user's backpack.",
               fields: {
                   user_id: 'ID of the user who has this gadget in their backpack.',
                   gadget_type: 'Type of the base gadget of this item.',
                   gadget: 'Special data associated with the gadget regardless of context.',
                   context: 'Context of the gadget related to the specific user.',
                   old_id: 'ID of the gadget before the Atlas conversion.',
               },
               create: true, update: true
end
