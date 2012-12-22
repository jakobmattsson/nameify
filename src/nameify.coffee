module.exports = (api, meta) ->
  (name, params, callback) ->
    if !meta[name]?
      throw new Error("No function with the name '#{name}'!")
    api[name].apply(api, meta[name].map((n) -> params[n]).concat([callback]))
