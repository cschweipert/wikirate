window.deckorate = {}


$(window).ready ->
  $("body").on "click", "a.card-paging-link", ->
    id = $(this).slot().attr("id")
    #unless history.state?
    #  history.replaceState(slot_id: id, "")
    history.pushState(slot_id: id, url: this.href, "", location.href);

  # TODO: consider moving above to decko

  $(".new-metric").on "click", ".metric-type-list .box", (e) ->
    params =
      card:
        fields:
          ":metric_type": $(this).data("cardLinkName")
    window.location = decko.path "new/Metric?#{$.param params}"
    e.stopImmediatePropagation()
    e.preventDefault()

  $("body").on "click", "._filter-year-field input", ->
    box = $(this)
    siblings = box.parent().siblings()
    if box.val() == "latest"
      siblings.find("input").prop "checked", false if box.is(":checked")
    else
      siblings.find("input[value='latest']").prop "checked", false
