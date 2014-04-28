class Swarm
  SQ_REPEL_RADIUS: 20 * 20
  V_LIM: 5
  INV_CENTRE_INFLUENCE: 100
  INV_MATCH_INFLUENCE: 8
  INV_TEND_TO_INFLUENCE: 100
  GRID_WIDTH: 20
  SQ_NEIGHBOUR_SEARCH_DIST: 20 * 20

  constructor: (size, width, height) ->
    @size = size
    @boids = @initialiseBoids(width, height)
    @focus_point = new Point(0, 0)
    @width = width
    @height = height

  initialiseBoids: (width, height) ->
    boids = []
    for b in [0 .. @size - 1] by 1
      x = Math.random() * width
      y = Math.random() * height
      boids[b] = new Boid(x, y)

    return boids

  setFocus: (x, y) ->
    @focus_point.x = x
    @focus_point.y = y

  distanceMetric: (a, b) ->
    return Math.pow(a.x - b.x, 2) +
    Math.pow(a.y - b.y, 2)

  # Updates position and velocities of all the boids.
  update_boids: ->
    kdtree = new kdTree(@boids, @distanceMetric, ["x", "y"])
    for boid in @boids
      centre = new Vector(0, 0)
      repel = new Vector(0, 0)
      avVelocities = new Vector(0, 0)

      neighbours = kdtree.nearest(boid, 100, @SQ_NEIGHBOUR_SEARCH_DIST)
      for n in neighbours
        # calculating the centre of the boids neighbours.
        centre.add(n[0])

        # add the vector between nearby neighbours.
        if boid.squaredDistanceTo(n[0]) < @SQ_REPEL_RADIUS
          repel.add(
            x: boid.x - n[0].x
            y: boid.y - n[0].y
          )

        # will be averaging the velocities of the neibour boids
        avVelocities.add(n[0].velocity)

      centre.scale(1/ neighbours.length)
      avVelocities.scale(1 / neighbours.length)

      forces = []

      # sum the forces on the boid
      boid.velocity.add(
        x: (centre.x - boid.x) / @INV_CENTRE_INFLUENCE
        y: (centre.y - boid.y) / @INV_CENTRE_INFLUENCE
      )
      boid.velocity.add(repel)
      boid.velocity.add(
        x: (avVelocities.x - n[0].velocity.x) / @INV_MATCH_INFLUENCE
        y: (avVelocities.y - n[0].velocity.y) / @INV_MATCH_INFLUENCE
      )
      boid.velocity.add(@tendToFocus(boid))

      # limit the velocity so they don't speed up continuously
      @limitVelocity(boid)
      boid.add(boid.velocity)

    return

  # limits the velocity so that the boids can't go arbitrarily fast.
  limitVelocity: (boid) ->
    mag = boid.velocity.magnitude()
    if mag > @V_LIM
      boid.velocity.scale(@V_LIM / mag)

  calculateAverages: (list) ->
    vectors = [
      new Vector(0, 0),
      new Vector(0, 0)
    ]
    for v in list
      vectors[0].add(v[0])
      vectors[1].add(v[0].velocity)

    return vectors

  tendToFocus: (boid) ->
    vector =
      x: (@focus_point.x - boid.x) / @INV_TEND_TO_INFLUENCE
      y: (@focus_point.y - boid.y) / @INV_TEND_TO_INFLUENCE
    return vector