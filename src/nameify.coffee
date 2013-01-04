exports.byName = (api, meta) ->
  (name, params, callback) ->
    if !meta[name]?
      throw new Error("No function with the name '#{name}'!")
    api[name].apply(api, meta[name].map((n) -> params[n]).concat([callback]))

exports.byPosition = (api, meta) ->
  Object.keys(meta).reduce (acc, name) ->
    acc[name] = (args..., callback) ->
      argobj = meta[name].reduce (acc, name, i) ->
        acc[name] = args[i]
        acc
      , {}
      api(name, argobj, callback)
    acc
  , {}
