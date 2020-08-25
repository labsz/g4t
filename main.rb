#!/usr/bin/env ruby
# frozen_string_literal: true

require 'tty-prompt'
require 'colorize'
require 'etc'

class Options
    def initialize
      @prompt = TTY::Prompt.new
    end

    def commit_files
      $lastmsg = 'Now that we commited the files'
      msg = @prompt.ask("Message to commit:")
      cmd = "git commit -m #{msg}"
      puts("Command: #{cmd}")
      system(cmd)
    end

    def add_files
      $lastmsg = 'Now that we added the files'
      all_files = @prompt.yes?("Add all files?")
      if all_files
          cmd = "git add ."
          puts("Adding all files...")
      else
          fname = @prompt.ask("File to add:")
          cmd = "git add #{fname}"
      end
      puts("Command: #{cmd}")
      system(cmd)
    end

    def logs
      cmd = "git log"
      puts("Command: #{cmd}")
      system(cmd)
    end

    def push_branch
      branch = @prompt.ask("Branch to push:")
      cmd = "git push origin #{branch}"
      puts("Command: #{cmd}")
      system(cmd)
    end

    def remote_adress
      $lastmsg = 'Now that we the remote address'
      uname = @prompt.ask('Your github username:')
      repo = @prompt.ask('Your repository name:')
      cmd = "git remote add origin https://github.com/#{uname}/#{repo}.git"
      puts("Adding remote repository https://github.com/#{uname}/#{repo}...")
      puts("Command: #{cmd}")
      system(cmd)
    end

    def status
      cmd = "git status"
      puts("Command: #{cmd}")
      system(cmd)
    end

    def clone_repo
      uname = @prompt.ask("User name:")
      repo = @prompt.ask("Repository name:")
      cmd = "git clone https://github.com/#{uname}/#{repo}/"
      puts("Command: #{cmd}")
      system(cmd)
    end

    def restore
      fname = @prompt.ask("File name:")
      cmd = "git restore #{fname}"
      puts("Command: #{cmd}")
      system(cmd)
    end
end

class Application
  def initialize
    @prompt = TTY::Prompt.new
    @opt = Options.new
    $lastmsg ||= "With .git initialized"
    initialized_git?
    g4t_start
  end

  def initialized_git?
    identify_user
    unless File.directory?('.git')
      git_init = @prompt.yes?('The .git directory was not found, do you want to initialize it?')
      if git_init
        $lastmsg = "Now that we initialized .git"
        cmd = "git init"
        puts("Initializing Git repository in '#{Dir.pwd}/.git'...")
        puts("Command: #{cmd}")
        system(cmd)
      else
        abort('Can not possible continue without .git repository!')
      end
    end
  end

  def identify_user
    if(File.exist?("/home/#{Etc.getlogin}/.gitconfig")) == false
        email = @prompt.ask("Github email: ")
        uname = @prompt.ask("Github username: ")
        cmd = "git config --global user.email #{email} && git config --global user.name #{uname}"
        puts("Command: #{cmd}")
        system(cmd)
    end
  end

  def show_panel
    options = ['Add remote address', 'Add files', 'Commit files', 'Push files to branch', 'Show git status', 'Show git logs']
    options.push('Clone a repo', 'Restore a file', 'Close')
    option = @prompt.select("#{$lastmsg}, what do you want to do?", options)
    case option
    when 'Add remote address' then
      @opt.remote_adress
    when 'Add files' then
      @opt.add_files
    when 'Commit files' then
      @opt.commit_files
    when 'Push files to branch' then
      @opt.push_branch
    when 'Show git status' then
      @opt.status
    when 'Show git logs' then
      @opt.logs
    when 'Restore a file' then
      @opt.restore
    when 'Clone a repo' then
      @opt.clone_repo
    when 'Close' then
      puts "Goodbye"
      exit
    end
  end

  def g4t_start
    loop { show_panel }
  end
end

Application.new
