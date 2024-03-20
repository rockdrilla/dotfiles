personal dotfiles

## repo URLs

- https://git.krd.sh/krd/dotfiles (main)
- https://github.com/rockdrilla/dotfiles (mirror)

## contents

- zsh
- gnu screen
- git
- vim (very naive)
- gdb (ditto)

files are stored in separate branch (`main`)

## installation

- install dotfiles (select preferred variant):
  - with `curl`:
    - default URI:

      ```sh
      curl -sSL https://dotfiles.krd.sh/get | sh -s
      ```

    - explicit fallback to Github:

      ```sh
      curl -sSL https://github.com/rockdrilla/dotfiles/raw/main/.config/dotfiles/install.sh | sh -s
      ```

  - with `wget`:
    - default URI:

      ```sh
      wget -q -O - https://dotfiles.krd.sh/get | sh -s
      ```

    - explicit fallback to Github:

      ```sh
      wget -q -O - https://github.com/rockdrilla/dotfiles/raw/main/.config/dotfiles/install.sh | sh -s
      ```

  - with `apt-helper` (very last-resort):
    - default URI:

      ```sh
      /usr/lib/apt/apt-helper download-file https://dotfiles.krd.sh/get "${HOME}/dotfiles.install.sh"
      sh "${HOME}/dotfiles.install.sh" ; rm -f "${HOME}/dotfiles.install.sh"
      ```

    - explicit fallback to Github:

      ```sh
      /usr/lib/apt/apt-helper download-file https://github.com/rockdrilla/dotfiles/raw/main/.config/dotfiles/install.sh "${HOME}/dotfiles.install.sh"
      sh "${HOME}/dotfiles.install.sh" ; rm -f "${HOME}/dotfiles.install.sh"
      ```

- switch shell to `zsh`:

  ```sh
  chsh -s /bin/zsh
  ```

## license

BSD 3-Clause
| [spdx.org](https://spdx.org/licenses/BSD-3-Clause.html)
| [opensource.org](https://opensource.org/licenses/BSD-3-Clause)
