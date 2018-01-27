conf = $avicus['redis']
password = conf['password']
db = conf['db']

$redis = Redis.new(conf)
$redis.auth(password) unless password.blank?
$redis.select(db)
