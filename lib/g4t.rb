#!/usr/bin/env ruby
# frozen_string_literal: true
require "os"
require "tty-prompt"

require_relative "g4tOptions"
require "etc"

module G4t
  class Core
    def initialize
      @opt = Options.new
      @prompt = TTY::Prompt.new
      start
    end

    def verify_system
      if OS.windows?
         "C:\\Users\\#{Etc.getlogin}\\.gitconfig" 
      else
        "/home/#{Etc.getlogin}/.gitconfig" 
      end
    end
    
    def git_init?
      unless File.directory?(".git")
        begin
          options = ["Clone a repo", "Initialize a repo", "Close"]
          userSelect = @prompt.select("The .git directory was not found, what do you want to do?", options)
          git_init_verify(userSelect)
        rescue TTY::Reader::InputInterrupt
          abort("\nCloseed")
        end
      end
    end

    def git_init_verify
      case @git_init_select
      when "Clone a repo"
        @opt.clone_repo
      when "Initialize a repo"
        @opt.initialize_git
      else
        abort("It is not possible to continue without a .git repository or cloned repository!")
      end
    end

    def identify_user
      if(File.exist?(verify_system)) == false
        begin
          email = @prompt.ask("Github email: ")
          uname = @prompt.ask("Github username: ")
          @opt.run_command("git config --global user.email #{email} && git config --global user.name #{uname}")
        rescue TTY::Reader::InputInterrupt
          abort("\nYou closed the application")
        end
      end
    end

    def show_panel
      options = [
        "Add remote address",
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
        Options.new.git_info
        opt_select = @prompt.select("Select: ", options)
        verify_option(opt_select)
      rescue TTY::Reader::InputInterrupt
        abort("\nYou has closed the application.")
      end
    end
    
    def verify_option(option)
      switch = {
        "Add remote address" => @opt.method(:remote_adress),
        "Add files" => @opt.method(:add_files),
        "Commit files" => @opt.method(:commit_files),
        "Push files to branch" => @opt.method(:push_branch),
        "Show git status" => @opt.method(:status),
        "Show git logs" => @opt.method(:logs),
        "Show diff" => @opt.method(:diff),
        "Restore a file" => @opt.method(:restore),
        "Reset to a commit" => @opt.method(:reset),
        "Reset to the last commit" => @opt.method(:hard_reset),
        "Change branch" => @opt.method(:change_branch),
        "Remove a file" => @opt.method(:remove_file),
        "Show the last commit" => @opt.method(:show_last_commit),
        "Git pull changes" => @opt.method(:pull_changes)
      }
    
      return switch[option].call
    end

    def start
      loop { show_panel }
    end
  end

  Core.new
end
