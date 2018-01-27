Mutations::Users::Login = GraphQL::Relay::Mutation.define do
  name 'UserLogin'
  description 'When a user logs into a server, will create a new user if one does not exist.'

  input_field :username, !types.String do
    description 'Username of the user.'
  end

  input_field :server, !types.Int do
    description 'ID of the server the user is logging into.'
  end

  input_field :uuid, !types.String do
    description 'UUID of the user.'
  end

  input_field :time, !Types::Scalar::DateTimeType do
    description 'Time of the operation.'
  end

  return_field :permissions, !types[types.String] do
    description 'Permissions that the user should receive when joining this server. These include category permissions.'
  end

  return_field :message, types.String do
    description 'Message to be shown to the user when they join. This is usually a recent announce message.'
  end

  return_field :has_alerts, !types.Boolean do
    description 'If the user has web alerts which are unread.'
  end

  return_field :settings, !types[Types::SettingType] do
    description 'Saved settings for the user.'
  end

  return_field :gadgets, !types[Types::BackpackGadgetType] do
    description 'Gadgets which a user has in their backpack.'
  end

  return_field :disallow_scope, !DisallowScope do
    description 'Information about if this login is allowed.'
  end

  return_field :chat_data, !ChatData do
    description "Information about the user's display in chat."
  end

  resolve ->(obj, args, ctx) {
    # TODO: define resolve function
  }
end

DisallowScope = GraphQL::ObjectType.define do
  name 'DisallowScope'
  description 'Information about if this login is allowed.'

  field :permissions, !types.Boolean do
    description 'If the login is disallowed due to lack of permissions.'
  end
  field :punishment, !types.Boolean do
    description 'If the login is disallowed due to a punishment.'
  end
  field :punishment_data, Types::PunishmentType do
    description 'The punishment that disallowed the login.'
  end
end

ChatData = GraphQL::ObjectType.define do
  name 'ChatData'
  description "Information about the user's display in chat."

  field :prefix, types.String do
    description 'Prefix that the user should have in game.'
  end
  field :suffix, types.String do
    description 'Suffix that the user should have in game.'
  end
end