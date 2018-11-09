require 'mongoid'

Mongoid.load!('config/mongoid.yml', :development)

require_relative '../models/user'
