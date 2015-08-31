_ = require 'lodash'
redis = require 'redis'

_client = {}
_namespaceMap = {}

isExistNS = (namespace) ->
  return false unless _.isString(namespace)
  return false unless _.has(_namespaceMap, namespace)
  return true

getUnionKey = (namespace, key) ->
  "#{namespace}_#{key}"

checkArgs = (namespace, key) ->
  return new Error('namespace not exists') unless isExistNS(namespace)
  return new Error('key must be string type') unless _.isString(key)
  return false

set = (namespace, key, value, callback) ->
  return callback err if err = checkArgs(namespace, key)

  unionKey = getUnionKey(namespace, key)
  try
    value = JSON.stringify(value)
  catch error
    return callback error

  if _namespaceMap[namespace]
    _client.setex(unionKey, _namespaceMap[namespace], value, callback)
  else
    _client.set(unionKey, value, callback)

get = (namespace, key, callback) ->
  return callback err if err = checkArgs(namespace, key)
  unionKey = getUnionKey(namespace, key)
  _client.get unionKey, (err, result) ->
    result = JSON.parse(result) unless err
    callback(err, result)

del = (namespace, key, callback) ->
  return callback err if err = checkArgs(namespace, key)
  unionKey = getUnionKey(namespace, key)
  _client.del(unionKey, callback)

inrc = (namespace, key, callback) ->
  return callback err if err = checkArgs(namespace, key)
  unionKey = getUnionKey(namespace, key)
  _client.incr(unionKey, callback)

derc = (namespace, key, callback) ->
  return callback err if err = checkArgs(namespace, key)
  unionKey = getUnionKey(namespace, key)
  _client.decr(unionKey, callback)


cache = {}

##
# namespaceMap key: namespace name  value: expire time, 0 forever
# opts: createClient options
##

cache.init = (namespaceMap, opts) ->
  return cache is _client

  _namespaceMap = namespaceMap
  _client = redis.createClient(opts.port, opts.host)

  _client.on 'error', (err) ->
    console.log err

  cache.set = set
  cache.get = get
  cache.del = del
  cache.inrc = inrc
  cache.derc = derc
  cache.namespaceMap = _namespaceMap
  cache.client = _client
  cache


cache.get = cache.set = cache.del = cache.inrc = cache.derc = ->
  throw Error 'cache must be init, at use before'

module.exports = cache
