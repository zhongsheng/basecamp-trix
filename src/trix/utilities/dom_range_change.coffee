#= require trix/utilities/dom
#= require trix/utilities/helpers

{DOM} = Trix
{memoize} = Trix.Helpers

class Trix.DOMRangeChange
  constructor: ({@range, @previousRange, @element}) ->

  needsAdjustment: ->
    @canAdjust() and (@isntEditable() or @containsCursorTarget())

  canAdjust: ->
    if @getDirection() is "backward"
      if @element.contains(@range.startContainer)
        firstNode = @element.firstChild ? @element
        firstNode = firstNode.firstChild while firstNode.firstChild
        @range.startContainer isnt firstNode
    else
      if @element.contains(@range.endContainer)
        lastNode = @element.lastChild ? @element
        lastNode = lastNode.lastChild while lastNode.lastChild
        @range.endContainer isnt lastNode

  containsCursorTarget: ->
    range = document.createRange()
    range.setStart(@getStartContainerAndOffset()...)
    range.setEnd(@getEndContainerAndOffset()...)

    contents = range.cloneContents()
    contents.normalize()
    contents.childNodes.length is 1 and contents.firstChild.textContent is Trix.ZERO_WIDTH_SPACE

  isntEditable: ->
    focusElement = DOM.findElementForContainerAtOffset(@getFocusContainerAndOffset()...)
    not focusElement?.isContentEditable

  getDirection: memoize ->
    if @range.compareBoundaryPoints(Range.START_TO_START, @previousRange) is -1
      "backward"
    else if @range.compareBoundaryPoints(Range.END_TO_END, @previousRange) is 1
      "forward"

  getStartContainerAndOffset: ->
    if @getDirection() is "backward"
      [@range.startContainer, @range.startOffset]
    else
      [@previousRange.endContainer, @previousRange.endOffset]

  getEndContainerAndOffset: ->
    if @getDirection() is "backward"
      [@previousRange.startContainer, @previousRange.startOffset]
    else
      [@range.endContainer, @range.endOffset]

  getFocusContainerAndOffset: ->
    if @getDirection() is "backward"
      [@range.startContainer, @range.startOffset]
    else
      [@range.endContainer, @range.endOffset]
