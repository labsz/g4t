#!/usr/bin/env ruby
# frozen_string_literal: true

require 'tty-prompt'
require 'colorize'
require 'etc'

class Application
  def initialize
    @prompt = TTY::Prompt.new
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
    if(File.exists?("/home/#{Etc.getlogin}/.gitconfig")) == false
        email = @prompt.ask("Github email: ")
        uname = @prompt.ask("Github username: ")
        cmd = "git config --global user.email #{email} && git config --global user.name #{uname}"
        puts("Command: #{cmd}")
        system(cmd)
    end
  end

  def show_panel
    opts = ['Add remote address', 'Add files', 'Commit files', 'Push files to branch', 'Show git status', 'Show git logs', "Close"]
    option = @prompt.select("#{$lastmsg}, what do you want to do?", opts)
    case option
    when 'Add remote address' then
      $lastmsg = 'Now that we the remote address'
      uname = @prompt.ask('Your github username:')
      repo = @prompt.ask('Your repository name:')
      cmd = "git remote add origin https://github.com/#{uname}/#{repo}.git"
      puts("Adding remote repository https://github.com/#{uname}/#{repo}...")
      puts("Command: #{cmd}")
      system(cmd)
    when 'Add files' then
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
    when 'Commit files' then
      $lastmsg = 'Now that we commited the files'
      msg = @prompt.ask("Message to commit:")
      cmd = "git commit -m #{msg}"
      puts("Command: #{cmd}")
      system(cmd)
    when 'Push files to branch' then
      branch = @prompt.ask("Branch to push:")
      cmd = "git push origin #{branch}"
      puts("Command: #{cmd}")
      system(cmd)
    when 'Show git status' then
      cmd = "git status"
      puts("Command: #{cmd}")
      system(cmd)
    when 'Show git logs' then
      cmd = "git log"
      puts("Command: #{cmd}")
      system(cmd)
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
