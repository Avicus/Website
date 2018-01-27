if Avicus::Application.for_users?
  Peek.into Peek::Views::Git
  Peek.into Peek::Views::Mysql2
  Peek.into Peek::Views::PerformanceBar
  Peek.into Peek::Views::Redis
  Peek.into Peek::Views::Rblineprof
end
