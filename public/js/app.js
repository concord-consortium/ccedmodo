// JS for ccedmodotest

$(document).ready(function() {
  $('#select-interactive').on('change', function() {
    var interactive = $(this).val();

    $('#interactive-iframe').attr('src', 'http://lab.dev.concord.org/examples/interactives/embeddable.html#'+interactive);
    $('input[name="interactive"]').val(interactive);
  }).trigger('change');
});