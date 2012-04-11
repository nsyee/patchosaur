# FIXME: require views and models

patchagogy = @patchagogy = @patchagogy or {}

patchagogy.routes = {}

patchagogy.routes.App = Backbone.Router.extend {
  routes:
    "index":       'index'
    "help":        'help'
    "help/:unit":  'help'
    "patch/:file": 'patch'
    # default
    "*path":       'index'

  index: () ->
    patchagogy.paper = Raphael("holder", "100%", "100%")
    patchagogy.objects = new patchagogy.Objects
    patchagogy.patchView = new patchagogy.PatchView
      objects: patchagogy.objects
    patchagogy.unitGraphView = new patchagogy.UnitGraphView
      objects: patchagogy.objects
    console.log 'created patch:', patchagogy.objects
    metrolite   = patchagogy.objects.newObject {x: 245, y: 100, text: 'metrolite 2000'}
    dump = patchagogy.objects.newObject {x: 230, y: 135, text: 'dump 10'}
    trig1 = patchagogy.objects.newObject {x: 250, y: 170, text: 'trigger 3'}
    cs1 = patchagogy.objects.newObject {x: 95, y: 210, text: 'cs "(x) -> x*x"'}
    cs2 = patchagogy.objects.newObject {x: 240, y: 214, text: 'cs "(x) -> x*x*x"'}
    cs3 = patchagogy.objects.newObject {x: 120, y: 254, text: 'cs "(x,y) -> x+y"'}
    cs4 = patchagogy.objects.newObject {x: 440, y: 210, text: 'cs "(b) -> @x = (@x or 0) + 1"'}
    print1 = patchagogy.objects.newObject {x: 70, y: 360, text: 'print "squared"'}
    print2 = patchagogy.objects.newObject {x: 270, y: 300, text: 'print "cubed"'}
    print3 = patchagogy.objects.newObject {x: 210, y: 330, text: 'print "cubed + squared"'}
    print4 = patchagogy.objects.newObject {x: 410, y: 256, text: 'print "ghetto counter"'}
    metrolite.connect(0, dump.id, 0)
    dump.connect(0, trig1.id, 0)
    trig1.connect(0, cs1.id, 0)
    trig1.connect(1, cs2.id, 0)
    trig1.connect(2, cs4.id, 0)
    cs1.connect(0, print1.id, 0)
    cs2.connect(0, print2.id, 0)
    cs1.connect(0, cs3.id, 0)
    cs2.connect(0, cs3.id, 1)
    cs3.connect(0, print3.id, 0)
    cs4.connect(0, print4.id, 0)
    patchagogy.objects.save()
}
