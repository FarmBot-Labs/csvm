local pretty = require 'pl.pretty'

function create_dispatcher (dispatcher_name, lookup_table)
  return function (message_name, args)
    local handler = lookup_table[name]
    if (handler) then
      return handler(args)
    else
      pretty.dump(lookup_table)
      error("Unnown action '" ..
            message_name      ..
            "' sent to '"     ..
            dispatcher_name   ..
            "'")
    end
  end
end


