$(document).on('change', '.form-field .radio-buttons label input', function(event) {
  if ($(this).is(':checked')) {
    $(this).parent('label').addClass('is-checked');
    $(this).parent('label').siblings().removeClass('is-checked');
  } else {
    $(this).parent('label').removeClass('is-checked');
  }
});

$(document).on('change', 'form.search-filters', function(event) {
  $(this).submit();
});

$(document).on('ajax:success', function(event, data) {
  if($(event.target).find('input').hasClass('archive_issue') || $(event.target).find('input').hasClass('unarchive_issue')) {
    $($(event.target).parent()).parent("tr:first").remove()
  }
})