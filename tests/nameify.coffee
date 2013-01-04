should = require 'should'
nameify = require('./coverage').require('nameify')



testapi = {
  version: 1
  store: {}

  get: (name, callback) ->
    if @store[name]
      callback(null, @store[name])
    else
      callback(new Error("Could not find the key"))

  set: (name, value, callback) ->
    @store[name] = value
    callback()
}



spec = {
  get: ['name']
  set: ['name', 'value']
}

ap2 = (name, params, callback) ->
  callback(null, { method: name, params: params })



it "should successfully transform an api to a function", () ->
  nameify.byName(testapi, spec).should.be.a 'function'



it "should raise an error if an invalid function is called", () ->
  api = nameify.byName(testapi, spec)
  f = -> api 'invalid-function', {}, ->
  f.should.throw "No function with the name 'invalid-function'!"



it "should pass arguments through properly", (done) ->
  isOK = false
  f = (err) ->
    should.not.exist err
    isOK.should.be.true
    done()

  api = nameify.byName({
    set: (name, value, callback) ->
      isOK = name == 'n' && value == 'v' && callback == f
      callback()
  }, {
    set: ['name', 'value']
  })

  api 'set', { name: 'n', value: 'v' }, f



it "should pass arguments through properly, even when in the wrong order", (done) ->
  isOK = false
  f = (err) ->
    should.not.exist err
    isOK.should.be.true
    done()

  api = nameify.byName({
    set: (name, value, callback) ->
      isOK = name == 'n' && value == 'v' && callback == f
      callback()
  }, {
    set: ['name', 'value']
  })

  api 'set', { value: 'v', name: 'n' }, f



it "should pass arguments through properly, even when some are missing", (done) ->
  isOK = false
  f = (err) ->
    should.not.exist err
    isOK.should.be.true
    done()

  api = nameify.byName({
    set: (name, value, callback) ->
      isOK = name == undefined && value == 'v' && callback == f
      callback()
  }, {
    set: ['name', 'value']
  })

  api 'set', { value: 'v' }, f



it "should retin proper context after being converted", (done) ->
  api = nameify.byName(testapi, spec)
  api 'set', { name: 'key', value: 123 }, (err) ->
    should.not.exist err
    api 'get', { name: 'key' }, (err, val) ->
      should.not.exist err
      val.should.eql 123
      done()



describe 'byPosition', ->

  it "should successfully transform a single api-function to an api-object", ->
    nameify.byPosition(ap2, spec).should.be.a 'object'

  it "should successfully create all the api-functions", ->
    nameify.byPosition(ap2, spec).should.have.keys ['get', 'set']

  it "should successfully create all the api-functions", (done) ->
    api = nameify.byPosition(ap2, spec)
    api.set 'n', 'v', (err, d) ->
      should.not.exist err
      d.should.eql { method: 'set', params: { name: 'n', value: 'v' } }
      done()
