Types::Scalar::DateTimeType = GraphQL::ScalarType.define do
  name 'DateTime'
  description 'A date with a time.'

  coerce_input ->(value, ctx) { DateTime.parse(value.to_s) }
  coerce_result ->(value, ctx) { value.strftime('%Y-%m-%dT%H:%M:%S.%L%z') }
end