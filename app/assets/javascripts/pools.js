$(document).ready(function(){
  $('.dropdown .dropdown').each(function(){
    var $self = $(this);
    var handle = $self.children('[data-toggle="dropdown"]');
    $(handle).click(function(){
      var submenu = $self.children('.dropdown-menu');
      $(submenu).toggle();
      return false;
    });
  });
});

