# Originally from https://github.com/rmosolgo/graphql-ruby/issues/945

=begin
  This should be included by all modules that should be exposed to the API.
  When included, the [graphql_type] method should be used to register the module with the API generator.
  Queries can also be auto-generated from fields using the [graphql_finders] method.
=end

module GraphQL::QLModel
  def self.included(klazz)
    klazz.extend Macros
  end

  module Macros

    @@queries = {}

    # used to create a GraphQL type from a declarative specification
    # @param name [String] the name of the type, defaults to the class name
    # @param description [String] a docstring for GraphQL
    # @param fields [Array<Symbol>] a list of fields to expose with GraphQL
    # @param create [Boolean] If a created_at field should be added.
    # @param update [Boolean] If a updated_at field should be added.
    # @return [GraphQL::ObjectType] a GraphQL object type to declare for the schema
    def graphql_type(name: self.name,
                     description: '',
                     fields:,
                     custom_fields: [],
                     create: false,
                     update: false)

      return if Avicus::Application.running_rake?
      # because of the way GraphQL creates objects
      # we have to reference self outside of the define block
      columns = nil
      begin
        columns = self.columns_hash
      rescue Exception => e
        puts 'Failed to get model info from DB!'
        return
      end

      fields[:created_at] = "Date when this #{name.downcase} was created." if create
      fields[:updated_at] = "Date when this #{name.downcase} was last updated." if update

      type = GraphQL::ObjectType.define do
        name name
        description description

        fields.each do |f, desc|
          col = columns[f.to_s]
          puts "Column #{f} not found for class #{name}" if col.nil?
          field f.to_sym, GraphQL::QLModel.convert_type(col.type, col.name) do
            description desc
            resolve ->(obj, args, ctx) {
              if ctx[:user].has_permission?(:api, name.to_s.underscore.to_sym, :see, f.to_s.underscore.to_sym, true)
                obj.send(f.to_sym)
              else
                nil
              end
            }
          end unless col.nil?
        end
        custom_fields.each do |f|
          fields[f.name.to_sym] = f.description
          field f.name.to_sym, f.type do
            description f.description
            resolve ->(obj, args, ctx) {
              if ctx[:user].has_permission?(:api, name.to_s.underscore.to_sym, :see, f.name.to_s.underscore.to_sym, true)
                f.resolver.call(obj, args, ctx)
              else
                nil
              end
            }
          end
        end
      end
      define_singleton_method(:graphql_type) do
        type
      end

      define_singleton_method(:graph_fields) do
        fields.keys
      end

      Types.const_set "#{name}Type", type
    end

    # Generate queries for the supplied fields
    # @param fields Field names that should be query-able from the API
    # @param name Base name of the query. Defaults to the current class name
    def graphql_finders(*fields, name: self.name)
      return if Avicus::Application.running_rake?

      clazz = self
      columns = nil
      begin
        columns = self.columns_hash
      rescue Exception => e
        puts 'Failed to get model info from DB! ' + e.to_s
        return
      end

      fields.unshift(:id) unless fields.include?(:id)

      @finders = fields

      @@queries[name.pluralize(2).camelize(:lower)] = GraphQL::Field.define do
        name name.pluralize(2).camelize(:lower)
        type Types.const_get("#{name}Type").to_list_type
        description 'Search for all ' + name.pluralize
        fields.each do |f|
          col = columns[f.to_s]
          puts "Column #{f} not found for class #{name}" if col.nil?
          argument f, GraphQL::QLModel.convert_type(col.type, col.name) unless col.nil?
        end
        resolve ->(_, args, ctx) do
          safe_args = args.each.select do |arg, val|
            fields.include?(arg.to_sym) && ctx[:user].has_permission?(:api, name.to_s.underscore.to_sym, :query, arg.to_s.underscore.to_sym, true)
          end
          search = clazz
          safe_args.each do |arg, val|
            search = search.where("#{arg}": val)
          end
          search.all
        end
      end

      define_singleton_method(:graph_finders) do
        @finders
      end
    end

    # used to create a GraphQL query for the ActiveRecord model
    # @param name [String] the name of the type, defaults to the class name
    # @param description [String] a docstring for GraphQL
    # @param arguments [Array<Hash{Symbol:Boolean}>] a list of maps of argument names to required booleans
    # @param resolver [Proc] a method that will resolve the query
    # @param multi [Boolean] If multiple results will be returned
    # @return [GraphQL::Field] a GraphQL field object to use in the schema
    def graphql_query(operation: 'find',
                      name: '',
                      class_name: self.name,
                      description: '',
                      arguments: [],
                      resolver:,
                      multi: false)
      return if Avicus::Application.running_rake?

      columns = nil
      begin
        columns = self.columns_hash
      rescue Exception => e
        puts 'Failed to get model info from DB! ' + e.to_s
        return
      end

      name = operation + class_name + name

      type = Types.const_get("#{class_name}Type")
      type = type.to_list_type if multi

      @@queries[name] = GraphQL::Field.define do
        name name
        type type
        description description
        arguments.each do |k|
          # TODO: use boolean required argument value to invoke to_non_null_type
          col = columns[k.to_s]
          puts "Column #{k} not found for class #{name}" if col.nil?
          argument k, GraphQL::QLModel.convert_type(col.type, col.name) unless col.nil?
        end
        resolve resolver
      end
    end

    # @return A Hash of {name => [GraphQL::Field]} that have been defined by this module.
    def graph_queries
      @@queries
    end

  end

  # convert a database type to a GraphQL type
  # @param db_type [Symbol] the type returned by columns_hash[column_name].type
  # @return [GraphQL::ScalarType] a GraphQL type
  def self.convert_type(db_type, name)
    # because we're outside of a GraphQL define block we cannot use the types helper
    # we must refer directly to the built-in GraphQL scalar types

    case db_type
      when :integer
        GraphQL::INT_TYPE
      when :boolean
        GraphQL::BOOLEAN_TYPE
      when :string
        GraphQL::STRING_TYPE
      when :text
        GraphQL::STRING_TYPE
      when :decimal
        GraphQL::FLOAT_TYPE
      when :datetime
        Types::Scalar::DateTimeType
      else
        puts 'Unknown type: ' + db_type.to_s
        GraphQL::STRING_TYPE
    end
  end

  # return [Array<Class>] a list of classes that implements this module
  def self.implementations
    Rails.application.eager_load!
    ActiveRecord::Base.descendants.each.select do |clz|
      begin
        clz.included_modules.include? GraphQL::QLModel
      rescue
        # it's okay that this is empty - just covering the possibility
      end
    end
  end

end