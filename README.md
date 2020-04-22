# TIL Tool

A simple tool for creating and indexing TILs (Today I Learned) from the command line.  The idea is to make it quick and easy to add a TIL without interrupting your workflow very much.

### [Example TIL Repo](https://www.github.com/danielecook/til)

## Quick Start

1. Download a [`til` binary](https://github.com/danielecook/TIL/releases) from the latest release and add it to your `PATH`
2. Run `til`. On first run it will create the `~/.til` directory and initialize a git repo
3. Create your first TIL by running `til open topic/title`
4. Create a new, empty repo on [github](https://www.github.com), [gitlab](https://www.gitlab.com), [sourcehut](https://sourcehut.org/), etc.
5. Run `til push --remote https://github.com/username/today-i-learned.git`, with the proper URL for your repo

## Usage

### `open`

Open a TIL by specifying the `<topic>/<title>`

```shell
til open Python/list_comprehensions
```

This will open a new document using the text editor set using `$EDITOR`. The document has a header which acts as a more thorough description than the title/filename:

```markdown
# syntactic sugar for modifying items in a list

...
```

On first use `til` creates a folder at `~/.til` and initiates a git repo. See [Adding a remote](#Adding-a-remote) for details on how to push TILs to GitHub or other GIT services.

TILs are saved to `~/.til/<topic>/<title>`. Once you close the document, a `README.md` is regenerated.

### `ls`

Use `ls` to list all TILs and details, or `ls <query>` to search TILs from the command line.

### `push`

Use `til push` to add TILs, commit, and to your remote repo. The `README.md` is regenerated prior to any files being pushed.

#### Adding a remote

When adding a remote, you should use a new remote repo. You can add or update the remote by using the push command with the `--remote` option. You only need to do this one time.

```bash
til push --remote https://github.com/username/today-i-learned.git
```

Alternatively, you can configure a remote manually. The code below is very similar to what the `--remote` option does.

```bash
# Change to the TIL directory
cd ~/.til
remote_url=https://github.com/username/today-i-learned.git
git remote remove origin || true
git remote add origin "${remote_url}"
git remote set-url --push origin "${remote_url}"
git push --set-upstream origin master
```

## Setting the `$EDITOR`

You can configure which editor to use by setting the `$EDITOR` variable. For example:

```bash
EDITOR=nano til open python/list_comprehensions
```

Alternatively, you can stick this in your `.bash_profile`:

```bash
export EDITOR=nano
```

`til` should work wil almost any program, but you must be able to open a file by specifying it as an argument.

Editors that work well:

* sublime text (specify using `subl`, and ensure that the shell commands are installed)
* atom (install shell commands
* vscode (install shell commands)
* vim/vi
* emacs
* nano

# Conributing

Please feel free to submit issues for bugs and suggestions.
