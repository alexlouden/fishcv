class Swarm
  REPEL_RADIUS: 40
  V_LIM: 5
  INV_CENTRE_INFLUENCE: 100
  INV_MATCH_INFLUENCE: 8
  INV_TEND_TO_INFLUENCE: 10

  constructor: (size, width, height) ->
    @size = size
    @boids = new Float32Array(size * 2 + 1)
    @boids_velocity = new Float32Array(size * 2 + 1)
    @focus_point = [200, 200]
    @init_positions width, height

  init_positions: (width, height) ->
    for b in [0 .. @size - 1] by 1
      x = Math.random() * width
      y = Math.random() * height
      @boids[b << 1] = Math.round(x)
      @boids[(b << 1) + 1] = Math.round(y)

    return

  distanceBetween: (p1, p2) ->
    n = (p1[0] - p2[0]) * (p1[0] - p2[0]) +
      (p1[1] - p2[1]) * (p1[1] - p2[1])
    return n

  getMagnitude: (vector) ->
    n = vector[0] * vector[0] + vector[1] * vector[1]
    n = Math.sqrt(n)
    return n

  setFocus: (x, y) ->
    @focus_point[0] = x
    @focus_point[1] = y

  # Updates position and velocities of all the boids.
  update_boids: ->
    for b in [0 .. @size - 1] by 1
      boidPosition = [@boids[b << 1], @boids[(b << 1) + 1]]
      boidVelocity = [@boids_velocity[b << 1], @boids_velocity[(b << 1) + 1]]
      sumPositions = [0, 0]
      sumVelocities = [0, 0]
      sumDifferences = [0, 0]

      for other in [0 .. @size - 1] by 1 when other isnt b

        otherPosition = [@boids[other << 1], @boids[(other << 1) + 1]]
        otherVelocity =
          [@boids_velocity[other << 1], @boids_velocity[(other << 1) + 1]]

        sumPositions[0] += otherPosition[0]
        sumPositions[1] += otherPosition[1]

        sumVelocities[0] += otherVelocity[0]
        sumVelocities[1] += otherVelocity[1]

        if @distanceBetween(boidPosition, otherPosition) < @REPEL_RADIUS * @REPEL_RADIUS
          sumDifferences[0] -= (otherPosition[0] - boidPosition[0])
          sumDifferences[1] -= (otherPosition[1] - boidPosition[1])

      forces = []
      # vector giving tendancy for the fish to group together
      center = (n / (@size - 1) for n in sumPositions)
      toCenter =
        [(center[0] - boidPosition[0]) / @INV_CENTRE_INFLUENCE,
        (center[1] - boidPosition[1]) / @INV_CENTRE_INFLUENCE]
      forces.push(toCenter)

      # vector for tendency for fish not to run into each other
      forces.push(sumDifferences)

      # fish will try to match the velocity of fish around them
      averageVelocity = (n / (@size - 1) for n in sumVelocities)
      averageVelocity =
        [averageVelocity[0] - boidVelocity[0],
        averageVelocity[1] - boidVelocity[1]]
      match = (n / @INV_MATCH_INFLUENCE for n in averageVelocity)
      forces.push(match)

      # fish will tend towards a point
      forces.push(@tend_to_point(b, @focus_point))
      
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