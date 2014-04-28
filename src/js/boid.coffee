class Boid
  constructor: (x, y) ->
    @x = x
    @y = y
    @velocity = new Vector(0, 0)

  setPosition: (x, y) ->
    @position.x = x
    @position.y = y

  setVelocity: (i, j) ->
    @velocity.x = i
    @velocity.y = j

  squaredDistanceTo: (that) ->
    return Math.pow((@x - that.x), 2) + Math.pow((@y - that.y), 2)

  add: (v) ->
    @x += v.x
    @y += v.y
    return