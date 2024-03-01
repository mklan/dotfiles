if rofi theming breaks (dark text on dark bg) :

append this to `/usr/lib/python3.9/site-packages/pywal/templates/colors-rofi-dark.rasi`:

```css
element-text,
element-icon {
  background-color: inherit;
  text-color: inherit;
}}
```

src: https://github.com/dylanaraps/pywal/issues/624
