
class Video
  # Takes video stream and puts it in a video element
  # When it has video it calls the ready function
  constructor: (@ready) ->
    @video_el = $('#webcam')[0]

    # canvas and context
    @canvas = $('canvas')[0]
    @ctx = @canvas.getContext("2d")
    @ctx.fillStyle = "rgb(0,255,0)"
    @ctx.strokeStyle = "rgb(0,255,0)"

    # @colour_frame = new jsfeat.pyramid_t(4)
    # @colour_frame.allocate 640, 480, jsfeat.U8_t | jsfeat.C1_t

    @grey_frame = new jsfeat.matrix_t(640, 480, jsfeat.U8_t | jsfeat.C1_t)

    compatibility.getUserMedia video: true, @handleVideo

  handleVideo: (stream) =>
    try
      @video_el.src = compatibility.URL.createObjectURL(stream)
    catch error
      @video_el.src = stream

    setTimeout @ready, 500
    return

  unload: ->
    @video_el.pause()
    @video_el.src = null
    return

  get_gray_frame: =>

    if @video_el.readyState is not @video_el.HAVE_ENOUGH_DATA
      return

    # video onto canvas
    @ctx.drawImage @video_el, 0, 0, 640, 480
    # get canvas colour image
    @colour_frame = @ctx.getImageData(0, 0, 640, 480)

    jsfeat.imgproc.grayscale @colour_frame.data, @grey_frame.data

    return @grey_frame

  play: =>
    @video_el.play()


class App
  constructor: ->
    @canvas2 = $('#canvas2')[0]
    @video = new Video(@video_ready)

  video_ready: =>

    @video.play()
    
    # Prepare canvas and image frames
    @ctx2 = @canvas2.getContext("2d")

    @background = new jsfeat.matrix_t(640, 480, jsfeat.U8_t | jsfeat.C1_t)
    @difference = new jsfeat.matrix_t(640, 480, jsfeat.U8_t | jsfeat.C1_t)

    # Used for drawing to canvas
    @imagedata = new jsfeat.pyramid_t(4)
    @imagedata.allocate 640, 480, jsfeat.U8_t | jsfeat.C1_t

    # First loop
    @first = true

    # Start processing
    compatibility.requestAnimationFrame @process_frame
    return
  
  process_frame: =>
    compatibility.requestAnimationFrame @process_frame

    frame = @video.get_gray_frame()

    @equalize_histogram(frame)
    @blur_image(frame, 5)

    if @first
      console.log 'running first'
      @background.data.set frame.data
      @first = false

    @equalize_histogram(@background)

    @average_background(frame)
    @blur_image(@difference, 5)

    # @detect_edges()
    
    @render(@video.ctx, @background)
    @render(@ctx2, @difference)

  equalize_histogram: (src) =>
    jsfeat.imgproc.equalize_histogram src.data, src.data

  blur_image: (src, blur_radius) =>
    kernel_size = (blur_radius + 1) << 1
    sigma = 0
    jsfeat.imgproc.gaussian_blur src, src, kernel_size, sigma

  average_background: (src) =>

    # how fast background averages
    f = 0.99

    # Difference threshold
    thresh = 0.1 * 255

    for i in [0 .. src.data.length]
      bg_colour = @background.data[i]
      fg_colour = src.data[i]

      if @difference.data[i] == 0
        @background.data[i] = (bg_colour * f) + (fg_colour * (1 - f))
      
      diff = Math.abs(bg_colour - fg_colour)

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
    alpha = (0xff << 24)
    i = src.cols * src.rows
    frame = @video.colour_frame
    data_u32 = new Uint32Array(frame.data.buffer)
    pix = 0
    while --i >= 0
      pix = src.data[i]
      data_u32[i] = alpha | (pix << 16) | (pix << 8) | pix
    ctx.putImageData frame, 0, 0

$ ->
  window.app = new App()

$(window).unload ->
  window.app.unload()
