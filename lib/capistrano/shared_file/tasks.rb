require 'capistrano'

unless Capistrano::Configuration.respond_to?(:instance)
  abort 'capistrano/shared_file requires Capistrano 2'
end

Capistrano::Configuration.instance.load do

  _cset :shared_files,                 %w(config/database.yml)
  _cset :shared_file_dir,              'files'
  _cset :shared_file_backup,           false
  _cset :shared_file_show_upload_diff, true

  def remote_path_to(file)
    File.join(shared_path, shared_file_dir, file)
  end

  def backup_path_to(file)
    File.join(File.dirname(file), "#{Time.now.strftime('%Y%m%dT%H%M%S')}_#{File.basename(file)}")
  end

  def confirm_upload_is_desired(backup_file, file)
    diff_result = `git diff --no-index --color=always --ignore-space-at-eol #{backup_file} #{file}`
    File.unlink(backup_file) unless shared_file_backup
    unless $?.success?
      puts "Showing diff for #{file}:"
      puts diff_result
      result = Capistrano::CLI.ui.ask('Are you sure that you want to upload your changes to #{file} (y/n)?', ['y','n'])
      return (result == 'y')
    end
  end

  namespace :shared_file do

    desc 'Generate remote directories for shared files.'
    task :setup, :except => { :no_release => true } do
      shared_files.each do |file|
        run "#{try_sudo} mkdir -p #{remote_path_to(File.dirname(file))}"
        run "#{try_sudo} chmod g+w #{remote_path_to(File.dirname(file))}" if fetch(:group_writable, true)
      end
    end
    after 'deploy:setup', 'shared_file:setup'

    desc 'Upload shared files to server'
    task :upload, :except => { :no_release => true } do
      shared_files.each do |file|
        if shared_file_backup || shared_file_show_upload_diff
          backup_file = backup_path_to(file)
          top.download(remote_path_to(file), backup_file, :via => :scp)
          if shared_file_show_upload_diff
            should_upload = confirm_upload_is_desired(backup_file, file)
            puts "No changes made to #{file}!"
          end
        end
        top.upload(file, remote_path_to(file), :via => :scp) if !shared_file_show_upload_diff || should_upload
      end
    end

    desc 'Download shared files from server.'
    task :download, :except => { :no_release => true } do
      shared_files.each do |file|
        if shared_file_backup
          run_locally "cp #{file} #{backup_path_to(file)}"
        end
        top.download(remote_path_to(file), file, :via => :scp)
      end
    end

    desc 'Symlink remote shared files to the current release directory.'
    task :symlink, :except => { :no_release => true } do
      shared_files.each do |file|
        run "ln -nfs #{remote_path_to(file)} #{release_path}/#{file}"
      end
    end
    after 'deploy:finalize_update', 'shared_file:symlink'

  end

end
