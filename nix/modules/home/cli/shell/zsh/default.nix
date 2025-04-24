{
  config,
  lib,
  inputs,
  ...
}:
with lib; let
  cfg = config.swarm.cli;
in {
  config = mkIf (cfg.shell == "zsh") {
    home.shell.enableZshIntegration = true;
    programs.zsh = {
      enable = true;
      autocd = true;
      enableCompletion = true;
      dirHashes = {
        n = "/home/${swarm.user}/swarm.flake";
        balatroAppData = "/home/${swarm.user}/.steam/steam/steamapps/compatdata/2379780/pfx/drive_c/users/steamuser/AppData/Roaming/Balatro";
      };
      history = {
        append = true;
        extended = true;
        ignoreAllDups = true;
        save = 1000000000;
        size = 1000000000;
      };
      historySubstringSearch.enable = true;
      syntaxHighlighting = {
        enable = true;
        highlighters = [
          "brackets"
          "root"
          "cursor"
          "pattern"
        ];
        patterns = {
          "rm -rf *" = "fg=white,bold,bg=red";
        };
      };
      autosuggestion = {
        enable = true;
        strategy = [
          "history"
          "completion"
        ];
      };

      plugins = [
        {
          name = "zsh-completions";
          src = inputs.zsh-completions;
        }
        {
          name = "zsh-colored-man-pages";
          src = inputs.zsh-colored-man-pages;
        }
        #{
        #  name = "zsh-autocomplete";
        #  src = inputs.zsh-autocomplete;
        #}
        {
          name = "zsh-dotnet-completion ";
          src = inputs.zsh-dotnet-completion;
        }
        {
          name = "zsh-better-npm-completion";
          src = inputs.zsh-better-npm-completion;
        }
        {
          name = "powerlevel10k";
          file = "powerlevel10k.zsh-theme";
          src = inputs.powerlevel10k;
        }
      ];
      sessionVariables = {
        WORDCHARS = "\${WORDCHARS//\/}";
      };
      shellAliases = {
        ssh = "kitty +kitten ssh";
        ls = "ls --color=auto";
        dcmd = "nix develop --command";
      };
      initExtraFirst = ''
        function source_if_exists { [[ -r $1 ]] && source $1 }
        # Start up p10k instant prompt so we don't feel the shell startup lag and can start typing instantly
        # Quiet since direnv may output during the instant prompt
        typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
        source_if_exists ''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${USERNAME}.zsh

        setopt magicequalsubst
        setopt nonomatch
        setopt numericglobsort
        setopt promptsubst
        setopt incappendhistory

        ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(buffer-empty bracketed-paste accept-line push-line-or-edit)
        ZSH_AUTOSUGGEST_USE_ASYNC=true
      '';

      initExtra = ''
        bindkey "$terminfo[kcuu1]" history-substring-search-up
        bindkey "$terminfo[kcud1]" history-substring-search-down

        bindkey -M vicmd 'k' history-substring-search-up
        bindkey -M vicmd 'j' history-substring-search-down

        source ${./.p10k.zsh}
      '';

      envExtra = ''
        export EDITOR=nvim
        export VISUAL=nvim
        export KUBE_EDITOR=nvim
        export AWS_SDK_LOAD_CONFIG=1
        export HOMEBREW_NO_ANALYTICS=1
        export PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools:~/code/kitty/kitty/launcher:~/.local/bin:./.fnm
      '';
      profileExtra = mkIf config.swarm.desktop.hyprland.enable ''
        if uwsm check may-start && uwsm select; then
          exec uwsm start default
        fi
      '';
    };
  };
}
