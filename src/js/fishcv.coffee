class Util
  render_mono_image: (src, dst, sw, sh, dw) ->
    alpha = (0xff << 24)
    i = 0

    while i < sh
      j = 0

      while j < sw
        pix = src[i * sw + j]
        dst[i * dw + j] = alpha | (pix << 16) | (pix << 8) | pix
        ++j
      ++i
    return



class App
  constructor: ->

    @video = $('#webcam')[0]
    @canvas = $('canvas')[0]

    @img_u8 = new jsfeat.matrix_t(640, 480, jsfeat.U8_t | jsfeat.C1_t)

    compatibility.getUserMedia video: true, @handleVideo

  handleVideo: (stream) =>
    try
      @video.src = compatibility.URL.createObjectURL(stream)
    catch error
      @video.src = stream

    setTimeout @step, 500
    return

  step: =>
    @video.play()
    @doFish()
    compatibility.requestAnimationFrame @tick
    return

  unload: ->
    @video.pause()
    @video.src = null
    return

  doFish: ->
    canvasWidth = @canvas.width
    canvasHeight = @canvas.height
    @ctx = @canvas.getContext("2d")
    @ctx.fillStyle = "rgb(0,255,0)"
    @ctx.strokeStyle = "rgb(0,255,0)"

    img_pyr = new jsfeat.pyramid_t(4)
    img_pyr.allocate 640, 480, jsfeat.U8_t | jsfeat.C1_t

    return
  
  tick: =>
    compatibility.requestAnimationFrame @tick

    if @video.readyState is not @video.HAVE_ENOUGH_DATA
      return

    @ctx.drawImage @video, 0, 0, 640, 480
    imageData = @ctx.getImageData(0, 0, 640, 480)
      
    jsfeat.imgproc.grayscale imageData.data, @img_u8.data
    
    blur_radius = 5
    kernel_size = (blur_radius + 1) << 1
    sigma = 1

    jsfeat.imgproc.gaussian_blur @img_u8, @img_u8, kernel_size, sigma

    # render result back to canvas
    data_u32 = new Uint32Array(imageData.data.buffer)
    alpha = (0xff << 24)
    i = @img_u8.cols * @img_u8.rows
    pix = 0
    while --i >= 0
      pix = @img_u8.data[i]
      data_u32[i] = alpha | (pix << 16) | (pix << 8) | pix
    @ctx.putImageData imageData, 0, 0


$ ->
  window.app = new App()

$(window).unload ->
  window.app.unload()
