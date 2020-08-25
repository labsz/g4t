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

    def initialize_git
      $lastmsg = "Now that we initialized .git"
      cmd = "git init"
      puts("Initializing Git repository in '#{Dir.pwd}/.git'...")
      puts("Command: #{cmd}")
      system(cmd)
    end

    def diff
      cmd = "git diff"
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
      options = ["Clone a repo", "Initialize a repo", "Close"]
      begin
        @git_init = @prompt.select("The .git directory was not found, what you wanna?", options)
        initialized_git_verify
      rescue TTY::Reader::InputInterrupt
        abort("\nYou close the application")
      end
    end
  end

  def initialized_git_verify
    case @git_init
    when "Initialize a repo" then
      @opt.initialize_git
    when "Clone a repo" then
      @opt.clone_repo
    else
      abort('Can not possible continue without .git repository or a repository cloned!')
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
    options.push('Show diff', 'Restore a file', 'Close')
    begin
      @option = @prompt.select("#{$lastmsg}, what do you want to do?", options)
      panel_verify
    rescue TTY::Reader::InputInterrupt
      abort("\nYou close the application")
    end
  end

  def panel_verify
    case @option
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
    when 'Show diff' then
      @opt.diff
    when 'Restore a file' then
      @opt.restore
    else
      abort("Goodbye, closed.")
    end
  end

  def g4t_start
    loop { show_panel }
  end
end

Application.new
