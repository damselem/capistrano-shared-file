require 'capistrano-shared-file'
require 'capistrano-spec'

RSpec.configure do
  include Capistrano::Spec::Matchers
end
