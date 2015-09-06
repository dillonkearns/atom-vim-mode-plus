# Refactoring status: 100%

{debug} = require './utils'
emoji = require 'emoji-images'
emojiFolder = 'atom://vim-mode/node_modules/emoji-images/pngs'
settings = require './settings'

class Hover
  lineHeight: null

  constructor: (@vimState) ->
    @text = []
    @view = atom.views.getView(this)

  add: (text) ->
    @text.push text
    @view.show()

  getText: ->
    minLengthToDisplay = 1
    # minLengthToDisplay =
    #   switch
    #     when ':clipboard:' in @text then 3
    #     when ':scissors:' in @text then 3
    #     else  1
    return if @text.length < minLengthToDisplay
    @text.join('')

  reset: ->
    @text = []
    @view.reset()

  destroy: ->
    @vimState = null
    @view.destroy()

class HoverElement extends HTMLElement
  createdCallback: ->
    @classList.add 'vim-mode-hover'
    this

  initialize: (@model) ->
    @style.paddingLeft  = '0.2em'
    @style.paddingRight = '0.2em'
    @style.marginLeft   = '-0.2em'
    this

  emojify: (text, size) ->
    emoji(String(text), emojiFolder, size)

  show: ->
    return unless settings.get('enableHoverIndicator')
    unless text = @model.getText()
      return
    {editor} = @model.vimState

    unless @marker
      @createOverlay()
      @lineHeight = editor.getLineHeightInPixels()

    # [FIXME] now investigationg overlay position become wrong
    # randomly happen.
    # console.log  @marker.getBufferRange().toString()
    @style.marginTop = (@lineHeight * -2) + 'px'
    @innerHTML = @emojify(text, @lineHeight * 0.9 + 'px')

  createOverlay: ->
    {editor} = @model.vimState
    point = editor.getCursorBufferPosition()
    @marker = editor.markBufferPosition point,
      invalidate: "never",
      persistent: false

    decoration = editor.decorateMarker @marker,
      type: 'overlay'
      item: this

  reset: ->
    @textContent = ''
    @marker?.destroy()
    @marker = null
    @lineHeight = null

  destroy: ->
    @model = null
    @lineHeight = null
    @marker?.destroy()
    @remove()

HoverElement = document.registerElement 'vim-mode-hover',
  prototype: HoverElement.prototype
  extends:   'div'

module.exports = {
  Hover, HoverElement
}
