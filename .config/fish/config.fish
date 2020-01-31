# Minimal Version Check
if test (string split "." "$FISH_VERSION" | string split "-")[1] -lt 3
  echo "fish 3.0 or newer is required"
  exit 1
end

# Bootstrap Fisher
if not functions -q fisher
  set -q XDG_CONFIG_HOME; or set XDG_CONFIG_HOME ~/.config
  curl https://git.io/fisher --create-dirs -sLo $XDG_CONFIG_HOME/fish/functions/fisher.fish
  fish -c fisher
end

# PATH
function _pathadd --argument dir
  if test -d $dir
    set -gx PATH $dir $PATH
  end
end

_pathadd ~/.cabal/bin
_pathadd ~/.cargo/bin
_pathadd ~/.local/bin
_pathadd ~/bin

# EDITOR, PAGER
set -xU EDITOR emacsclient -t -a vim
set -xU PAGER less
set -xU LESS -RSi
set -xU LESS_TERMCAP_mb (printf "\e[01;31m")
set -xU LESS_TERMCAP_md (printf "\e[01;35m")
set -xU LESS_TERMCAP_me (printf "\e[0m")
set -xU LESS_TERMCAP_so (printf "\e[0;30;103m")
set -xU LESS_TERMCAP_se (printf "\e[0m")
set -xU LESS_TERMCAP_us (printf "\e[04;32m")
set -xU LESS_TERMCAP_ue (printf "\e[0m")

# aliases
if status --is-interactive
  abbr -ga -- - 'cd -'
  abbr -ga ... '../..'
  abbr -ga .... '../../..'
  abbr -ga ..... '../../../..'
  abbr -ga d cdh
  abbr -ga g git
  abbr -ga l la
  abbr -ga v vim
end

# fzf
set -U FZF_LEGACY_KEYBINDINGS 0

set -xga FZF_DEFAULT_OPTS '--reverse --color=light'

# z
set -U Z_CMD j
