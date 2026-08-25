# Zui Docs

Official documentation for [Zui](https://github.com/AdamMusa/zui).

Production: [zui.alkimist.dev](https://zui.alkimist.dev)

## Scope

- Complete reference for all 241 registered Zui components
- Source-backed properties, events, adapters, container metadata, and Ruby examples
- Guides for setup, state, bindings, events, commands, layout, animation, and effects
- Full-text component and guide search
- Responsive navigation, light and dark themes, syntax highlighting, and copyable examples
- Lexxy-backed guide authoring studio

## Stack

| Layer | Implementation |
| --- | --- |
| Application | Ruby 4.0.6, Rails 8.1 |
| Rendering | Server-rendered ERB, Turbo |
| Interaction | Stimulus, import maps |
| Authoring | Action Text, Lexxy 0.9 |
| Persistence | SQLite, Active Storage |
| Assets | Propshaft |
| Runtime | Puma on port 3050 |
| Deployment | Docker, Kamal, Thruster |

Lexxy is the only Markdown-friendly authoring path. The application does not install a second
Markdown parser or renderer.

## Local development

Requirements:

- Ruby 4.0.6
- Bundler
- SQLite 3

Prepare the application:

```bash
bin/setup --skip-server
bin/rails db:seed
```

Start Puma:

```bash
bin/dev
```

The application is available at [http://localhost:3050](http://localhost:3050).

## Routes

| Route | Purpose |
| --- | --- |
| `/` | Documentation overview and featured components |
| `/components` | Searchable component catalog |
| `/components/:slug` | Complete component API and Ruby example |
| `/guides/:slug` | Technical guide |
| `/search` | JSON search endpoint |
| `/studio` | Lexxy guide editor |
| `/up` | Application health check |

The studio is enabled in development and test. Production requires:

```bash
ZUI_DOCS_STUDIO=1
```

## Component catalog

[`config/zui_catalog.json`](config/zui_catalog.json) is the committed Zui component contract. The
snapshot records component names, categories, QML adapters, properties, events, container status,
reference copy, and complete Builder examples.

Current snapshot:

| Field | Value |
| --- | --- |
| Zui version | `0.0.5` |
| Components | `241` |
| Source revision | `514bd4a84b5785d5909c2d28664849b1d77c804f` |

Synchronize from a neighboring Zui checkout:

```bash
bin/rails "catalog:sync[../zui]"
```

The synchronization task regenerates the snapshot and executes every published component example
against the selected Zui source checkout. Invalid component metadata or Ruby examples stop the task.

Set a non-default source checkout with `ZUI_SOURCE`:

```bash
ZUI_SOURCE=/path/to/zui bin/rails catalog:sync
```

## Guide authoring

Guide records use Action Text content authored through Lexxy. Seed content is defined in
[`db/seeds.rb`](db/seeds.rb), and the studio provides the editing interface.

Validate guide syntax, language metadata, and referenced Zui APIs:

```bash
bin/rails "docs:validate[../zui]"
```

No interactive component simulator is embedded in reference pages. Component documentation uses
complete, source-validated Ruby examples and explicit API tables.

## Verification

Run the application test suite:

```bash
bin/rails test
```

Run the complete release checks:

```bash
bin/rails test
bin/rails "catalog:validate[../zui]"
bin/rails "docs:validate[../zui]"
bin/rubocop
bin/brakeman --no-pager
bin/rails assets:precompile
```

The catalog controller tests assert all 241 entries, API-page content, valid source examples, and a
visible catalog grid independent of decorative reveal animation.

## Configuration

| Variable | Default | Purpose |
| --- | --- | --- |
| `PORT` | `3050` | Puma listen port |
| `ZUI_SOURCE` | `../zui` | Zui checkout used by catalog and guide validation |
| `ZUI_DOCS_STUDIO` | unset | Enables the production authoring studio when set to `1` |
| `RAILS_MAX_THREADS` | `3` | Puma thread count |
| `SOLID_QUEUE_IN_PUMA` | unset | Runs the Solid Queue supervisor in Puma when enabled |

## Project structure

```text
app/
  controllers/          Catalog, guides, search, and studio endpoints
  javascript/           Stimulus controllers
  models/               Catalog access and guide records
  views/                Documentation, catalog, and studio templates
config/
  zui_catalog.json      Committed source registry
db/
  seeds.rb              Published guide content
lib/tasks/              Catalog and guide validation tasks
script/                 Synchronization and source-validation programs
test/                    Model and controller coverage
```

## Deployment

The repository includes a production Dockerfile and Kamal configuration. Production boots Puma,
serves fingerprinted Propshaft assets through Thruster, and exposes `/up` for health checks.

```bash
bin/kamal deploy
```
