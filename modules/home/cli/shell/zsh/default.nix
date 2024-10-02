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
    programs.zsh = {
      enable = true;
      autocd = true;
      enableCompletion = true;
      dirHashes = {
        n = "/home/${swarm.user}/swarm.flake";
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
        kssh = "kitty +kitty ssh";
        ls = "ls --color=auto";
        dcmd = "nix develop --command";
      };
      initExtraFirst = ''
        function source_if_exists { [[ -r $1 ]] && source $1 }
        # Start up p10k instant prompt so we don't feel the shell startup lag and can start typing instantly
        source_if_exists ''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${USERNAME}.zsh

        setopt magicequalsubst
        setopt nonomatch
        setopt numericglobsort
        setopt promptsubst
        setopt incappendhistory
        setopt EXTENDED_HISTORY

        ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(buffer-empty bracketed-paste accept-line push-line-or-edit)
        ZSH_AUTOSUGGEST_USE_ASYNC=true
      '';

      initExtra = ''
        source_if_exists ~/.p10k.zsh
      '';

      envExtra = ''
        export EDITOR=nvim
        export VISUAL=nvim
        export KUBE_EDITOR=nvim
        export AWS_SDK_LOAD_CONFIG=1
        export HOMEBREW_NO_ANALYTICS=1
        export PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools:~/code/kitty/kitty/launcher:~/.local/bin:./.fnm
      '';

      # If we're using hyprland, make the first tty autostart on login
      profileExtra = mkIf config.swarm.desktop.hyprland.enable ''
        [[ -f ~/.zshrc ]] && . ~/.zshrc

        if [[ -z $DISPLAY ]] && [[ $(tty) == "/dev/tty1" ]]; then
          exec Hyprland
        fi
      '';
    };
  };
}
