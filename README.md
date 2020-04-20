# TIL

A very simple tool for creating and indexing TILs (Today I Learned)

## Usage

### `open`

Open a TIL by specifying the `<topic>/<title>`

```shell
til open Python/list_comprehensions
```

This will open a new document using the text editor set using `$EDITOR`. The document has a header which is where you can write a more thorough description.

```
# my new til
```

On first usage `til` creates a folder at `~/.til` and initiates a git repo. You can [add a remote](https://help.github.com/en/github/importing-your-projects-to-github/adding-an-existing-project-to-github-using-the-command-line) to push TILs to GitHub or other GIT services.

TILs are saved to `~/.til/<topic>/<title>`, and a README index is regenerated on every run. Then all changes are committed automatically.

### `ls`

Use `ls` to list all TILs and details, or `ls <query>` to search TILs from the command line.

### `push`

Use `til push` to push TILs to the default remote.

## Installation


