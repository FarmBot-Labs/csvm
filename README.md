# Celery Script Virtual Machine

Work in progress / Proof of concept. Written in mRuby.

## Installation

```bash
git clone https://github.com/farmbot-labs/csvm-poc --recursive
mix deps.get
# This compiles mruby and then any ruby sources in `ruby_lib`
mix compile
iex -S mix
```

```elixir
iex()> Csvm.Server.echo "hey ruby!"
DATA FROM MRUBY: "hey ruby!\n"
```

## Testing

```
rake test
```

## TODOs

 * Something like `pry-remote`, maybe.
 * clean up `mrb` during build (broke right now).
