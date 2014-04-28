class Vector
  constructor: (x, y) ->
    @x = x
    @y = y

  scale: (v) ->
    @x *= v
    @y *= v
    return

  magnitude: ->
    return Math.sqrt(@x * @x + @y * @y)

  add: (that) ->
    @x += that.x
    @y += that.y
    return

  subtract: (that) ->
    @x -= that.x
    @y -= that.y
    return

class Point extends Vector
  constructor: (x, y) ->
    @x = x
    @y = y

  squaredDistanceTo: (that) ->
    return Math.pow((@x - that.x), 2) + Math.pow((@y - that.y), 2)