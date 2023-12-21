Project for my homepage.

# Build sphinx target

Setup meson:

```
 meson setup <build_root>
```

Build sphinx target:

```
ninja -C <build_roo> sphinx
```

Website index is at `<build_root>/docs/build/index.html`

# Update github pages

Github pages uses branch website as the source. To update it
run `update_website_branch.sh`.

Commit messages of website branch contains the full has to the
commit which it is based on.
