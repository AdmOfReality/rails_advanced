$(document).on('ajax:success', '.vote-controls a', function(event) {
  const [data, status, xhr] = event.detail;
  const container = $(this).closest('.vote-controls');
  const votableType = container.data('votable-type');
  const votableId = container.data('votable-id');

  container.find('.vote-error').remove();

  if (data.rating !== undefined) {
    $(`#rating-${votableType}-${votableId}`).text(data.rating);
  }

  container.removeClass('vote-error-state');
});

$(document).on('ajax:error', '.vote-controls a', function(event) {
  const [data, status, xhr] = event.detail;
  const container = $(this).closest('.vote-controls');

  container.find('.vote-error').remove();

  const errorMessage = data?.error || 'Something went wrong';

  const errorHtml = `<div class="vote-error" style="color: red; margin-top: 5px;">${errorMessage}</div>`;
  container.append(errorHtml);

  container.addClass('vote-error-state');
});
