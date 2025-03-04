$(document).on('click', '.edit-question-link', function(e) {
  e.preventDefault();
  const questionId = $(this).data('questionId');
  $(`#edit-question-${questionId}`).toggleClass('hidden');
});

