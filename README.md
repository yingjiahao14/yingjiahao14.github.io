# jhying.org

Personal academic homepage of Jiahao Ying, served at [jhying.org](https://jhying.org).

## Editing

- `index.md` — About Me & Research Interests
- `_data/news.yml` — news items (one entry per line)
- `_data/publications.yml` — publication list (see field comments in the file)
- `_includes/services.html` — academic services

Push to `main` and the site is built and deployed automatically.

## Publication hover animations

Each publication row can show a small SVG "scene" that plays on hover (the
thumbnail fades out, the animation fades in). On touch screens there is no
hover, so a small IntersectionObserver in `_layouts/homepage.html` adds a
`.play` class while the card sits in the middle band of the viewport — scenes
auto-play as you scroll, and revert to the thumbnail as they leave. Moving the
mouse away and `prefers-reduced-motion` fall back to the static thumbnail.

A shared character system keeps every scene consistent: one robot "bot" plus a
kit of parts (speech bubble, document, magnifier, score stamp, skill block),
all drawn with `currentColor`/`var(--muted)`/`var(--accent)` so they adapt to
light and dark mode automatically.

Files involved:

- `_includes/scenes.html` — one Liquid `{% when '<key>' %}` branch per scene,
  holding the inline `<svg>` markup.
- `assets/css/main.css` — the scene animations live at the end, in three blocks:
  the drawing parts (`.scene .ln`, `.ac`, …), the `@keyframes`, and the
  `.pub:hover .<key>-*` rules that trigger them on hover.
- `_data/publications.yml` — each paper opts in with a `scene: <key>` field.

### Adding a scene for a new paper

1. Pick a short `<key>` (e.g. `probing`). Tell me what the paper *does* and I can
   author the scene; to do it by hand:
2. In `_includes/scenes.html`, add `{% when 'probing' %}` with an
   `<svg class="scene s-probing" viewBox="0 0 132 94" aria-hidden="true">…</svg>`.
3. In `assets/css/main.css`, add `@keyframes probing-*` and matching
   `.pub:is(:hover,.play) .probing-*` rules (the `:is()` makes the scene work
   for both desktop hover and mobile scroll-play; prefix every class with the
   key to avoid collisions across scenes).
4. In `_data/publications.yml`, add `scene: probing` to that paper.

**The one hard rule** (both reviewers on the first build hit this): in SVG, a CSS
`transform` animation *overrides* the element's `transform` attribute. So any
element that both needs positioning and animates via transform must use two
nested groups — an outer `<g transform="translate(…)">` for placement and an
inner `<g class="…">` for the animation. Rotations/scales about an element's own
center also need `transform-box: fill-box`.

## Local preview

```
bundle install
bundle exec jekyll serve
```
