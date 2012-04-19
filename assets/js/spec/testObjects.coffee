describe "Object Models", ->
  beforeEach ->
    @objects = new patchosaur.Objects
  afterEach ->
    do @objects.clear

  it "can be created and removed from a collection", ->
    expect(@objects.length).toBe 0
    object = @objects.newObject text: 'cs "(x) -> 1"'
    expect(@objects.length).toBe 1
    @objects.remove object
    expect(@objects.length).toBe 0

  it "can be connected and disconnected", ->
    one = @objects.newObject text: 'cs "(x) -> x"'
    two = @objects.newObject text: 'cs "(x, y) -> x + y"'
    expect(one.connected(0, two.id, 0)).toBe false
    expect(one.connected(0, two.id, 1)).toBe false
    one.connect(0, two.id, 1)
    expect(one.connected(0, two.id, 0)).toBe false
    expect(one.connected(0, two.id, 1)).toBe true
    one.disconnect(0, two.id, 1)
    one.connect(0, two.id, 0)
    expect(one.connected(0, two.id, 0)).toBe true
    expect(one.connected(0, two.id, 1)).toBe false
    one.disconnect(0, two.id, 0)
    expect(one.connected(0, two.id, 0)).toBe false
    expect(one.connected(0, two.id, 1)).toBe false

  it "has default attributes assigned", ->
    object = @objects.newObject()
    expect(object.get 'text').toBeDefined()
    expect(object.get 'numInlets').toBeDefined()
    expect(object.get 'numOutlets').toBeDefined()
    expect(object.get 'x').toBeDefined()
    expect(object.get 'y').toBeDefined()
    # sanity
    expect(object.get 'aw44efaiw8333333').toBeUndefined()
