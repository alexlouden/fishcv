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
    @canvas2 = $('#canvas2')[0]

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
    
    @ctx2 = @canvas2.getContext("2d")

    img_pyr = new jsfeat.pyramid_t(4)
    img_pyr.allocate 640, 480, jsfeat.U8_t | jsfeat.C1_t

    @background = new jsfeat.matrix_t(640, 480, jsfeat.U8_t | jsfeat.C1_t)
    @difference = new jsfeat.matrix_t(640, 480, jsfeat.U8_t | jsfeat.C1_t)

    @first = true

    return
  
  tick: =>
    compatibility.requestAnimationFrame @tick

    if @video.readyState is not @video.HAVE_ENOUGH_DATA
      return

    # video onto canvas
    @ctx.drawImage @video, 0, 0, 640, 480
    # get canvas colour image
    @imageData = @ctx.getImageData(0, 0, 640, 480)
    
    # colour image (imagedata) to grey (img_u8)
    @grayscale()

    @equalize_histogram(@img_u8)
    @blur_image(5)

    if @first
      console.log 'running first'
      @background.data.set @img_u8.data
      @first = false

    @equalize_histogram(@background)

    @average_background(@img_u8)

    # @detect_edges()
    
    @render(@ctx, @background)
    @render(@ctx2, @difference)

  grayscale: =>
    jsfeat.imgproc.grayscale @imageData.data, @img_u8.data

  equalize_histogram: (src) =>
    jsfeat.imgproc.equalize_histogram src.data, src.data

  blur_image: (blur_radius) =>
    kernel_size = (blur_radius + 1) << 1
    sigma = 0
    jsfeat.imgproc.gaussian_blur @img_u8, @img_u8, kernel_size, sigma

  average_background: (src) =>

    # how fast background averages
    f = 0.96

    # Difference threshold
    thresh = 0.1 * 255

    for i in [0 .. src.data.length]
      bg_colour = @background.data[i]
      fg_colour = src.data[i]

      diff = Math.abs(bg_colour - fg_colour)
      
      if @difference.data[i] == 0
        @background.data[i] = (bg_colour * f) + (fg_colour * (1 - f))

      if diff > thresh
        @difference.data[i] = diff / 2 + 128
      else
        @difference.data[i] = 0

    return

  detect_edges: =>
    low_threshold = 40
    high_threshold = 80
    jsfeat.imgproc.canny @img_u8, @img_u8,
      low_threshold, high_threshold

  render: (ctx, src) =>
    # draw data to canvas
    data_u32 = new Uint32Array(@imageData.data.buffer)
    alpha = (0xff << 24)
    i = src.cols * src.rows
    pix = 0
    while --i >= 0
      pix = src.data[i]
      data_u32[i] = alpha | (pix << 16) | (pix << 8) | pix
    ctx.putImageData @imageData, 0, 0

$ ->
  window.app = new App()

$(window).unload ->
  window.app.unload()
