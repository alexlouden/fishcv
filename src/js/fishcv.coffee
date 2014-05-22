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

    # @video = $('#webcam')[0]
    @canvas = $('canvas')[0]

    # @imageData = new jsfeat.matrix_t(640, 480, jsfeat.U8_t | jsfeat.C1_t)
    # @swarm = new Swarm(20, @canvas.width, @canvas.height)

    # compatibility.getUserMedia video: true, @handleVideo

    @doFish()

  # handleVideo: (stream) =>
  #   try
  #     @video.src = compatibility.URL.createObjectURL(stream)
  #   catch error
  #     @video.src = stream

  #   setTimeout @step, 500
  #   return

  # step: =>
  #   @video.play()
  #   @doFish()
  #   compatibility.requestAnimationFrame @tick
  #   return

  unload: ->
    @video.pause()
    @video.src = null
    return

  doFish: ->

    @ctx = @canvas.getContext("2d")
    @ctx.fillStyle = "rgb(0,255,0)"
    @ctx.strokeStyle = "rgb(0,255,0)"

    @draw_fish 200, 200, 0

  draw_fish: (x, y, direction) ->

    width = 40
    height = 200

    tail_offset = 0.07 # Ratio of height
    tail_width = 0.7 # Ratio of width

    tail_1_x = x + width * tail_width
    tail_1_y = y + height * (1 + tail_offset)

    tail_2_x = x - width * tail_width
    tail_2_y = y + height * (1 - tail_offset)

    @ctx.beginPath()
    @ctx.moveTo tail_1_x, tail_1_y

    cp1_x = x - width/2
    cp1_y = y + height/2
    cp2_x = x - width
    cp2_y = y

    @ctx.bezierCurveTo cp1_x, cp1_y, cp2_x, cp2_y, x, y

    cp1_x = x + width
    cp1_y = y
    cp2_x = x + width/2  * 1.4 # Magic numbers to make
    cp2_y = y + height/2 * 1.1 # fish body more even

    @ctx.bezierCurveTo cp1_x, cp1_y, cp2_x, cp2_y, tail_2_x, tail_2_y

    @ctx.lineTo tail_1_x, tail_1_y

    # Center line
    # @ctx.moveTo x, y - 20
    # @ctx.lineTo x, y + height + 20

    @ctx.stroke()
    return


  #   @curr_img_pyr = new jsfeat.pyramid_t(3)
  #   @prev_img_pyr = new jsfeat.pyramid_t(3)
  #   @curr_img_pyr.allocate 640, 480, jsfeat.U8_t | jsfeat.C1_t
  #   @prev_img_pyr.allocate 640, 480, jsfeat.U8_t | jsfeat.C1_t

  #   @point_count = 0
  #   @point_status = new Uint8Array(100)
  #   @prev_xy = new Float32Array(100 * 2)
  #   @curr_xy = new Float32Array(100 * 2)

  #   @options =
  #     win_size: 20
  #     max_iterations: 30
  #     epsilon: 0.01
  #     min_eigen: 0.001

  #   return
  
  # tick: =>
  #   compatibility.requestAnimationFrame @tick

  #   if @video.readyState is not @video.HAVE_ENOUGH_DATA
  #     return

  #   @ctx.drawImage @video, 0, 0, 640, 480
  #   @imageData = @ctx.getImageData(0, 0, 640, 480)
    
  #   # @blur_image(5)
  #   # @detect_edges()

  #   # swap flow data
  #   [@prev_xy, @curr_xy] = [@curr_xy, @prev_xy]
  #   [@prev_img_pyr, @curr_img_pyr] = [@curr_img_pyr, @prev_img_pyr]

  #   @grayscale()
  #   @equalize_histogram()

  #   @draw_boids()
  #   @swarm.update_boids()

  #   # @render()
  #   @optical_flow()

  # grayscale: ->
  #   jsfeat.imgproc.grayscale @imageData.data, @curr_img_pyr.data[0].data

  # equalize_histogram: ->
  #   jsfeat.imgproc.equalize_histogram(
  #     @curr_img_pyr.data[0].data, @curr_img_pyr.data[0].data
  #   )

  # add_tracking_points: =>

  #   if @point_count > 50
  #     return

  #   canvasWidth = @canvas.width
  #   canvasHeight = @canvas.height
  #   for x in [0..10]
  #     for y in [0..10]
  #       @add_tracking_point(canvasWidth/10*x, canvasWidth/10*y)

  #   return

  # add_tracking_point: (x, y) ->

  #   @curr_xy[@point_count<<1] = x
  #   @curr_xy[(@point_count<<1)+1] = y

  #   @point_count++

  # optical_flow: ->
  #   @curr_img_pyr.build @curr_img_pyr.data[0], true

  #   jsfeat.optical_flow_lk.track(
  #     @prev_img_pyr, @curr_img_pyr,
  #     @prev_xy, @curr_xy,
  #     @point_count,
  #     @options.win_size, @options.max_iterations,
  #     @point_status, @options.epsilon, @options.min_eigen
  #   )

  #   @prune_oflow_points()
  #   @add_tracking_points()

  # # blur_image: (blur_radius) =>
  # #   kernel_size = (blur_radius + 1) << 1
  # #   sigma = 0
  # #   jsfeat.imgproc.gaussian_blur @curr_img_pyr, @curr_img_pyr,
  # # kernel_size, sigma

  # # detect_edges: =>
  # #   low_threshold = 40
  # #   high_threshold = 80
  # #   jsfeat.imgproc.canny @imageData, @imageData,
  # #     low_threshold, high_threshold

  # prune_oflow_points: ->
  #   # ugh
  #   n = @point_count
  #   i = 0
  #   j = 0
  #   while i < n
  #     if @point_status[i] is 1
  #       if j < i
  #         @curr_xy[j << 1] = @curr_xy[i << 1]
  #         @curr_xy[(j << 1) + 1] = @curr_xy[(i << 1) + 1]
  #       @draw_circle @curr_xy[j << 1], @curr_xy[(j << 1) + 1]
  #       ++j
  #     ++i
  #   @point_count = j
  #   return

  # draw_circle: (x, y) ->
  #   @ctx.beginPath()
  #   @ctx.arc x, y, 4, 0, Math.PI * 2, true
  #   @ctx.closePath()
  #   @ctx.fill()

  # draw_boids: ->
  #   console.log "Boids!"
  #   @ctx.fillStyle = "rgb(255,0,0)"
  #   @ctx.strokeStyle = "rgb(255,0,0)"
  #   for i in [0 .. @swarm.size - 1] by 1
  #     x = @swarm.boids[i << 1]
  #     y = @swarm.boids[(i << 1) + 1]
  #     @draw_circle x, y
  #     # @draw_fish x, y

  #   @ctx.fillStyle = "rgb(0,255,0)"
  #   @ctx.strokeStyle = "rgb(0,255,0)"
  #   return

  # render: =>
  #   # draw data to canvas
  #   data_u32 = new Uint32Array(@imageData.data.buffer)
  #   alpha = (0xff << 24)
  #   i = @curr_img_pyr.cols * @curr_img_pyr.rows
  #   pix = 0
  #   while --i >= 0
  #     pix = @curr_img_pyr.data[i]
  #     data_u32[i] = alpha | (pix << 16) | (pix << 8) | pix
  #   @ctx.putImageData @imageData, 0, 0

$ ->
  window.app = new App()

$(window).unload ->
  window.app.unload()
