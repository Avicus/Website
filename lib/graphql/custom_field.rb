class GraphQL::CustomField
  attr_accessor :name, :description, :type, :resolver

  def initialize(name, description, type, resolver)
    @name = name
    @description = description
    @type = type
    @resolver = resolver
  end
end