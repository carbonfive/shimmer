require 'spec_helper'

RSpec.describe 'dialog actions', type: :feature do
  it 'auto-accepts a confirmation dialog' do
    visit '/dialog.html'
    # Here, we should be stopped by a BIG BAD CONFIRM DIALOG but fortunately
    # we configured the test runner to auto-accept!
    click_on 'Go home'
    expect(page).to have_current_path('/')
  end
end
