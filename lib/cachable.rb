module Cachable
  # Get a cached value for a field.
  # If the result is not in the cache, it will be grabbed and stored in the cache.
  def cached_for(duration, field, *args)
    copy = *args
    args.each_with_index { |arg, i| copy[i] = arg.duplicable? ? arg.dup : arg } # creates a duplicate of *args
    key = get_key(field, *copy)
    value = $redis.get(key) || cache(field, self.send(field, *args), duration, *copy)
    YAML.load(value)
  end

  # Helper method to get the cached value of a field for 1 week.
  def cached(field, *args)
    cached_for(1.week, field, *args)
  end

  # Check if a field if cached in redis.
  def is_cached?(field, *args)
    $redis.exists(get_key(field, *args))
  end

  # Flush data from redis.
  def flush(field = '*')
    match = Cachable.get_key(self.class, cachable_id, field, '*')
    keys = $redis.keys(match)
    $redis.del(keys) unless keys.empty?
  end

  # Flush data from a class.
  def flush_class(field = '*')
    Cachable.flush_class(self.class, field)
  end

  # Flush data from a class.
  def self.flush_class(clazz, field = '*')
    match = Cachable.get_key(clazz, '*', field, '*')
    keys = $redis.keys(match)
    $redis.del(keys) unless keys.empty?
  end

  private

  # Set a key to a value in redis.
  def cache(field, value, duration, *args)
    value = value.to_yaml
    key = get_key(field, *args)
    $redis.set(key, value)
    $redis.expire(key, duration)
    value.to_s
  end

  # Get the ID that should be used for key generation.
  def cachable_id
    # defaults to 'id'
    if self.respond_to?(:id)
      return self.send(:id)
    end
    '_'
  end

  # Generate a unique key for use in redis.
  def get_key(field, *args)
    Cachable.get_key(self.class, cachable_id, field, args.to_json)
  end

  # Generate a unique key for use in redis.
  def self.get_key(clazz, id, field, args_json)
    "cachable:#{clazz.name}:#{field}:#{args_json}:#{id}"
  end
end
