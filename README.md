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

### Upload

To upload all the files defined in the `shared_files` capistrano variable to a remote server, you can execute:

    bundle exec cap shared_file:upload

With backup (it creates a backup of the remote shared files on your machine before uploading the new versions to the remote machine):

    bundle exec cap shared_file:upload -s backup=true

### Download

To download all the files defined in the `shared_files` capistrano variable from a remote server, you can execute:

    bundle exec cap shared_file:download

With backup (it creates a backup of the local shared files on your machine before downloading the new versions from the remote machine):

    bundle exec cap shared_file:download -s backup=true
    
### Symlink

To symlink the uploaded configuration files to the current release path, you can execute:

    bundle exec cap shared_file:symlink
    
This task will be executed on every deploy. If you happen to make any changes in the files specified in the `shared_files` capistrano variable, make sure you upload them.

**Note**: You can use it together with `capistrano/ext/multistage` like:

    bundle exec cap <STAGE> shared_file:upload
    bundle exec cap <STAGE> shared_file:download
