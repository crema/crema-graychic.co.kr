class Reviews
  collapse = ($review_content, complete) ->
    $collapsed = $review_content.find(".review-content-collapsed").css(opacity: 0)
    $expanded = $review_content.find(".review-content-expanded").css(opacity: 1)
    $review_content.height($expanded.height())
    setTimeout (->
      $review_content.addClass("expanding")
      lib.animation.fade_out $expanded, duration: "short"
      lib.animation.fade_in $collapsed, duration: "short", complete: ->
        $collapsed.css(opacity: 1)
        $expanded.css(opacity: 0)
        lib.animation.css $review_content, {
          from_css: {height: $expanded.height()},
          to_css: {height: $collapsed.height()},
          complete: ->
            $collapsed.css(opacity: "")
            $expanded.css(opacity: "")
            $review_content.removeClass("expanding expanded").css(height: "")
            complete() if complete
          }
      ), 1

app.reviews = new Reviews

$(document).on "form:validate:before.ClientSideValidations", "form.form-review", (e) ->
  $form = $(this)
  $review_message = $form.find("#review_message")
  default_message = $form.data("review-message-default")
  if default_message && $review_message.val() == default_message
    $review_message.val("")

add_score = ($review, delta_score, delta_total) ->
  $score = $review.find(".like-score")
  score = parseInt $score.text().replace(/\+\-/, "")
  score += delta_score
  if score > 0
    $score.text("+" + score)
  else if score < 0
    $score.text(score)
  else
    $score.text("0")

  $total = $review.find("strong.total")
  $total.text(parseInt($total.text()) + delta_total) if delta_total != 0

  if delta_total >= 0 && delta_score > 0
    $plus = $review.find("strong.plus")
    $plus.text(parseInt($plus.text()) + 1)
  else if delta_total <= 0 && delta_score < 0
    $plus = $review.find("strong.plus")
    $plus.text(parseInt($plus.text()) - 1)

$(document).on "click", "a.link-like", ->
  $like_action = $(this).closest(".like-action")
  liked = $like_action.hasClass("liked")
  unliked = $like_action.hasClass("unliked")
  if liked
    $like_action.removeClass("liked")
    final_score = 0
    delta_score = -1
    delta_total = -1
  else
    $like_action.addClass("liked")
    final_score = 1
    if unliked
      $like_action.removeClass("unliked")
      delta_score = 2
      delta_total = 0
    else
      delta_score = 1
      delta_total = 1

  add_score $like_action.closest(".panel-review"), delta_score, delta_total
  $.ajax({
    url: $like_action.data("url"),
    type: "post",
    data: {score: final_score}
  })

$(document).on "click", "a.link-unlike", ->
  $like_action = $(this).closest(".like-action")
  liked = $like_action.hasClass("liked")
  unliked = $like_action.hasClass("unliked")
  if unliked
    $like_action.removeClass("unliked")
    final_score = 0
    delta_score = 1
    delta_total = -1
  else
    $like_action.addClass("unliked")
    final_score = -1
    if liked
      $like_action.removeClass("liked")
      delta_score = -2
      delta_total = 0
    else
      delta_score = -1
      delta_total = 1

  add_score $like_action.closest(".panel-review"), delta_score, delta_total
  $.ajax({
    url: $like_action.data("url"),
    type: "post",
    data: {score: final_score}
  })

$(document).on "change", "input.input-file.one-image", ->
  if !image_field_validate($(this))
    return

  $input = $(this)[0]
  $preview_container = $(this).siblings(".preview-container")
  $preview = $preview_container.find("img.preview")
  if !lib.browser.supports_file_reader()
    if this.value
      $(this).siblings().find(".description").html(this.value.match(/[^\\]*\.(\w+)$/)[0])
  else
    if $input.files && $input.files[0]
      $(this).siblings().find(".description").html($input.files[0].name)

$(document).on "change", "select.select-rating", ->
  $this = $(this)
  if $this.val() == ""
    rating = 5
  else
    rating = parseInt($this.val())

  $stars = $this.closest(".score-container").find(".star-rating-container i")
  $stars.each (i) ->
    if i < rating
      $(this).removeClass("unstar").addClass("star")
    else
      $(this).removeClass("star").addClass("unstar")

$(document).on "change", "select#category", ->
  $.getScript($(this).val())

$(document).on "change", "select#sort", ->
  url = $.url($("#data-sort-type").data("url"))
  $.getScript url.attr("base") + url.attr("path") + "?" + $.param($.extend(url.param(), {sort: $(this).val()}))

$(document).on "click", ".link-close", ->
  if lib.ajax_util.is_in_progress()
    if confirm("아직 끝나지 않은 요청이 있습니다. 지금 닫으면 요청이 중단됩니다. 정말로 닫으시겠습니까?")
      window.location.href = $(this).attr("href")
    false

$(document).on "click", "a.link-edit", ->
  $this = $(this)
  $review = $this.closest(".review")
  if $review.hasClass("show-action")
    $review.removeClass("show-action")
  else
    $(".review").removeClass("show-action")
    $review.addClass("show-action")

$(document).on "click", ".photo-review-popup", ->
  app.window.photo_review_popup $(this).data("photo-review-popup-url")
