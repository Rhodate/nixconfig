{ pkgs, writeShellScriptBin, ...}: writeShellScriptBin "fk" ''
  set -euo pipefail
  windows=$(${pkgs.kitty}/bin/kitty @ ls | \
  ${pkgs.jq}/bin/jq -r '
    .[]
    | .id as $os_win_id
    | .tabs[] += { tab_len: (.tabs|length) }
    | .tabs[]
    | select(.is_focused == false)
    | .id as $tab_id
    | .title as $tab_title
    | .tab_len as $tab_len
    | .windows[] += { tab_id: $tab_id, tab_title: $tab_title, os_win_id: $os_win_id, win_len: (.windows|length), tab_len: $tab_len }
    | .windows[]
    | [.os_win_id, .tab_id, .id, .tab_len, .tab_title, .win_len, .title  ]
    | @tsv
    ' |\
  ${pkgs.gawk}/bin/awk -F"\t" '
      {
        single_tab=$4==1;
        single_win=$5==1;
        last_tab=$4==i+1;
        last_win=$6==j+1;
        first_tab=i==0;
        first_win=j==0;
      }

      { printf $3"\t" }

      single_tab && first_win { printf "---" }
      !single_tab && first_win { printf "+--" }
      !single_win && !first_win { printf "   " }

      single_win { printf "---" }
      !single_win { printf "+--" }

      {print "\t"$1":"$2"\t"$5"("$7")"}

      { last_tab ? i=0 : i++ ; last_win ? j=0 : j++}
      ' |${pkgs.unixtools.column}/bin/column -ts  $'\t'
    )


  window_id=$(${pkgs.fzf}/bin/fzf --prompt="CHOOSE WINDOW> " --nth=1,4 --reverse <<< "''${windows}" | ${pkgs.gawk}/bin/awk '{ print $1 }')

  ${pkgs.kitty}/bin/kitty @ focus-window -m "id:''${window_id}"
''
