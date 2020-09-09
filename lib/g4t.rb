#!/usr/bin/env ruby
# frozen_string_literal: true
require "os"
require "tty-prompt"
require "etc"

module G4t
  class Options
    def initialize
      $prompt = TTY::Prompt.new
    end
    def commit_files
      $lastmsg = "Now that we commited the files"
      msg = $prompt.ask("Commit message:")

      if msg[0] != "\""
        msg = "\"#{msg}"
      end

      if msg[-1] != "\""
        msg = "#{msg}\""
      end

      puts msg
      run_command("git commit -m #{msg}")
    end

    def add_files
      $lastmsg = "Now that we added the files"
      all_files = $prompt.yes?("Add all files?")
      if all_files
        cmd = "git add ."
        puts("Adding all files...")
      else
        fname = $prompt.ask("File to add:")
        cmd = "git add #{fname}"
      end
      run_command(cmd)
    end

    def logs
      run_command("git log")
    end

    def push_branch
      branch = $prompt.ask("Branch to push:")
      run_command("git push origin #{branch}")
    end

    def remote_adress
      $lastmsg = "Now that we the remote address"
      uname = $prompt.ask("Your github username:")
      repo = $prompt.ask("Your repository name:")
      puts("Adding remote repository https://github.com/#{uname}/#{repo}...")
      run_command("git remote add origin https://github.com/#{uname}/#{repo}.git")
    end

    def status
      run_command("git status")
    end

    def clone_repo
      uname = $prompt.ask("Username:")
      repo = $prompt.ask("Repository name:")
      run_command("git clone https://github.com/#{uname}/#{repo}/")
    end

    def restore
      fname = $prompt.ask("File name:")
      run_command("git restore #{fname}")
    end

    def reset
      commit = $prompt.ask("Commit id:")
      run_command("git reset --hard #{commit}")
    end

    def hard_reset
      confirmation = $prompt.yes?("do you really want to hard reset?")

      if confirmation
        run_command("git reset --hard HEAD~")
      else
        puts "Cancelling operation"
      end

    end

    def initialize_git
      $lastmsg = "Now that we initialized .git"
      puts("Initializing Git repository in '#{Dir.pwd}/.git'...")
      run_command("git init")
    end

    def diff
      run_command("git diff")
    end

    def change_branch
      bname = $prompt.ask("Branch name:")
      run_command("git checkout -b #{bname}")
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
      file_name = $prompt.ask("Enter the file name: ")
      run_command("git rm #{file_name}")
    end

    def show_last_commit
      run_command("git show")
    end

    def pull_changes
      git_pull_options = ["rebase", "no-rebase", "ff-only"]
      chose = $prompt.select("chose: ", git_pull_options)
      run_command("git pull --#{chose}")
    end

    def run_command(cmd)
      puts "Command: #{cmd}"
      system(cmd)
    end
  end

  class Run
    def initialize
      @opt = Options.new
      git_init?
      start
    end

    def verify_system
      if OS.windows?; "C:\\Users\\#{Etc.getlogin}\\.gitconfig" else "/home/#{Etc.getlogin}/.gitconfig" end
    end
    def git_init?
      identify_user
      unless File.directory?(".git")
        begin
          options = ["Clone a repo", "Initialize a repo", "Close"]
          @git_init_select = $prompt.select("The .git directory was not found, what do you want to do?", options)
          git_init_verify
        rescue TTY::Reader::InputInterrupt
          abort("\nCloseed")
        end
      end
    end

    def git_init_verify
      case @giti_init_select
      when "Clone a repo"
        @opt.clone_repo
      when "Init a repo"
        @opt.init_repo
      else
        abort("It is not possible to continue without a .git repository or cloned repository!")
      end
    end

    def identify_user
      if(File.exist?(verify_system)) == false
        begin
          email = $prompt.ask("Github email: ")
          uname = $prompt.ask("Github username: ")
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
        "Close"
      ]

      begin
        @opt.git_info
        @opt_select = $prompt.select("Select: ", options)
        verify_option
      rescue TTY::Reader::InputInterrupt
        abort("\nYou has closed the application.")
      end
    end
    def verify_option
      case @opt_select
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

    def start
      loop { show_panel }
    end
  end

  Run.new
end
