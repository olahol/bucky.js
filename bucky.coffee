upload = (url, policy, file) ->
  size  = 0
  bytes = 0

  formData = new FormData()
  for k, v of policy
    formData.append k, v
  formData.append "file", file

  xhr = new XMLHttpRequest()

  xhr.onreadystatechange = ->
    if xhr.readyState is 4
      return handle.fail file, policy.key unless xhr.statusText is "OK"
      rest = size - bytes
      handle.progress rest unless rest is 0
      handle.done file, policy.key

  xhr.upload.addEventListener "abort", (e) ->
    handle.fail file, policy.key
  xhr.upload.addEventListener "error", (e) ->
    handle.fail file, policy.key
  xhr.upload.addEventListener "progress", (e) ->
    if bytes is 0
      size = e.total
      handle.start size
    handle.progress e.loaded - bytes
    bytes = e.loaded

  xhr.open "POST", url, true
  xhr.send formData

  handle =
    start: ->
    fail: ->
    progress: ->
    done: ->

bucky = (bucket, els...) ->
  multiple = (e) ->
    total  = 0
    loaded = 0
    count  = 0
    files  = e.target.files || e.dataTransfer.files

    handle.start()

    for file in files
      handle.policy file, (policy) ->
        up = upload "http://#{bucket}.s3.amazonaws.com", policy, file
        up.start = (size) ->
          total += size
        up.progress = (bytes) ->
          loaded += bytes
          handle.progress loaded, total
        up.fail = (name, key) ->
          count += 1
          handle.fail name, key
          handle.stop() if count is files.length
        up.done = (name, key) ->
          count += 1
          handle.done name, key
          handle.stop() if count is files.length

  listen = (el) ->
    stop = (e) ->
      e.stopPropagation()
      e.preventDefault()
    if el.nodeName is "INPUT"
      el.addEventListener "change", multiple
    else
      el.addEventListener "dragover", stop
      el.addEventListener "dragleave", stop
      el.addEventListener "drop", (e) ->
        stop e
        multiple e

  for el in els
    listen el

  handle =
    start: ->
    policy: ->
    progress: ->
    fail: ->
    done: ->
    stop: ->

window.bucky = bucky
