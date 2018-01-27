# Write a key-value pair to the rails cache.
def set_cache(var, value, time)
  Rails.cache.write(var, value, :expires_in => time)
  value
end

# Get a value from the rails cache.
# If the cache does not contain the key, the default will be used.
def get_cache(var, default = nil)
  stored = Rails.cache.read(var)
  stored == nil ? default : stored
end

# Clear the rails cache.
def reset_cache(var)
  Rails.cache.delete(var)
end

# Check if a key is in the cache.
def is_in_cache(var)
  Rails.cache.exist?(var)
end
