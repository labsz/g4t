#!/usr/bin/env ruby
# frozen_string_literal: true

require 'tty-prompt'
require 'colorize'

$prompt = TTY::Prompt.new

def commit_msg
    msg = $prompt.ask("Enter the commit msg:")

    system("git commit -m #{msg}")
    system("git push origin")
end

def remote_add
    system("git remote add origin https://github.com/#{ARGV[0]}/#{ARGV[1]}")
    add_files
end

def add_files
    chose_btn = $prompt.yes?("Add all files:".magenta)

    case chose_btn
    when true
        system("git add .")
    else
        file_name = $prompt.ask("Enter the file name to add:")

        system("git add #{file_name}")
    end

    commit_msg
end

def verify
    if File.directory?(".git") == false
        chose_btn = $prompt.yes?("You forget to initialize the repository, you wanna initialize:".red)
        case chose_btn
        when true
            system("git init")
            remote_add
        else
            puts "Good Bye"
        end
    else
        add_files
    end
end

verify
