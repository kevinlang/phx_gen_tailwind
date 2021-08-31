# PhxGenTailwind

Adds Tailwind to your new Phoenix 1.6+ project

## Installation

First, install it in your `mix.exs` file. If you have an umbrella setup,
you should be installing it in your Phoenix app (`{name}_web`).

```elixir
def deps do
  [
    {:phx_gen_tailwind, "~> 0.1.2-rc.0", only: :dev}
  ]
end
```

Once installed, simply run `mix phx.gen.tailwind` from the root of your project.
If you are in an umbrella setup, it should be run from the root of your web app.

```
$ mix phx.gen.tailwind
* creating assets/package.json
* creating assets/tailwind.config.js
* injecting assets/css/app.css
* injecting config/dev.exs
* injecting mix.exs
* injecting assets/js/app.js

NPM install new dependencies? [Yn] 
* running cd assets/ && npm install
```
