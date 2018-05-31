# CeleryScript Runtime Environment

Where CeleryScript code gets executed.

# Deps

1. Install Lua.
2. Install LuaRocks and Deps:

```
sudo luarocks
sudo luarocks install busted
sudo luarocks install luacov
sudo luarocks install luasocket
sudo luarocks install penlight
```

# Run Tests

```
busted .
```

# Debug / Local Dev

```
CELERY_ENV=dev lua lua_lib/_main.lua
```

In a web browser, open [http://localhost:8000/](http://localhost:8000/).

Dev mode exposes an `INBOX` global variable which may be useful for debugging VM/host messages.

Example: Running a `CODE.CREATE` call with a `"foobarbaz"` payload:

```
INBOX.push_req("CODE", "CREATE", "foobarbaz")
```

# View Coverage

```
luacov
cat luacov.report.out
```
