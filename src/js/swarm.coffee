class Swarm
  REPEL_RADIUS: 20
  V_LIM: 5
  INV_CENTRE_INFLUENCE: 100
  INV_MATCH_INFLUENCE: 8
  INV_TEND_TO_INFLUENCE: 10

  constructor: (size, width, height) ->
    @size = size
    @boids = new Float32Array(size * 2 + 1)
    @boids_velocity = new Float32Array(size * 2 + 1)
    @init_positions width, height

  init_positions: (width, height) ->
    for b in [0 .. @size - 1] by 1
      x = Math.random() * width
      y = Math.random() * height
      @boids[b << 1] = Math.round(x)
      @boids[(b << 1) + 1] = Math.round(y)

    return

  distanceBetween: (x1, y1, x2, y2) ->
    n = (x1 - x2) * (x1 - x2) +
      (y1 - y2) * (y1 - y2)
    return Math.sqrt(n)

  getMagnitude: (vector) ->
    n = vector[0] * vector[0] + vector[1] * vector[1]
    n = Math.sqrt(n)
    return n

  # Updates position and velocities of all the boids.
  update_boids: ->
    for b in [0 .. @size - 1] by 1
      forces = []
      forces.push(@move_to_centre(b))
      forces.push(@repel_other(b))
      forces.push(@match_nearby(b))
      forces.push(@tend_to_point(b, [600, 500]))
      
      # Sum the force vectors
      f = [0, 0]
      for frc in forces
        f[0] += frc[0]
        f[1] += frc[1]

      @boids_velocity[b << 1] += f[0]
      @boids_velocity[(b << 1) + 1] += f[1]
      @limit_velocity(b)

      # now update that position!
      p = b << 1
      @boids[p] += @boids_velocity[p]
      @boids[p + 1] += @boids_velocity[p + 1]

    return

  # Adds a tendancy for boids to fly towards the centre of the group
  move_to_centre: (boid) ->
    # finding centre
    x = 0
    y = 0

    for i in [0 .. @size - 1] by 1 when i isnt boid
      x += @boids[i << 1]
      y += @boids[(i << 1) + 1]

    x = x / (@size - 1)
    y = y / (@size - 1)

    bX = @boids[boid << 1]
    bY = @boids[(boid << 1) + 1]

    diff = [(x - bX) / @INV_CENTRE_INFLUENCE, (y - bY) / @INV_CENTRE_INFLUENCE]

    return diff

  # Tendancy for boids to keep seperated a little
  repel_other: (boid) ->
    res = [0, 0]
    bX = @boids[boid << 1]
    bY = @boids[(boid << 1) + 1]

    for b in [0 .. @size - 1] by 1 when b isnt boid
      x = @boids[b << 1]
      y = @boids[(b << 1) + 1]

      if @distanceBetween(bX, bY, x, y) < @REPEL_RADIUS
        res[0] -= (x - bX)
        res[1] -= (y - bY)

    return res

  # Boids will try to match the velocity of those boids around them
  match_nearby: (boid) ->
    v = [0, 0]

    for b in [0 .. @size - 1] by 1 when b isnt boid
      v[0] += @boids_velocity[boid << 1]
      v[1] += @boids_velocity[(boid << 1) + 1]

    v[0] = v[0] / (@size - 1)
    v[1] = v[1] / (@size - 1)
    v[0] -= @boids[boid << 1]
    v[1] -= @boids[(boid << 1) + 1]

    v = (n / @INV_MATCH_INFLUENCE for n in v)
    return v


  # limits the velocity so that the boids can't go arbitrarily fast.
  limit_velocity: (boid) ->
    v = [@boids_velocity[boid << 1], @boids_velocity[(boid << 1) + 1]]
    mag = @getMagnitude(v)
    if mag > @V_LIM
      @boids_velocity[boid << 1] = @boids_velocity[boid << 1] /  mag * @V_LIM
      @boids_velocity[(boid << 1) + 1] =
        @boids_velocity[(boid << 1) + 1] / mag * @V_LIM

  tend_to_point: (boid,  point) ->
    b = [@boids[boid << 1], @boids[(boid << 1) + 1]]
    r = []
    r[0] = (point[0] - b[0]) / @INV_TEND_TO_INFLUENCE
    r[1] = (point[1] - b[1]) / @INV_TEND_TO_INFLUENCE
    return r