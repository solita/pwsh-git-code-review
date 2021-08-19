# pwsh-git-code-review

Tool and examples about how to make code reviews with git without pull requests

## Requirements

Tool was created and tested with **[PowerShell](https://aka.ms/powershell-release?tag=stable)** version 7.1.4 (the one on top of .NET Core / .NET 5).

Tool expects you to have **[Meld](https://meldmerge.org/)** installed as a difftool in your git global config `git config --global -e`. It should look something like below.

Windows:

```gitconfig
[difftool "meld"]
    path = C:/Program Files (x86)/Meld/Meld.exe
    cmd = 'C:/Program Files (x86)/Meld/Meld.exe' $LOCAL $BASE $REMOTE --output=$MERGED
```

Mac/Linux:

Sorry, try to google! In Mac/Linux you might need to also chmod +x the .githooks/commit-msg file and in worst case make dos2unix bit conversion for the file.
