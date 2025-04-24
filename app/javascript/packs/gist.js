function loadGist($container) {
  const url = $container.data('gist-url');
  if (!url) return;

  const gistId = url.split('/').pop();
  const file = url.includes('?file=') ? '&' + url.split('?')[1] : '';

  const iframe = document.createElement('iframe');
  iframe.width = '100%';
  iframe.frameBorder = 0;

  $container.empty().append(iframe);

  const doc = iframe.contentDocument || iframe.contentWindow.document;
  const gistScript = `<html><head><base target="_parent"></head><body><script type="text/javascript" src="${url}.js${file}"></script></body></html>`;

  doc.open();
  doc.write(gistScript);
  doc.close();
}

function initGists(scope = document) {
  $(scope).find('.gist-container').each(function () {
    loadGist($(this));
  });
}

// при загрузке страницы
$(document).on('DOMContentLoaded', function () {
  initGists();
});

// экспорт функции для ручного вызова после AJAX
window.initGists = initGists;
