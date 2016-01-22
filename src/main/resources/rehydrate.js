function() {
  $('body').append(
    $('<iframe src="' + location.toString() + '">')
      .attr('id', 'reload-iframe')
  );

  var newWindow = $('#reload-iframe')[0].contentWindow;
  function preventInitialCometTransaction() {
    if (newWindow.lift && typeof newWindow.lift.lift_cometEntry == 'function') {
      lift.lift_cometEntry = newWindow.lift.lift_cometEntry;
      newWindow.lift.lift_cometEntry = function() {}
    } else {
      os.nextTick(preventInitialCometTransaction)
    }
  }

  $('#reload-iframe').load(function() {
    var new_toWatch = newWindow.lift_toWatch;
    newWindow.lift_toWatch = {};
    var $newComets = newWindow.$('[data-lift-comet]');

    $('[data-lift-comet]').each(function(i) {
      this.outerHTML = $newComets[i].outerHTML;
    });

    lift_toWatch = new_toWatch;

    lift.lift_handlerSuccessFunc();
  });

  $('#reload-iframe').remove();
}
