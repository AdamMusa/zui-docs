# Zui documentation

The complete, code-first documentation and component catalog for [Zui](https://github.com/AdamMusa/zui).

The application is intentionally separate from the Zui source tree. It uses Rails 8.1, Hotwire,
Stimulus, Action Text, and Basecamp's [Lexxy](https://github.com/basecamp/lexxy) editor. Lexxy owns
the Markdown-friendly authoring path; no Redcarpet, CommonMarker, Kramdown, or other Markdown gem is
installed.

## Local setup

```bash
bin/setup
bin/rails db:seed
bin/dev
```

Open `http://localhost:3000`. In development, `/studio` exposes the Lexxy guide editor. Production
keeps the studio disabled unless `ZUI_DOCS_STUDIO=1` is set.

## Catalog source

`config/zui_catalog.json` is a committed snapshot of Zui's registered component contract. It includes
all component names, categories, adapters, properties, events, container status, documentation, and
complete Builder examples. Every published example is executed against the source checkout during
catalog synchronization; the sync fails instead of publishing an invalid snippet.

Refresh it from a neighboring checkout:

```bash
bin/rails "catalog:sync[../zui]"
```

The current snapshot contains 241 components from Zui 0.0.5 at source revision
`514bd4a84b5785d5909c2d28664849b1d77c804f`.

## Verification

```bash
bin/rails test
bin/rails "catalog:validate[../zui]"
bin/rails "docs:validate[../zui]"
bin/rubocop
bin/brakeman --no-pager
bin/rails assets:precompile
```
