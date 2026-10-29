#!/usr/bin/env python3
"""Render a pywal-style CSS template with dual light/dark palettes.

Every {placeholder} color (background, foreground, cursor, color0..15) is
substituted with a CSS light-dark(<light>, <dark>) pair instead of a single
value. Firefox resolves light-dark() against prefers-color-scheme, which
tracks org.gnome.desktop.interface color-scheme at runtime – so the rendered
stylesheet flips between the two palettes live, without Firefox restarting.

Usage:
    gen-ff-theme.py <light-scheme.json> <dark-scheme.json> <template> <output>

The template uses Python str.format() syntax: literal curly braces must be
doubled ({{ }}) – same convention as pywal templates.
"""

import json
import sys


def load_scheme(path):
    with open(path) as f:
        scheme = json.load(f)
    colors = dict(scheme.get("colors", {}))
    colors.update(scheme.get("special", {}))
    return colors


def main():
    if len(sys.argv) != 5:
        sys.exit(__doc__.strip().splitlines()[-2].strip())
    light_path, dark_path, template_path, output_path = sys.argv[1:5]

    light = load_scheme(light_path)
    dark = load_scheme(dark_path)

    values = {}
    for key in set(light) | set(dark):
        values[key] = "light-dark({}, {})".format(
            light.get(key, "#000000"), dark.get(key, "#000000")
        )

    with open(template_path) as f:
        rendered = f.read().format(**values)

    with open(output_path, "w") as f:
        f.write(rendered)


if __name__ == "__main__":
    main()
