# capistrano-shared-file
A Capistrano recipe to upload, download and symlink configuration files like `config/database.yml` to or from your remote servers.

One of the most common use cases for this gem is when used together with [Figaro](https://github.com/laserlemon/figaro), where the `config/application.yml` file is *git-ignored* but you still want to have a convenient way to push it to your servers on every deploy.

Heavily inspired by teohm's [capistrano-shared_file](https://github.com/teohm/capistrano-shared_file) gem.

## Install

    gem install capistrano-shared-file

For Bundler, add this to your `Gemfile`:

    gem 'capistrano-shared-file'

## Usage

You can start using it by simply adding the line below at the bottom of your `deploy.rb`:

    require 'capistrano-shared-file'

Generally you won't need to modify any of the default variables defined in the gem. For a more customized setup, please refer to the next section.

## Variables

The following is the list of capistrano variables that are defined in this gem and that can be customized to fit your specific needs.

### shared_files

Specifies the list of files that you want to symlink to the `current_release` directory. By default:

    set :shared_files, %w(config/database.yml)

For example, when using [Figaro](https://github.com/laserlemon/figaro) you will probably want to add the `application.yml` file to this list.

    set :shared_files, %w(config/database.yml config/application.yml)

### shared_file_dir

Specify the directory in which you want to upload all shared files. By default:

    set :shared_file_dir, 'files'

For example, given the following variables are set in your `deploy.rb`:

    set :deploy_to,       '/home/damselem/my_amazing_project
    set :shared_file_dir, 'files'
    set :shared_files,    %w(config/application.yml)

The shared file in the remote will be at:

    /home/damselem/my_amazing_project/shared/files/config/application.yml

### shared_file_backup

Enbales backups of your shared files when uploading and downloading shared files. By default:

    set :shared_file_backup, false

For more details on the implications of setting this variable to `true`, refer to the next **Upload** and **Download** sections.

## Tasks

### Upload

To upload all the files defined in the `shared_files` capistrano variable to a remote server, you can execute:

    bundle exec cap shared_file:upload

With backup (it creates a backup of the remote shared files on your machine before uploading the new versions to the remote machine):

    bundle exec cap shared_file:upload -S shared_file_backup=true

### Download

To download all the files defined in the `shared_files` capistrano variable from a remote server, you can execute:

    bundle exec cap shared_file:download

With backup (it creates a backup of the local shared files on your machine before downloading the new versions from the remote machine):

    bundle exec cap shared_file:download -S shared_file_backup=true

### Symlink

To symlink the uploaded configuration files to the current release path, you can execute:

    bundle exec cap shared_file:symlink

You normally shouldn't have to execute it manually since it's already executed automatically on every deploy.

## capistrano/ext/multistage
This gem has been tested to work with `capistrano/ext/multistage`. For example:

    bundle exec cap <STAGE> shared_file:upload
    bundle exec cap <STAGE> shared_file:download
