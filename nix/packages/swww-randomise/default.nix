{
  writeShellScriptBin,
  system,
  inputs,
  ...
}: let
  swww = inputs.swww.packages.${system}.swww;
in
  writeShellScriptBin "swww-randomise" ''
    #!/bin/zsh

    if [[ $# -lt 1 ]] || [[ ! -d $1 ]]; then
        echo "Usage: $0 <dir containing images> <optional: interval in seconds>" >&2
        exit 1
    fi

    # Edit below to control the images transition
    export SWWW_TRANSITION_FPS=144
    export SWWW_TRANSITION_STEP=2

    # The directory containing the images
    IMAGE_DIR="$1"
    # This controls (in seconds) when to switch to the next image
    INTERVAL=''${2:-10}

    # Possible values:
    #    -   no:   Do not resize the image
    #    -   crop: Resize the image to fill the whole screen, cropping out parts that don't fit
    #    -   fit:  Resize the image to fit inside the screen, preserving the original aspect ratio
    RESIZE_TYPE="fit"

    if [[ ! -d "$IMAGE_DIR" ]]; then
        echo "Image directory not found: $IMAGE_DIR" >&2
        exit 1
    fi

    # Get the list of displays once
    readarray -t DISPLAY_LIST < <(swww query | grep -Po "^[^:]+")

    if [ ''${#DISPLAY_LIST[@]} -eq 0 ]; then
        echo "No displays found via swww query." >&2
        exit 1
    fi

    while true; do
        readarray -t images < <(find "$IMAGE_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) -print)

        if [ ''${#images[@]} -eq 0 ]; then
            echo "No images found in $IMAGE_DIR. Waiting ''${INTERVAL} seconds before retrying." >&2
            sleep "$INTERVAL"
            continue
        fi

        shuffled_indices=($(seq 0 $(( ''${#images[@]} - 1 )) | shuf))

        for index in "''${shuffled_indices[@]}"; do
            img="''${images[$index]}"

            for disp in "''${DISPLAY_LIST[@]}"; do
                echo "Setting wallpaper for display $disp to $img" >&2
                swww img --resize="$RESIZE_TYPE" --outputs "$disp" "$img" || {
                    echo "Error setting wallpaper for $disp with $img" >&2
                }
                sleep 0.1
            done
            sleep "$INTERVAL"
        done
    done
  ''
