class Swarm
  SQ_REPEL_RADIUS: 20 * 20
  V_LIM: 5
  CENTRE_INFLUENCE: 1 / 1000
  MATCH_INFLUENCE: 1 / 40
  TEND_TO_INFLUENCE: 1 / 100000
  REPEL_INFLUENCE: 1 / 100
  GRID_WIDTH: 20
  SQ_NEIGHBOUR_SEARCH_DIST: 30 * 30
  MAX_NEIGHBOURS: 30
  WRAP_RADIUS: 40
  EDGE_FORCE: 0.25

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

      neighbours = kdtree.nearest(boid, @MAX_NEIGHBOURS, @SQ_NEIGHBOUR_SEARCH_DIST)
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
      #force of boids tending to 'clump' together
      boid.velocity.add(
        x: (centre.x - boid.x) * @CENTRE_INFLUENCE
        y: (centre.y - boid.y) * @CENTRE_INFLUENCE
      )

      # boids don't want to run into each other
      repel.scale(@REPEL_INFLUENCE)
      boid.velocity.add(repel)

      # boids will tend to match the velocity of nearby boids
      boid.velocity.add(
        x: (avVelocities.x - boid.velocity.x) * @MATCH_INFLUENCE
        y: (avVelocities.y - boid.velocity.y) * @MATCH_INFLUENCE
      )

      # boids will tend towards a location
      boid.velocity.add(@tendToFocus(boid))

      # limit the velocity so they don't speed up continuously
      boid.add(boid.velocity)
      @wrapPosition(boid)
      @limitVelocity(boid)

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
      x: (@focus_point.x - boid.x) * @TEND_TO_INFLUENCE
      y: (@focus_point.y - boid.y) * @TEND_TO_INFLUENCE
    return vector

  wrapPosition: (boid) ->
    if boid.x > @width - @WRAP_RADIUS
      boid.velocity.x -= @EDGE_FORCE

    if boid.y > @height - @WRAP_RADIUS
      boid.velocity.y -= @EDGE_FORCE

    if boid.x < @WRAP_RADIUS
      boid.velocity.x += @EDGE_FORCE

    if boid.y < @WRAP_RADIUS
      boid.velocity.y += @EDGE_FORCE

  makeRandomVector: ->
    x = Math.floor(Math.random() * 10)
    y = Math.floor(Math.random() * 10)
    v = new Vector(x, y)
    v.scale(@V_LIM / v.magnitude())
    return v