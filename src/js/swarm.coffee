class Swarm
  REPEL_RADIUS: 40
  V_LIM: 5
  INV_CENTRE_INFLUENCE: 100
  INV_MATCH_INFLUENCE: 8
  INV_TEND_TO_INFLUENCE: 10
  GRID_WIDTH: 20

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

      neighbours = kdtree.nearest(boid, 10)
      for n in neighbours
        centre.add(n[0])

      centre.scale(1/ neighbours.length)

      forces = []

      boid.velocity.add(
        x: (centre.x - boid.x) / 100
        y: (centre.y - boid.y) / 100
      )

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

  tend_to_point: (boid,  point) ->
    r = []
    r[0] = (point.x - boid.x) / @INV_TEND_TO_INFLUENCE
    r[1] = (point.y - boid.y) / @INV_TEND_TO_INFLUENCE
    return new Vector(r[0], r[1])