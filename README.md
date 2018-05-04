# Csvm

## Usage
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

## Notes
`mruby` does not get cleaned up for some reason. 
