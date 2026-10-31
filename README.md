## ww-ap-overlay
All Portals Overlay as a plugin on waywall.

## Installation

### External Dependencies

- Python 3
- [all-portals-overlay](https://github.com/lincoln-lm/all-portals-overlay) by Lincoln

### Installation
#### Using [plug.waywall](https://github.com/its-saanvi/plug.waywall)
```lua
{
	url = "https://github.com/its-saanvi/ww-ap-overlay",
	name = "ww_ap_overlay",
	config = function(config)
		require("ww_ap_overlay").setup(config, {
			python_path = "/usr/bin/python3", -- Path to the python3 executable.
			clone_path = "~/all-portals-overlay", -- Path to a git clone of the all-portals-overlay repo.
			binary_path = "", -- If both clone_path and python_path are set, this is not needed. But this is preferred even if clone_path and python_path are set.
			ww_cli = { -- ww_command_line defaults, you can customize it to work with however you have setup ww_command_line yourself
				start_key = "BACKSLASH",
				enter_key = "Return",
				look = {
					x = 200,
					y = 200,
					size = 7,
					color = "#FFFFFF",
				},
				commands = {
					add_sh = "apadd",
					remove_sh = "aprm",
					ring = "apring",
				},
			},
			wayevents_path = "~/.local/bin/wayevents",
			hotkeys = {
				next = "Page_Up",
				prev = "Page_Down",
				reset = "o",
				solve = "p",
			},
			overlay = {
				text = { -- Shows the list of strongholds you have entered currently.
					x = 1420,
					y = 580,
					size = 3,
					color = "#FFFFFF",
				},
				image = { -- Shows the overlay image
					dst = {
						x = 1520,
						y = 580,
						w = 400,
						h = 500,
					},
				},
			},
		})
	end,
	dependencies = {
		{
			url = "https://github.com/arjuncgore/ww_command_line",
		},
		{
			url = "https://git.sr.ht/~me-nx/wayevents",
		},
		{
			url = "https://github.com/rxi/json.lua",
			name = "json",
		},
	},
}
```

## Issues
If you face any issues with installing dependencies (like wayevents), please make an issue.
