if rofi theming breaks ( dark text on dark bg) :

add this to the cached wal template:

```css
element-text,
element-icon {
  background-color: inherit;
  text-color: inherit;
}
```

src: https://github.com/dylanaraps/pywal/issues/624
