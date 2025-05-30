import consumer from "./consumer"

$(document).on('DOMContentLoaded ready page:load', function () {
  const $question = $('#question-show[data-question-id]')
  if (!$question.length) return

  const questionId = $question.data('question-id')

  consumer.subscriptions.create(
    { channel: "QuestionChannel", id: questionId },
    {
      received(data) {
        if (data.answer) {
          $('.answers').append(data.answer)
        }
      }
    }
  )
})
