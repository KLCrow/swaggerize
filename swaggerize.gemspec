Gem::Specification.new do |s|
  s.name        = 'swaggerize'
  s.version     = '0.0.0'
  s.date        = '2019-04-18'
  s.summary     = 'Swaggerize'
  s.description = 'Auto generator swagger docs'
  s.authors     = ['Lyubomyr Kardash']
  s.email       = 'lyubomyr.kardash@namely.com'
  s.files       = `git ls-files -z`.split("\x0")
  s.homepage    = 'http://rubygems.org/gems/swaggerize'
  s.license     = 'MIT'

  s.add_dependency 'json-schema-generator'
end