# Weather script — secure setup

`weather.sh` reads `OPENWEATHER_API_KEY` from the environment instead of
storing the key in the script.

## 1. Get an API key

Sign up at <https://openweathermap.org/api> and create a free API key.

## 2. Set the environment variable

Because **Waybar does not inherit your shell's environment**, the variable must
be injected via the Waybar `exec` command or a wrapper script.

### Option A — systemd user environment (recommended)

```bash
systemctl --user set-environment OPENWEATHER_API_KEY=<your-key>
# Persist across reboots by adding to ~/.config/environment.d/openweather.conf:
echo 'OPENWEATHER_API_KEY=<your-key>' \
    >> ~/.config/environment.d/openweather.conf
```

Restart Waybar after setting the variable:

```bash
pkill waybar && waybar &
```

### Option B — inline in Waybar config

In `~/.config/waybar/config`, wrap the exec command:

```json
"exec": "OPENWEATHER_API_KEY=<your-key> /path/to/weather.sh"
```

> ⚠ This stores the key in the Waybar config file. Make sure that file is
> gitignored or not committed to a public repository.

### Option C — source a local .env file from your shell profile

Create `scripts/bar-modules/weather/.env` (gitignored) based on `.env.example`:

```bash
cp scripts/bar-modules/weather/.env.example \
   scripts/bar-modules/weather/.env
# Edit .env and set your real key
```

Then export the variable from your login shell profile (`~/.bash_profile`,
`~/.zprofile`, or `~/.profile`) so that systemd user services started from
the session inherit it:

```bash
echo 'export OPENWEATHER_API_KEY=<your-key>' >> ~/.zprofile
# Then either log out and back in, or run:
systemctl --user set-environment OPENWEATHER_API_KEY=<your-key>
```

> ℹ️ `~/.config/environment.d/*.conf` files use plain `KEY=VALUE` syntax
> parsed by `systemd-environment-d-generator` — they do **not** support shell
> `source` or `export` directives.

## 3. Verify

```bash
OPENWEATHER_API_KEY=<your-key> ./scripts/bar-modules/weather/weather.sh
```

You should see a JSON string with current weather data.
