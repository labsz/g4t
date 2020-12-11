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
    run_command("git commit -m #{msg}")
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
    run_command(cmd)
  end

  def logs
    run_command("git log")
  end

  def push_branch
    branch = @prompt.ask("Branch to push:")
    run_command("git push origin #{branch}")
  end

  def remote_adress
    $lastmsg = "Now that we the remote address"
    uname = @prompt.ask("Your github username:")
    repo = @prompt.ask("Your repository name:")
    puts("Adding remote repository https://github.com/#{uname}/#{repo}...")
    run_command("git remote add origin https://github.com/#{uname}/#{repo}.git")
  end

  def status
    run_command("git status")
  end

  def clone_repo
    uname = @prompt.ask("Username:")
    repo = @prompt.ask("Repository name:")
    run_command("git clone https://github.com/#{uname}/#{repo}/")
  end

  def restore
    fname = @prompt.ask("File name:")
    run_command("git restore #{fname}")
  end

  def reset
    commit = @prompt.ask("Commit id:")
    run_command("git reset --hard #{commit}")
  end

  def hard_reset
    confirmation = @prompt.yes?("do you really want to hard reset?")

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
    bname = @prompt.ask("Branch name:")
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
    file_name = @prompt.ask("Enter the file name: ")
    run_command("git rm #{file_name}")
  end

  def show_last_commit
    run_command("git show")
  end

  def pull_changes
    git_pull_options = ["rebase", "no-rebase", "ff-only"]
    chose = @prompt.select("chose: ", git_pull_options)
    run_command("git pull --#{chose}")
  end

  def run_command(cmd)
    puts "Command: #{cmd}"
    system(cmd)
  end
end
