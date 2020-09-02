#!/usr/bin/env ruby
# frozen_string_literal: true

require 'tty-prompt'
require 'etc'

class Options
    def initialize
      @prompt = TTY::Prompt.new
    end

    def commit_files
      $lastmsg = 'Now that we commited the files'
      msg = @prompt.ask("Commit message:")
      Application.run("git commit -m #{msg}")
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
      Application.run(cmd)
    end

    def logs
      Application.run("git log")
    end

    def push_branch
      branch = @prompt.ask("Branch to push:")
      Application.run("git push origin #{branch}")
    end

    def remote_adress
      $lastmsg = 'Now that we the remote address'
      uname = @prompt.ask('Your github username:')
      repo = @prompt.ask('Your repository name:')
      puts("Adding remote repository https://github.com/#{uname}/#{repo}...")
      Application.run("git remote add origin https://github.com/#{uname}/#{repo}.git")
    end

    def status
      Application.run("git status")
    end

    def clone_repo
      uname = @prompt.ask("Username:")
      repo = @prompt.ask("Repository name:")
      Application.run("git clone https://github.com/#{uname}/#{repo}/")
    end

    def restore
      fname = @prompt.ask("File name:")
      Application.run("git restore #{fname}")
    end

    def initialize_git
      $lastmsg = "Now that we initialized .git"
      puts("Initializing Git repository in '#{Dir.pwd}/.git'...")
      Application.run("git init")
    end

    def diff
      Application.run("git diff")
    end

    def change_branch
      bname = @prompt.ask("Branch name:")
      Application.run("git checkout -b #{bname}")
    end

    def git_info
      status = {
          'Git branch' => IO.popen('git rev-parse --abbrev-ref HEAD'),
          'Repository name' => IO.popen('basename `git rev-parse --show-toplevel`')
      }
      status.each do |k, v|
        puts("#{k}: #{v.read}")
      end
      puts("____________\n\n")
    end

    def remove_file
      file_name = @prompt.ask("Enter the file name: ")
      Application.run("git rm #{file_name}")
    end

    def show_last_commit
      Application.run("git show")
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

  def self.run(cmd)
    puts("Command: #{cmd}")
    system(cmd)
  end

  def initialized_git?
    identify_user
    unless File.directory?('.git')
      options = ["Clone a repo", "Initialize a repo", "Close"]
      begin
        @git_init = @prompt.select("The .git directory was not found, what do you want?", options)
        initialized_git_verify
      rescue TTY::Reader::InputInterrupt
        abort("\nYou closed the application")
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
      abort('It is not possible to continue without a .git repository or cloned repository!')
    end
  end

  def identify_user
    if(File.exist?("/home/#{Etc.getlogin}/.gitconfig")) == false
        email = @prompt.ask("Github email: ")
        uname = @prompt.ask("Github username: ")
        self.run("git config --global user.email #{email} && git config --global user.name #{uname}")
    end
  end

  def show_panel
    options = ['Add remote address', 'Add files', 'Commit files', 'Push files to branch', 'Show git status', 'Show git logs']
    options.push("Show the last commit", 'Remove a file', 'Show diff', 'Change branch', 'Restore a file', 'Close')
    begin
      @opt.git_info
      @option = @prompt.select("#{$lastmsg}, what do you want to do?", options)
      panel_verify
    rescue TTY::Reader::InputInterrupt
      abort("\nYou closed the application")
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
    when "Change branch" then
      @opt.change_branch
    when 'Remove a file' then
      @opt.remove_file
    when 'Show the last commit' then
      @opt.show_last_commit
    else
      abort("Goodbye, closed.")
    end
  end

  def g4t_start
    loop { show_panel }
  end
end

Application.new
