compatibility = (->
  lastTime = 0
  isLittleEndian = true
  URL = window.URL or window.webkitURL
  requestAnimationFrame = (callback, element) ->
    requestAnimationFrame = window.requestAnimationFrame or \
        window.webkitRequestAnimationFrame or \
        window.mozRequestAnimationFrame or \
        window.oRequestAnimationFrame or \
        window.msRequestAnimationFrame

    requestAnimationFrame.call window, callback, element

  cancelAnimationFrame = (id) ->
    cancelAnimationFrame = window.cancelAnimationFrame or (id) ->
      clearTimeout id
      return

    cancelAnimationFrame.call window, id

  getUserMedia = (options, success, error) ->
    getUserMedia = window.navigator.getUserMedia or \
        window.navigator.mozGetUserMedia or \
        window.navigator.webkitGetUserMedia or \
        window.navigator.msGetUserMedia

    getUserMedia.call window.navigator, options, success, error

  detectEndian = ->
    buf = new ArrayBuffer(8)
    data = new Uint32Array(buf)
    data[0] = 0xff000000
    isLittleEndian = true
    isLittleEndian = false  if buf[0] is 0xff
    isLittleEndian

  URL: URL
  requestAnimationFrame: requestAnimationFrame
  cancelAnimationFrame: cancelAnimationFrame
  getUserMedia: getUserMedia
  detectEndian: detectEndian
  isLittleEndian: isLittleEndian
)()