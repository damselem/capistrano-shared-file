# capistrano-shared-file
A Capistrano recipe to upload, download and symlink configuration files like `config/database.yml` or `config/application.yml` to or from your remote servers. Heavily inspired by teohm's [capistrano-shared_file](https://github.com/teohm/capistrano-shared_file) gem.

## Install

    gem install capistrano-shared-file

For Bundler, add this to your `Gemfile`:

    gem 'capistrano-shared-file'

## Usage

Add the following lines to `config/deploy.rb`:

    set :shared_files, %w(config/database.yml)
    require 'capistrano-shared-file'

## Tasks

To upload all the files defined in the `shared_files` capistrano variable to a remote server, you can simply execute:

    bundle exec cap shared_file:upload

To download all the files defined in the `shared_files` capistrano variable from a remote server, you can simply execute:

    bundle exec cap shared_file:download

**Note**: You can use it together with `capistrano/ext/multistage` like:

    bundle exec cap <STAGE> shared_file:upload
    bundle exec cap <STAGE> shared_file:download
