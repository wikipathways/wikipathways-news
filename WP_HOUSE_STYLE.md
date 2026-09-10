# WikiPathways House Style

Extracted from the source of [wikipathways.github.io](https://www.wikipathways.org/) (Gladstone Institutes design), specifically `assets/main.scss`, `_includes/`, `_layouts/`, and the site's own living style guide at `style.md`. This document summarizes the visual language so it can be reused consistently in other WikiPathways materials (e.g. this newsletter).

## Typography

Two typefaces, used for distinct roles:

| Role | Typeface | Notes |
|---|---|---|
| Body / UI text | **Poppins** (Regular, plus Thin/ExtraLight/Light/Medium/SemiBold/Bold/ExtraBold/Black + italics) | Geometric sans-serif, loaded as a local `@font-face` from `assets/fonts/Poppins-*.ttf`. Applied to `.wrapper` at ≥800px viewport width. |
| Headings | **Linux Libertine** (Regular, Bold, Italic, and combinations) | A serif face, applied to `h1`–`h4`. Gives headings a more editorial, print-like contrast against the sans-serif body/UI. |

Heading scale:

- `h1` — 2em
- `h2` — 1.5em, bold, margin-top 25px / margin-bottom 5px
- `h3` — 1.25em, margin-top 15px / margin-bottom 5px
- `h4` — 1em, bold

Icon font: **Font Awesome** (bundled locally via `assets/fontawesome.all.min.css` / `webfonts/`, plus an older Font Awesome 4.5.0 loaded from a CDN for legacy glyph classes).

## Color Palette

The site's own `style.md` documents this explicitly as Primary / Secondary / Tertiary palettes.

**Primary palette** (neutrals):

| Swatch | Hex | Use |
|---|---|---|
| Black | `#000000` | Body text, primary text on light backgrounds |
| Grey | `#F5F6F6` | Subtle surface tint |
| Light grey | `#EEEEEE` | Header/footer background, `.bg-light`, hover states |
| White | `#FFFFFF` | Page/card backgrounds |

**Secondary palette** — one accent color per content type, used consistently across badges, pill buttons, and category links:

| Category | Hex | Used for |
|---|---|---|
| Organism Blue | `#3955E7` | Organisms; also the default link color (`a:link`, `a:visited`, `a:hover`) and the "front page" CTA button |
| Community Green | `#008558` | Communities |
| Annotation Purple | `#880BC8` | Annotations (pathway/disease/cell-type ontology terms); also used for carousel control icons |
| Pathway Orange | `#FF8120` | Pathways |

**Tertiary palette** (hover/active/darker variants of the secondary colors):

| Category | Hex |
|---|---|
| Organism Dark Blue | `#1E3199` |
| Community Dark Green | `#026E55` |
| Annotation Dark Purple | `#620492` |
| Pathway Dark Orange | `#D16919` |
| Dark Grey | `#94A6A8` |

Other recurring neutrals in the stylesheet: `#424242` (page-title link text), `#4C4C4C` (secondary badge background), `#666` (icon/action buttons), `#999999`/`#cfcfcf`/`#dcdcdc` (muted text/borders), `#fff3cd` / `#f0ad4e` (amber announcement-banner background/border).

**Rule of thumb:** every content type in WikiPathways (Organism, Community, Annotation, Pathway) has its own accent color, applied consistently to pill buttons and badges wherever that content type appears, with a darker shade reserved for `:hover`.

## Layout

- Built on **Jekyll** using the `minima` theme as a base, heavily overridden by `assets/main.scss`.
- **Bootstrap 4.0.0** (CDN) supplies the grid, navbar, cards, buttons, and badges; `main.scss` overrides Bootstrap defaults rather than replacing them.
- Content is wrapped in a `.wrapper` container, capped at **max-width: 1190px** on viewports ≥800px.
- `box-sizing: content-box` is forced globally (an override of Bootstrap's `border-box` default), inherited from the `minima` base theme.
- Responsive breakpoint at 800px switches `.row-main` to a flex column layout for mobile.

## Header

- `.site-header`: light grey background (`#EEEEEE`), no bottom border.
- Logo: `wikipathways-logo-horizontal.svg`, 75px tall, linked to home.
- Right-aligned inline search box (Font Awesome search icon + text input) and a flat text nav menu (About, Search, Browse, Communities, Download, Analyze, Cite, Help) — no dropdown/hamburger chrome, just inline links with small font size.
- An optional full-width announcement banner sits below the nav bar (amber `#fff3cd` background, `#f0ad4e` border) for transition/status notices.

## Footer

- `.site-footer`: same light grey (`#EEEEEE`) as the header, small padding.
- Row of GitHub badge/shield images (last commit, author count, commit activity, build status) at the top.
- Multi-column link list below (About/Help, API/Tools/Download, Organisms/Communities/Browse/Academy, Statistics/Citations/Report a bug), plus the site description and a CC0 public-domain badge.

## Components

**Pill buttons** (`.btn.btn-sm.btn-pill`) — small, fully-rounded (`border-radius: 23px`) buttons, one variant per content-type color:

```html
<a class="btn btn-sm btn-pill btn-organism">…</a>   <!-- blue -->
<a class="btn btn-sm btn-pill btn-community">…</a>  <!-- green -->
<a class="btn btn-sm btn-pill btn-annotation">…</a> <!-- purple -->
<a class="btn btn-sm btn-pill btn-pathway">…</a>    <!-- orange -->
```

Each has a filled default state and a darker fill + white border on `:hover`. A separate `btn-outline-warning` style (white fill, blue border/text) is used for generic external/internal links, and `btn-front` (white fill, blue border/text, inverts to solid blue on hover) is reserved for the homepage's primary call-to-action.

**Badges**: `.badge-secondary` uses dark grey (`#4C4C4C`) fill, white text, `border-radius: 4px`, `font-weight: 400`.

**Cards** (pathway thumbnails): Bootstrap `.card` with a thumbnail image (`.card-img-top`), tight body padding (`.card-body { padding: 0 0 0 5px }`), and small caption text (`.card-text { font-size: 0.8em }`). Card links (`a.card-link`) drop the underline and render in black.

**Tables**: `table-layout: fixed`, small bottom margin; DataTables sorting-indicator tweaks are included for interactive tables.

**Tabs**: standard Bootstrap `nav-tabs` used to switch between "Gallery" (card grid) and "List" views of the same data (see pathway listings).

## Iconography & Imagery

- Font Awesome glyphs for inline UI actions (copy link, copy embed code, save as PDF, edit markdown) — rendered as plain icon buttons, no border, `color: #666`.
- Favicons/touch icons provided in the standard modern set (`favicon.ico`, 16/32px PNG, Apple touch icon, Android Chrome icons, web manifest).
- Decorative "thanks" logos are desaturated (`filter: grayscale(100%)`) until relevant.

## Tone of the visual system

Clean, high-contrast, editorial-meets-scientific-tool: a serif display face for headings paired with a neutral geometric sans for interface text, a near-white/light-grey chrome (header, footer, backgrounds) that stays out of the way, and one saturated accent color per core data type (organism/community/annotation/pathway) used as the primary way users visually distinguish and navigate content categories throughout the site.
