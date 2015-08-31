cache = require '../'

namespaceMap =
  'test1': 0
  'test2': 1

opts =
  host: '192.168.59.103'
  port: 8220


cache.init namespaceMap, opts

cache.set 'test2', 'hello', 'world', (err, result) ->
  console.log err, result

cache.get 'test2', 'hello', (err, result) ->
  console.log err, result
  cache.client.end()

