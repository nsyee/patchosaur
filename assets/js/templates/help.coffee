patchosaur = @patchosaur ?= {}

patchosaur.templates = {}

# compiled
patchosaur.templates.help = _.template '''
<div class="modal" id="modalHelp">
    <div class="modal-header">
        <a class="close" data-dismiss="modal">×</a>
        <h3>patchosaur help</h3>
    </div>
    <div class="modal-body">
        <p>
        Press 'h' to toggle help.
        Double click to create a new object or to edit an existing one.
        To connect an inlet to and outlet, click an outlet (it should pulse),
        then click the inlet.
        To move an object, drag it.
        </p>
        <p>
          To remove an object:
          <ul>
            <li>On a Mac: alt-click on it</li>
            <li>Linx: ctrl-click on it</li>
          </ul>
        </p>
        <p>
          List of objects loaded:
          <ul>
              <% _.each(patchosaur.units.units, function (unit, name, x) {  %>
                  <li><%= name %></li>
              <% }); %>
          </ul>
        </p>
    </div>
    <div class="modal-footer">
        <a data-dismiss="modal" class="btn">Close</a>
    </div>
</div>
'''
