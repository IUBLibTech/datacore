require 'rails_helper'

describe RobotsController do
  let(:user) { create(:user) }
  let(:admin) { create(:admin) }
  let(:robots_txt) { ContentBlock.create(name: 'robots_txt', value: content) }
  let(:content) { "User-Agent: *\nDisallow: /concern" }

  after do
    ContentBlock.delete('robots_txt')
  end

  describe '#show' do
    it 'is blank by default' do
      get :show
      expect(response).to be_successful
      expect(response.body).to eq ''
    end

    it 'renders the value' do
      robots_txt
      get :show
      expect(response).to be_successful
      expect(response.body).to eq content
    end

    it 'is route for /robots.txt', type: :routing do
      expect(get: '/robots.txt').to route_to(controller: 'robots', action: 'show', format: 'txt')
    end
  end

  describe '#edit' do
    it 'is unavailable to the public' do
      get :edit
      expect(response).to redirect_to(new_user_session_path(locale: nil))
    end

    it 'is unavailable to regular users' do
      sign_in user
      get :edit
      expect(response).to be_unauthorized
    end

    context 'with rendering' do
      render_views
      it 'is rendered for admins' do
        robots_txt
        sign_in admin
        get :edit
        expect(response).to be_successful
        expect(response.body).to include(content)
      end
    end
  end

  describe '#update' do
    let(:new_content) { 'Disallow: *' }

    it 'is unavailable to the public' do
      patch :update, params: { content_block: { value: new_content } }
      expect(response).to redirect_to(new_user_session_path(locale: nil))
    end

    it 'is unavailable to regular users' do
      sign_in user
      patch :update, params: { content_block: { value: new_content } }
      expect(response).to be_unauthorized
    end

    it 'is updated for admins' do
      robots_txt
      sign_in admin
      patch :update, params: { content_block: { value: new_content } }
      expect(response).to redirect_to(edit_robots_path)
      get :show
      expect(response.body).to eq new_content
    end
  end
end