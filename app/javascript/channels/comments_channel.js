import consumer from "./consumer"

$(document).on('DOMContentLoaded', subscribe)
$(document).on('comments:subscribe', subscribe)

function subscribe() {
  $('.comments[data-commentable-type]').each(function() {
    const $element = $(this)
    if ($element.data('subscribed')) return

    const commentableType = $element.data('commentable-type')
    const commentableId = $element.data('commentable-id')

    consumer.subscriptions.create(
      { channel: "CommentsChannel", commentable_type: commentableType, commentable_id: commentableId },
      {
        received(data) {
          $element.append(data.html)
        }
      }
    )

    $element.data('subscribed', true)
  })
}

