#!/usr/bin/env ruby
# frozen_string_literal: true

require "tty-prompt"
require "os"
require "etc"

class Options
    def initialize
      @prompt = TTY::Prompt.new
    end

    def commit_files
      $lastmsg = "Now that we commited the files"
      msg = @prompt.ask("Commit message:")

      if msg[0] != "\""
        msg = "\"#{msg}"
      end

      if msg[-1] != "\""
        msg = "#{msg}\""
      end

      puts msg
      `git commit -m #{msg}`
    end

    def add_files
      $lastmsg = "Now that we added the files"
      all_files = @prompt.yes?("Add all files?")
      if all_files
        cmd = "git add ."
        puts("Adding all files...")
      else
        fname = @prompt.ask("File to add:")
        cmd = "git add #{fname}"
      end
      `#{cmd}`
    end

    def logs
      `git log`
    end

    def push_branch
      branch = @prompt.ask("Branch to push:")
      `git push origin #{branch}`
    end

    def remote_adress
      $lastmsg = "Now that we the remote address"
      uname = @prompt.ask("Your github username:")
      repo = @prompt.ask("Your repository name:")
      puts("Adding remote repository https://github.com/#{uname}/#{repo}...")
      `git remote add origin https://github.com/#{uname}/#{repo}.git`
    end

    def status
      Application.run("git status")
    end

    def clone_repo
      uname = @prompt.ask("Username:")
      repo = @prompt.ask("Repository name:")
      `git clone https://github.com/#{uname}/#{repo}/`
    end

    def restore
      fname = @prompt.ask("File name:")
      `git restore #{fname}`
    end

    def reset
      commit = @prompt.ask("Commit id:")
      `git reset --hard #{commit}`
    end

    def hard_reset
      confirmation = @prompt.yes?("do you really want to hard reset?")

      if confirmation
        `git reset --hard HEAD~`

      else
        puts "Cancelling operation"
      end

    end

    def initialize_git
      $lastmsg = "Now that we initialized .git"
      puts("Initializing Git repository in '#{Dir.pwd}/.git'...")
      `git init`
    end

    def diff
      Application.run("git diff")
    end

    def change_branch
      bname = @prompt.ask("Branch name:")
      `git checkout -b #{bname}`
    end

    def git_info
      status = {
          "Git branch" => IO.popen("git branch"),
          "Repository url" => IO.popen("git config --get remote.origin.url")
      }
      status.each do |k, v|
        puts("#{k}: #{v.read}")
      end
      puts("____________\n\n")
    end

    def remove_file
      file_name = @prompt.ask("Enter the file name: ")
      `git rm #{file_name}`
    end

    def show_last_commit
      Application.run("git show")
    end

    def pull_changes
      git_pull_options = ["rebase", "no-rebase", "ff-only"]
      chose = @prompt.select("chose: ", git_pull_options)
      `git pull --#{chose}`
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
    unless File.directory?(".git")
      options = ["Clone a repo", "Initialize a repo", "Close"]
      begin
        @git_init = @prompt.select("The .git directory was not found, what do you want to do?", options)
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
      abort("It is not possible to continue without a .git repository or cloned repository!")
    end
  end

  def identify_user
    if OS.windows? == true
      git_config = "C:\\Users\\#{Etc.getlogin}\\.gitconfig"
    else
      git_config = "/home/#{Etc.getlogin}/.gitconfig"
    end
    if(File.exist?(git_config)) == false
      begin
        email = @prompt.ask("Github email: ")
        uname = @prompt.ask("Github username: ")
        self.run("git config --global user.email #{email} && git config --global user.name #{uname}")
      rescue TTY::Reader::InputInterrupt
        abort("\nYou closed the application")
      end
    end
  end

  def show_panel
    options = ["Add remote address",
               "Add files",
               "Commit files",
               "Push files to branch",
               "Show git status",
               "Show git logs",
               "Show the last commit",
               "Remove a file",
               "Show diff",
               "Change branch",
               "Git pull changes",
               "Restore a file",
               "Reset to a commit",
               "Reset to the last commit",
               "Close"]

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
    when "Add remote address" then
      @opt.remote_adress
    when "Add files" then
      @opt.add_files
    when "Commit files" then
      @opt.commit_files
    when "Push files to branch" then
      @opt.push_branch
    when "Show git status" then
      @opt.status
    when "Show git logs" then
      @opt.logs
    when "Show diff" then
      @opt.diff
    when "Restore a file" then
      @opt.restore
    when "Reset to a commit" then
      @opt.reset
    when "Reset to the last commit" then
      @opt.hard_reset
    when "Change branch" then
      @opt.change_branch
    when "Remove a file" then
      @opt.remove_file
    when "Show the last commit" then
      @opt.show_last_commit
    when "Git pull changes" then
      @opt.pull_changes
    else
      abort("Goodbye, closed.")
    end
  end

  def g4t_start
    loop { show_panel }
  end
end

Application.new
