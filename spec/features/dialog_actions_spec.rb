require 'spec_helper'

RSpec.describe 'dialog actions', type: :feature do
  it 'dismisses a confirmation dialog' do
    skip "Cannot test this since the dialog freezes the spec"

    visit '/dialog.html'
    accept_confirm do
      click_on 'Go home'
    end
    expect(page).to have_current_path('/')
  end
end
