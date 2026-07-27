require 'rails_helper'

describe RackAttacksController do
  let(:user) { create(:user) }
  let(:admin) { create(:admin) }
  let(:name) { Datacore::RackAttackConfig.config_key }
  let(:existing_block) { ContentBlock.where(name: name).first || ContentBlock.create(name: name, value: '') }
  let(:content_block) { existing_block.value = content; existing_block.save; existing_block }
  let(:content) { "---\nsafe_paths:\n- \"^/assets\"\n- \"^/rack_attack\"\nsafe_ips: []\nsafe_user_agents: []\nblock_ips: []\nblock_user_agents: []\nthrottle_ips: []\nthrottle_user_agents: []\n" }
  let(:new_content) { "---\nsafe_paths:\n- \"^/assets\"\n- \"^/rack_attack\"\nsafe_ips: []\nsafe_user_agents: []\nblock_ips: []\nblock_user_agents: []\nthrottle_ips: []\nthrottle_user_agents:\n- bad-agent\n" }

  after do
    ContentBlock.delete(name)
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
        content_block
        sign_in admin
        get :edit
        expect(response).to be_successful
        expect(response.body).to include(ERB::Util.html_escape(content))
      end
    end
  end

  describe '#update' do
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
      content_block
      sign_in admin
      patch :update, params: { content_block: { value: new_content } }
      expect(response).to redirect_to(edit_rack_attack_path)
      expect(ContentBlock.where(name: name)&.first&.value).to eq new_content
    end
  end
end
