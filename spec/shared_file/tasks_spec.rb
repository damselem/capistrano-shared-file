require 'spec_helper'

describe Capistrano::SharedFile do
  before do
    @configuration = Capistrano::Configuration.new
    @configuration.extend(Capistrano::Spec::ConfigurationExtension)
    Capistrano::SharedFile.load_into(@configuration)

    @configuration.set :shared_path, '/home/project/shared'
    @configuration.set :release_path, '/home/project/releases/1234'
  end

  it 'defines shared_file:upload' do
    expect(@configuration.find_task('shared_file:upload')).to_not be_nil
  end

  it 'defines shared_file:download' do
    expect(@configuration.find_task('shared_file:download')).to_not be_nil
  end

  it 'defines shared_file:symlink' do
    expect(@configuration.find_task('shared_file:symlink')).to_not be_nil
  end

  it 'defines shared_file:setup' do
    expect(@configuration.find_task('shared_file:setup')).to_not be_nil
  end

  describe 'shared_file:setup' do
    before do
      @configuration.find_and_execute_task('shared_file:setup')
    end

    it 'creates the shared files directory' do
      command = 'mkdir -p /home/project/shared/files/config'
      expect(@configuration).to have_run(command)
    end

    it 'changes the permissions of the shared files directory' do
      command = 'chmod g+w /home/project/shared/files/config'
      expect(@configuration).to have_run(command)
    end

  end

  describe 'shared_file:upload' do
    context 'given there are 2 shared files' do
      before do
        @configuration.set :shared_files, %w(config/database.yml config/application.yml)
        @configuration.find_and_execute_task('shared_file:upload')
      end

      it 'uploads config/database.yml' do
        expect(@configuration).to have_uploaded('config/database.yml').to('/home/project/shared/files/config/database.yml')
      end

      it 'uploads config/application.yml' do
        expect(@configuration).to have_uploaded('config/application.yml').to('/home/project/shared/files/config/application.yml')
      end
    end
  end

  describe 'shared_file:download' do
    context 'given there are 2 shared files' do
      before do
        @configuration.set :shared_files, %w(config/database.yml config/application.yml)
        @configuration.find_and_execute_task('shared_file:download')
      end

      it 'downloads config/database.yml' do
        expect(@configuration).to have_downloaded('config/database.yml').from('/home/project/shared/files/config/database.yml')
      end

      it 'downloads config/application.yml' do
        expect(@configuration).to have_downloaded('config/application.yml').from('/home/project/shared/files/config/application.yml')
      end
    end
  end

  describe 'shared_file:symlink' do
    context 'given there are 2 shared files' do
      before do
        @configuration.set :shared_files, %w(config/database.yml config/application.yml)
        @configuration.find_and_execute_task('shared_file:symlink')
      end

      it 'symlinks config/database.yml' do
        command = 'ln -nfs /home/project/shared/files/config/database.yml /home/project/releases/1234/config/database.yml'
        expect(@configuration).to have_run(command)
      end

      it 'symlinks config/application.yml' do
        command = 'ln -nfs /home/project/shared/files/config/application.yml /home/project/releases/1234/config/application.yml'
        expect(@configuration).to have_run(command)
      end

      it 'performs shared_file:symlink after deploy:finalize_update' do
        @configuration.should callback('shared_file:symlink').after('deploy:finalize_update')
      end

    end
  end

end
