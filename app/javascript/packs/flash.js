$(document).ready(function() {
  $(document).on("click", ".flash", function() {
    $(this).fadeOut(500, function() {
      $(this).remove();
    });
  });
});
