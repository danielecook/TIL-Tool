# TIL

A simple tool for creating and indexing TILs (Today I Learned) from the command line. See an example of what it outputs [here](https://www.github.com/danielecook/til-dec).

## Quick Start


1. Download a `til` binary from releases and put it on your `PATH`
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

This will open a new document using the text editor set using `$EDITOR`. The document has a header which is where you can write a more thorough description.

```markdown
# syntactic sugar for modifying items in a list

...
```

On first use `til` creates a folder at `~/.til` and initiates a git repo. You can [add a remote](https://help.github.com/en/github/importing-your-projects-to-github/adding-an-existing-project-to-github-using-the-command-line) to push TILs to GitHub or other GIT services.

TILs are saved to `~/.til/<topic>/<title>`, and a README index is regenerated on every run. Then all changes are committed automatically.

### `ls`

Use `ls` to list all TILs and details, or `ls <query>` to search TILs from the command line.

### `push`

Use `til push` to push TILs to the default remote.

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
