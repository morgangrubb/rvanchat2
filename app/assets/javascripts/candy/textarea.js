var CandyShop = (function(self) { return self; }(CandyShop || {}));

CandyShop.Textarea = (function(self, Candy, $) {
  self.init = function() {
    Candy.View.Template.Room.form = '<div class="message-form-wrapper">' +
      '<form method="post" class="message-form">' +
      // '<input name="message" class="field" type="text" aria-label="Message Form Text Field" autocomplete="off" maxlength="1000" />' +
      '<textarea name="message" class="field" aria-label="Message Form Text Field" autocomplete="off" maxlength="1000" lines="2"></textarea>' +
      '<input type="submit" class="submit" name="submit" value="{{_messageSubmit}}" /></form></div>';

    // Capture enter
    $(Candy).on('candy:view.room.after-add', function(e, data) {
      data.element.find('textarea[name="message"]').keydown(function(e) {
        if (e.keyCode == 13 && !e.shiftKey) {
          e.preventDefault();
          data.element.find('form.message-form').submit();
        }
      });
    });
  }

  return self;
}(CandyShop.Textarea || {}, Candy, jQuery));
