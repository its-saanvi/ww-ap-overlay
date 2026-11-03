## ww-ap-overlay
All Portals Overlay as a plugin on waywall. Watch the [demo](https://youtu.be/tvPJhZJjx3g) to know more.

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
					completion_color = "#323232",
				},
				commands = {
					add_sh = "addap", -- Command to add a stronghold. Syntax: <command_name> <x> <z> <ring_number: optional>
					remove_sh = "rmap", -- Command to remove a stronghold. Syntax: <command_name> <ring_number: optional>
					ring = "ringap", -- Command to check which ring a stronghold is in. Syntax: <command_name> <x> <z>
				},
			},
			wayevents_path = "~/.local/bin/wayevents", -- Path to the wayevents binary. This gets added to $PATH if you have it in an unusual location.
			hotkeys = {
				next = "Page_Up", -- Hotkey to go to next stronghold
				prev = "Page_Down", -- Hotkey to go to previous stronghold
				reset = "o", -- Hotkey to reset current session (backup is saved automatically by all-portals-overlay).
				solve = "p", -- Hotkey to run the solver.
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
#### Manually
> You need to get [git](https://git-scm.com/) first.
Run these commands in a terminal:
```bash
cd ~/.config/waywall
git clone https://github.com/its-saanvi/ww-ap-overlay ww_ap_overlay
git clone https://github.com/arjuncgore/ww_command_line
git clone https://git.sr.ht/~me-nx/wayevents
git clone https://github.com/rxi/json.lua json
```

Then put this in your config wherever you want. `config` is your waywall config table:
```lua
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
			completion_color = "#323232",
		},
		commands = {
			add_sh = "addap", -- Command to add a stronghold. Syntax: <command_name> <x> <z> <ring_number: optional>
			remove_sh = "rmap", -- Command to remove a stronghold. Syntax: <command_name> <ring_number: optional>
			ring = "ringap", -- Command to check which ring a stronghold is in. Syntax: <command_name> <x> <z>
		},
	},
	wayevents_path = "~/.local/bin/wayevents", -- Path to the wayevents binary. This gets added to $PATH if you have it in an unusual location.
	hotkeys = {
		next = "Page_Up", -- Hotkey to go to next stronghold
		prev = "Page_Down", -- Hotkey to go to previous stronghold
		reset = "o", -- Hotkey to reset current session (backup is saved automatically by all-portals-overlay).
		solve = "p", -- Hotkey to run the solver.
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
```


## Thanks 
- [Lincoln](https://github.com/lincoln-lm) for [all-portals-overlay](https://github.com/lincoln-lm/all-portals-overlay).
- [Gore](https://github.com/arjuncgore) for [ww_command_line](https://github.com/arjuncgore/ww_command_line).
- [me-nx](https://git.sr.ht/~me-nx) for [wayevents](https://git.sr.ht/~me-nx/wayevents).
- [json.lua](https://github.com/rxi/json.lua)'s creators and maintainers.

## Issues
If you face any issues with installing dependencies (like wayevents) or find any bugs, please make an [issue](https://github.com/its-saanvi/ww-ap-overlay).
