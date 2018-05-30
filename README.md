# Deps

1. Install Lua.
2. Install LuaRocks and Deps:

```
sudo luarocks
sudo luarocks install busted
sudo luarocks install luacov
sudo luarocks install penlight
```

# Run Tests

```
busted .
```

# View Coverage

```
luacov
cat luacov.report.out
```
