# Swaggerize
 
[![Codacy Badge](https://app.codacy.com/project/badge/Grade/761dbbcee2354bfd9ce3c54fb250ad08)](https://app.codacy.com/gh/namely/swaggerize/dashboard)
[![Codacy Badge](https://app.codacy.com/project/badge/Coverage/761dbbcee2354bfd9ce3c54fb250ad08)](https://app.codacy.com/gh/namely/swaggerize/dashboard)

Auto generates swagger JSON documentation

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'swaggerize', git: 'https://github.com/namely/swaggerize.git'
```

And then execute:

    $ bundle install

Include Swaggerize in parent ApiController

```ruby
include Concerns::Swaggerize
```

You can exclude gem execution for a specific controller or action by adding

```ruby
skip_after_action :swaggerize, only: [:index, :show]
```
