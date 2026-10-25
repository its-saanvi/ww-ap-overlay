## TODO
- Overlay view in game using waywall.image: PR to all-portals-overlay directly to output to PNG and use that.

## Installation

### Dependencies

- Python 3
- [all-portals-overlay](https://github.com/lincoln-lm/all-portals-overlay) by Lincoln

### Installation
#### Using [plug.waywall](https://github.com/its-saanvi/plug.waywall)
```lua
{
    url = "https://github.com/its-saanvi/ww-ap-overlay",
    name = "ww_ap_overlay",
    config = function(config)
        -- This is the default config
        require("ww_ap_overlay").setup(config, {
            python_path = "/usr/bin/python3", -- Path to python3
            overlay_path = "~/all-portals-overlay", -- Path to a git clone of the all-portals-overlay repo
            overlay_binary = "", -- If both overlay_path and python_path are set, this is not needed. But this is preferred even if overlay_path and python_path are set
            ww_cli = { -- ww_command_line defaults, you can customize it to work with however you have setup ww_command_line yourself
                start_key = "BACKSLASH",
                enter_key = "Return",
                look = {
                    x = 200,
                    y = 200,
                    size = 7,
                    color = "#FFFFFF"
                },
            },
            hotkeys = {
                next = "Page_Up",
                prev = "Page_Down",
                reset = "F12",
                input_next_stronghold = "Delete",
                solve = "F9",
            },
            overlay = {
                x = 1620,
                y = 780
            }
        })
    end,
    dependencies = {
        {
            url = "https://github.com/arjuncgore/ww_command_line",
        },
    }
}
```
