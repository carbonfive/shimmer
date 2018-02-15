module Capybara
  module Shimmer
    module JavascriptExpressions
      NODE_VISIBLE = "
function() {
  let element = this;
  while (element) {
    const style = window.getComputedStyle(element);
    const isComputedStyleVisible =
      style &&
      style.display !== 'none' &&
      style.visibility !== 'hidden' &&
      style.opacity !== '0';
    if (!isComputedStyleVisible) {
      return false;
    }
    element = element.parentElement;
  }
  return true;
}
                                      "
      INNER_TEXT = "function() { return this.innerText }"
    end
  end
end
