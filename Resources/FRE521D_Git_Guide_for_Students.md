# FRE 521D - Working with the Course Repository

## A Complete Guide to Git for Our Course

**Course:** FRE 521D - Data Analytics in Climate, Food and Environment  
**Term:** Winter 2026  
**Instructor:** Asif Ahmed Neloy

---

## Before We Begin: Why Are We Using Git?

Throughout this course, I'll be pushing lecture notes, lab files, assignments, and datasets to our course repository. Rather than downloading ZIP files every class or checking Canvas for updates, Git allows you to:

1. **Get all course materials with one command** - No more hunting for files
2. **Stay synchronized** - When I update a lecture or fix a typo, you get the changes instantly
3. **Never lose your work** - Git tracks everything, so you can always recover
4. **Learn an industry-standard tool** - Every data science team uses version control

Think of Git as a "smart folder" that knows how to talk to the internet and merge changes from multiple people. Our GitHub repository is the "master copy" in the cloud, and your computer will have a local copy that stays in sync.

---

## Part 1: Setting Up Your Computer (One-Time Setup)

Before you can use Git, you need to install it. This is a one-time process.

---

### For Windows Users

Windows doesn't come with Git, so we need to install it along with a proper terminal.

**Step 1: Download Git**

Go to https://git-scm.com/download/win

Your browser should automatically start downloading the installer. If not, click the download link.

**Step 2: Run the Installer**

Double-click the downloaded file (it will be named something like `Git-2.43.0-64-bit.exe`).

During installation, you'll see many screens with options. For most of them, **just click "Next" to accept the defaults**. However, pay attention to these:

- **"Choosing the default editor"** - Select "Use Visual Studio Code as Git's default editor" if you have VS Code installed. Otherwise, keep the default (Vim) or choose Notepad.
  
- **"Adjusting your PATH environment"** - Select "Git from the command line and also from 3rd-party software" (this is usually the default and what you want)

- **"Choosing HTTPS transport backend"** - Keep "Use the OpenSSL library"

- **"Configuring the line ending conversions"** - Keep "Checkout Windows-style, commit Unix-style line endings"

Click "Install" and wait for it to finish.

**Step 3: Open Git Bash**

After installation, you'll have a new program called **Git Bash**. This is a terminal (command-line interface) that lets you run Git commands.

To open it:
- Press the Windows key
- Type "Git Bash"
- Click on "Git Bash" to open it

You should see a black window with text that looks something like:
```
YourName@YourComputer MINGW64 ~
$
```

This is your command line. The `$` is where you type commands.

**Step 4: Verify Git is Installed**

In Git Bash, type this command and press Enter:

```bash
git --version
```

You should see output like:
```
git version 2.43.0.windows.1
```

If you see a version number, Git is installed correctly!

---

### For Mac Users

Good news - Mac makes this easier because it has a built-in terminal.

**Step 1: Open Terminal**

There are several ways to open Terminal:
- Press `Cmd + Space` to open Spotlight, type "Terminal", and press Enter
- Or go to Applications → Utilities → Terminal

You should see a window with text ending in `$` or `%`.

**Step 2: Check if Git is Already Installed**

Many Macs come with Git pre-installed. Let's check:

```bash
git --version
```

If you see a version number like `git version 2.39.0`, you're all set! Skip to Step 4.

If you see a popup asking to install "command line developer tools", click "Install" and wait. This will install Git for you.

If you get "command not found", continue to Step 3.

**Step 3: Install Git (if needed)**

The easiest way is using Homebrew (a package manager for Mac). First, install Homebrew by pasting this entire line into Terminal:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Press Enter and follow the prompts. You may need to enter your Mac password (you won't see characters as you type - this is normal for security).

After Homebrew is installed, install Git:

```bash
brew install git
```

**Step 4: Verify Installation**

```bash
git --version
```

You should see a version number. 

---

### Configuring Git (Both Mac and Windows)

Now we need to tell Git who you are. This information gets attached to any changes you make (though for this course, you won't be pushing changes back to my repository).

Open your terminal (Git Bash on Windows, Terminal on Mac) and run these two commands, **replacing the placeholder text with your actual name and email**:

```bash
git config --global user.name "Your Full Name"
```

Press Enter, then:

```bash
git config --global user.email "your.email@student.ubc.ca"
```

**What does this do?**

The `git config` command changes Git's settings. The `--global` flag means this applies to all Git projects on your computer (not just one). We're setting two pieces of information:
- `user.name` - Your name (will appear in commit history)
- `user.email` - Your email (used to identify you)

**Verify your configuration:**

```bash
git config --list
```

You should see your name and email in the output.

---

## Part 2: Getting the Course Repository (Cloning)

Now for the exciting part - downloading the course materials!

---

### Understanding What We're About to Do

When you "clone" a repository, you're creating a complete copy of it on your computer. This isn't just downloading files - you're getting the entire history of the project, all branches, and establishing a connection to the original repository so you can pull updates later.

Think of it like this:
- **Downloading a ZIP** = Getting a snapshot of files (no connection to source)
- **Cloning a repository** = Getting files + history + live connection for updates

---

### Step 1: Decide Where to Store the Course Folder

First, let's navigate to where you want to keep your course materials. I recommend creating a dedicated folder for your MFRE courses.

**On Windows (Git Bash):**

```bash
cd /c/Users/$USER/Documents
```

Let me explain this command:
- `cd` stands for "change directory" - it moves you to a different folder
- `/c/Users/$USER/Documents` is the path to your Documents folder
- `$USER` automatically becomes your Windows username

Now create a folder for your courses:

```bash
mkdir MFRE_Courses
```

The `mkdir` command means "make directory" - it creates a new folder.

Move into that folder:

```bash
cd MFRE_Courses
```

**On Mac (Terminal):**

```bash
cd ~/Documents
```

The `~` symbol is a shortcut that means "my home folder", so `~/Documents` means "the Documents folder in my home folder".

Create and enter a courses folder:

```bash
mkdir MFRE_Courses
cd MFRE_Courses
```

---

### Step 2: Clone the Repository

Now we'll clone the course repository. Run this command:

```bash
git clone https://github.com/aaneloy/FRE521D-Winter2026-UBC.git
```

**What's happening here?**

- `git clone` is the command to copy a repository
- The URL points to our course repository on GitHub
- Git will create a new folder with the repository name and download everything into it

You'll see output like:
```
Cloning into 'FRE521D-Winter2026-UBC'...
remote: Enumerating objects: 156, done.
remote: Counting objects: 100% (156/156), done.
remote: Compressing objects: 100% (98/98), done.
remote: Total 156 (delta 45), reused 142 (delta 35), pack-reused 0
Receiving objects: 100% (156/156), 2.45 MiB | 5.23 MiB/s, done.
Resolving deltas: 100% (45/45), done.
```

This means Git is:
1. Connecting to GitHub
2. Counting all the files and their history
3. Compressing the data for transfer
4. Downloading everything
5. Unpacking it on your computer

---

### Step 3: Enter the Repository Folder

```bash
cd FRE521D-Winter2026-UBC
```

Now you're inside the course folder!

---

### Step 4: Explore What You Have

Let's see what's inside:

```bash
ls
```

The `ls` command "lists" the contents of the current folder. On Windows Git Bash and Mac, you'll see the files and folders in our repository.

For more detail, try:

```bash
ls -la
```

The `-la` flags mean:
- `-l` = "long format" (show details like file sizes and dates)
- `-a` = "all files" (including hidden files that start with `.`)

You'll notice a `.git` folder - this is where Git stores all the version history and configuration. **Never delete or modify this folder!**

---

### Step 5: Check the Repository Status

```bash
git status
```

This is one of the most useful Git commands. It tells you:
- Which branch you're on
- Whether you have any changes
- Whether you're in sync with the remote repository

You should see:
```
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

This means:
- You're on the `main` branch (the primary version of the code)
- Your local copy matches what's on GitHub (`origin/main`)
- You haven't made any changes yet

---

## Part 3: The Golden Rule - Keep Your Work Separate

This is the most important concept in this guide.

---

### The Problem

Here's a scenario that causes headaches:

1. I give you `Lab_03.ipynb`
2. You open it and start working, adding your solutions
3. I realize there was a typo and push a fix
4. You try to get my update with `git pull`
5. **CONFLICT!** Git doesn't know whether to keep your version or my version

This creates a "merge conflict" that can be confusing to resolve.

---

### The Solution: Your Personal Work Folder

We're going to create a simple system: **never modify my files directly**. Instead:

1. Create a `my_work` folder for all your personal work
2. When you need to work on something, **copy** it to `my_work` first
3. Work on your copy
4. My files stay untouched, so updates always work smoothly

---

### Setting Up Your Work Folder

Make sure you're in the repository folder:

```bash
cd ~/Documents/MFRE_Courses/FRE521D-Winter2026-UBC
```

(On Windows, use `/c/Users/$USER/Documents/MFRE_Courses/FRE521D-Winter2026-UBC`)

Create your personal folder structure:

```bash
mkdir my_work
mkdir my_work/labs
mkdir my_work/assignments
mkdir my_work/notes
mkdir my_work/practice
```

Or do it all in one command:

```bash
mkdir -p my_work/{labs,assignments,notes,practice}
```

The `-p` flag means "create parent directories if they don't exist" and the `{a,b,c}` syntax creates multiple folders at once.

---

### Tell Git to Ignore Your Work Folder

We'll add your `my_work` folder to a special file called `.gitignore`. This tells Git to completely ignore that folder - it won't track changes, won't complain about it, and won't try to merge it.

```bash
echo "my_work/" >> .gitignore
```

Let me break this down:
- `echo "my_work/"` - This outputs the text "my_work/"
- `>>` - This "appends" (adds to the end of) a file
- `.gitignore` - This is the file we're adding to

Now check what's in the .gitignore file:

```bash
cat .gitignore
```

The `cat` command displays the contents of a file. You should see `my_work/` listed.

---

### Your Repository Should Now Look Like This

```
FRE521D-Winter2026-UBC/
│
├── .git/                    ← Git's internal folder (don't touch!)
├── .gitignore               ← List of files Git should ignore
│
├── Lectures/                ← My lecture materials
│   ├── Lecture_01.ipynb
│   ├── Lecture_02.ipynb
│   └── ...
│
├── Labs/                    ← My lab files
│   ├── Lab_01.ipynb
│   ├── Lab_02.ipynb
│   └── ...
│
├── Assignments/             ← My assignment files
│   └── ...
│
├── Data/                    ← Datasets we'll use
│   └── ...
│
├── my_work/                 ← YOUR PERSONAL FOLDER (Git ignores this!)
│   ├── labs/               ← Your lab solutions go here
│   ├── assignments/        ← Your assignment solutions go here
│   ├── notes/              ← Your personal notes
│   └── practice/           ← Your practice code
│
└── README.md
```

The key insight: **Everything in `my_work/` is yours. Everything else is mine. Never the two shall mix.**

---

## Part 4: Your Daily Workflow

Here's what you'll do regularly throughout the course.

---

### Starting Your Work Session

Every time you sit down to work on course materials, start by getting the latest updates:

**Step 1: Open your terminal**

- Windows: Open Git Bash
- Mac: Open Terminal

**Step 2: Navigate to the course folder**

```bash
cd ~/Documents/MFRE_Courses/FRE521D-Winter2026-UBC
```

(Adjust the path based on where you cloned the repository)

**Pro tip:** You can drag a folder onto the terminal window to paste its path, or use Tab to autocomplete folder names.

**Step 3: Pull the latest updates**

```bash
git pull origin main
```

Let's understand this command:
- `git pull` = Download changes and merge them into your local copy
- `origin` = The nickname for the GitHub repository (set up automatically when you cloned)
- `main` = The branch you want to pull from

You'll see one of two things:

**If there are updates:**
```
remote: Enumerating objects: 5, done.
remote: Counting objects: 100% (5/5), done.
remote: Compressing objects: 100% (3/3), done.
remote: Total 3 (delta 2), reused 0 (delta 0), pack-reused 0
Unpacking objects: 100% (3/3), done.
From https://github.com/aaneloy/FRE521D-Winter2026-UBC
   a1b2c3d..e4f5g6h  main       -> origin/main
Updating a1b2c3d..e4f5g6h
Fast-forward
 Lectures/Lecture_05.ipynb | 234 ++++++++++++++++++++++++
 1 file changed, 234 insertions(+)
 create mode 100644 Lectures/Lecture_05.ipynb
```

This tells you a new file `Lecture_05.ipynb` was added!

**If you're already up to date:**
```
Already up to date.
```

This means you have all the latest files.

---

### Working on a Lab or Assignment

Let's say I just released Lab 3 and you want to work on it.

**Step 1: First, make sure you have the latest version**

```bash
git pull origin main
```

**Step 2: Copy the file to your work folder**

```bash
cp Labs/Lab_03.ipynb my_work/labs/Lab_03_solution.ipynb
```

The `cp` command means "copy". The syntax is `cp source destination`.

I recommend adding something to the filename (like `_solution` or your initials) so you can tell your version apart from the original.

**Step 3: Open and work on YOUR copy**

Open `my_work/labs/Lab_03_solution.ipynb` in Jupyter Notebook or VS Code. Work on it, save your changes, take breaks - whatever you need.

**Step 4: Your work is safe!**

Because you're working in `my_work/`, which Git ignores:
- Your changes won't conflict with my updates
- You can `git pull` anytime without worry
- Your solutions stay exactly where you put them

---

### End of Session: Verify Everything is Good

Before you close everything, it's good practice to check the status:

```bash
git status
```

If you followed the workflow correctly, you should see:
```
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

Even though you created files in `my_work/`, Git doesn't mention them because of our `.gitignore` rule.

---

## Part 5: What If I Already Modified Your Files?

Don't panic! This happens to everyone. Here's how to fix it.

---

### Scenario 1: You Modified Files But Haven't Done Anything Else

Let's say you accidentally edited `Labs/Lab_02.ipynb` directly instead of making a copy first.

**First, see what you changed:**

```bash
git status
```

You'll see something like:
```
On branch main
Your branch is up to date with 'origin/main'.

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   Labs/Lab_02.ipynb

no changes added to commit (use "git add" and/or "git commit -a")
```

**Step 1: Save your work first!**

Before doing anything, let's save your changes to your work folder:

```bash
cp Labs/Lab_02.ipynb my_work/labs/Lab_02_my_work.ipynb
```

**Step 2: Discard changes to the original file**

Now we'll tell Git to restore the original version:

```bash
git restore Labs/Lab_02.ipynb
```

The `git restore` command throws away your changes to that file and reverts it to the last committed version.

**Step 3: Verify the file is restored**

```bash
git status
```

You should see "working tree clean" again.

**Step 4: Your work is safe in `my_work/`**

You can continue working on `my_work/labs/Lab_02_my_work.ipynb`. The original is back to normal.

---

### Scenario 2: You Modified Files and Now `git pull` Fails

You try to pull updates and see:

```
error: Your local changes to the following files would be overwritten by merge:
        Labs/Lab_02.ipynb
Please commit your changes or stash them before you merge.
Aborting
```

Git is protecting you! It won't overwrite your changes without your permission.

**Option A: Save your work and discard changes (Recommended)**

```bash
# Save your work first
cp Labs/Lab_02.ipynb my_work/labs/Lab_02_backup.ipynb

# Discard changes to the original
git restore Labs/Lab_02.ipynb

# Now pull will work
git pull origin main
```

**Option B: Use Git Stash (Temporary Storage)**

Git has a feature called "stash" that temporarily saves your changes:

```bash
# Stash (hide) your changes
git stash
```

Your changes are now saved in a temporary location, and your files are clean.

```bash
# Pull the updates
git pull origin main
```

Now you can either:

```bash
# Bring back your changes (may cause conflicts)
git stash pop
```

Or just leave them stashed and copy them out:

```bash
# See what's in your stash
git stash show -p
```

This shows you what changes are stashed. You can manually copy what you need to your `my_work/` folder.

To clear the stash when you're done:

```bash
git stash drop
```

---

### Scenario 3: Total Chaos - The Nuclear Option

If things are really messed up and you just want to start fresh:

**WARNING: This will DELETE all local changes! Make sure you've saved any work you want to keep somewhere else (like copying files to your Desktop).**

```bash
# Throw away ALL local changes and match the remote exactly
git fetch origin
git reset --hard origin/main
```

What these commands do:
- `git fetch origin` - Downloads the latest info from GitHub (but doesn't change your files yet)
- `git reset --hard origin/main` - Forces your local files to exactly match what's on GitHub

After this, your repository is a fresh clone of the course materials.

---

## Part 6: Understanding What's Happening (For the Curious)

You don't need to read this section to use Git, but it helps to understand what's going on.

---

### How Git Tracks Changes

Git doesn't store complete copies of every version of every file. Instead, it stores:

1. **Snapshots** - Each "commit" is a snapshot of all your files at that moment
2. **Differences** - Git calculates what changed between snapshots

When you do `git pull`, Git:
1. Downloads new commits from GitHub
2. Looks at what changed
3. Applies those changes to your files
4. If you changed the same lines I changed, it asks for help (merge conflict)

---

### The Three States of Git Files

Files in a Git repository can be in three states:

1. **Committed** - The file is safely stored in Git's database
2. **Modified** - You've changed the file but haven't told Git yet
3. **Staged** - You've marked a modified file to be included in the next commit

For this course, you won't be committing or staging - you're just pulling my changes. But this explains the terminology you might see.

---

### What is "origin"?

When you cloned the repository, Git automatically created a "remote" called `origin`. This is just a nickname for the GitHub URL.

You can see your remotes:

```bash
git remote -v
```

Output:
```
origin  https://github.com/aaneloy/FRE521D-Winter2026-UBC.git (fetch)
origin  https://github.com/aaneloy/FRE521D-Winter2026-UBC.git (push)
```

So when you say `git pull origin main`, you're saying "pull from the remote called 'origin', specifically the 'main' branch."

---

### What is a Branch?

Think of branches as parallel versions of the project. The `main` branch is the primary version. Developers use other branches to work on features without affecting `main`.

For this course, we only use `main`, so don't worry about branches.

---

## Part 7: Quick Reference Card

Print this out or save it for quick access!

---

### Commands You'll Use Often

| What You Want to Do | Command |
|---------------------|---------|
| Go to course folder | `cd ~/Documents/MFRE_Courses/FRE521D-Winter2026-UBC` |
| Get latest updates | `git pull origin main` |
| See what's changed | `git status` |
| Copy a file to work on | `cp Labs/Lab_03.ipynb my_work/labs/Lab_03_solution.ipynb` |
| Undo changes to a file | `git restore filename` |
| List files in folder | `ls` or `ls -la` |

---

### The Daily Workflow (3 Commands)

```bash
# 1. Go to the course folder
cd ~/Documents/MFRE_Courses/FRE521D-Winter2026-UBC

# 2. Get the latest updates
git pull origin main

# 3. Copy the file you need to work on
cp Labs/Lab_XX.ipynb my_work/labs/Lab_XX_solution.ipynb
```

Then open your copy in `my_work/` and start working!

---

### If You Accidentally Modified My Files

```bash
# Save your work first!
cp Labs/Lab_XX.ipynb my_work/labs/Lab_XX_backup.ipynb

# Restore the original
git restore Labs/Lab_XX.ipynb

# Now you can pull updates
git pull origin main
```

---

### Useful Navigation Commands

| Command | What It Does | Example |
|---------|--------------|---------|
| `cd foldername` | Enter a folder | `cd Labs` |
| `cd ..` | Go up one folder | `cd ..` |
| `cd ~` | Go to home folder | `cd ~` |
| `pwd` | Print current location | `pwd` |
| `ls` | List folder contents | `ls` |
| `mkdir name` | Create a folder | `mkdir notes` |
| `cp source dest` | Copy a file | `cp file.txt copy.txt` |
| `mv source dest` | Move/rename a file | `mv old.txt new.txt` |

---

## Part 8: Getting Help

### Common Error Messages and Solutions

**"fatal: not a git repository"**

You're not in a Git folder. Navigate to the course repository:
```bash
cd ~/Documents/MFRE_Courses/FRE521D-Winter2026-UBC
```

**"Your local changes would be overwritten by merge"**

You modified a file that I also updated. See Scenario 2 in Part 5.

**"Permission denied"**

On Mac, you might need to use `sudo` (administrator mode) for some operations. But for this course, you shouldn't need it. If you see this, double-check you're in the right folder.

**"Connection refused" or "Could not resolve host"**

Check your internet connection. GitHub might also be down (rare) - check status.github.com.

---

### Resources

- **Git Documentation:** https://git-scm.com/doc (comprehensive but technical)
- **GitHub Guides:** https://guides.github.com/ (beginner-friendly tutorials)
- **Oh Shit, Git!?!:** https://ohshitgit.com/ (solutions for common mistakes, with some colorful language)

---

### Still Stuck?

1. **Google the error message** - Someone has probably had the same problem
2. **Ask on our course discussion board** - Your classmates might know the answer
3. **Come to office hours** - I'm happy to help troubleshoot

---

## Final Thoughts

Git might feel complicated at first, but the workflow for this course is actually simple:

1. **Pull before you start working** → `git pull origin main`
2. **Copy files to your `my_work/` folder before editing**
3. **Work on your copies, leave my files alone**

If you follow these three rules, you'll never have conflicts, and you'll always have the latest course materials.

Welcome to FRE 521D, and happy coding!

---

*Last updated: January 2026*
