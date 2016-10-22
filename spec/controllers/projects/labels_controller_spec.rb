require 'spec_helper'

describe Projects::LabelsController do
  let(:group)   { create(:group) }
  let(:project) { create(:project, namespace: group) }
  let(:user)    { create(:user) }

  before do
    project.team << [user, :master]

    sign_in(user)
  end

  describe 'GET #index' do
    let!(:label_1) { create(:label, project: project, priority: 1, title: 'Label 1') }
    let!(:label_2) { create(:label, project: project, priority: 3, title: 'Label 2') }
    let!(:label_3) { create(:label, project: project, priority: 1, title: 'Label 3') }
    let!(:label_4) { create(:label, project: project, title: 'Label 4') }
    let!(:label_5) { create(:label, project: project, title: 'Label 5') }

    let!(:group_label_1) { create(:group_label, group: group, title: 'Group Label 1') }
    let!(:group_label_2) { create(:group_label, group: group, title: 'Group Label 2') }
    let!(:group_label_3) { create(:group_label, group: group, title: 'Group Label 3') }
    let!(:group_label_4) { create(:group_label, group: group, title: 'Group Label 4') }

    before do
      create(:label_priority, project: project, label: group_label_1, priority: 3)
      create(:label_priority, project: project, label: group_label_2, priority: 1)
    end

    context '@prioritized_labels' do
      before do
        list_labels
      end

      it 'does not include labels without priority' do
        list_labels

        expect(assigns(:prioritized_labels)).not_to include(group_label_3, group_label_4, label_4, label_5)
      end

      it 'is sorted by priority, then label title' do
        expect(assigns(:prioritized_labels)).to eq [group_label_2, label_1, label_3, group_label_1, label_2]
      end
    end

    context '@labels' do
      it 'is sorted by label title' do
        list_labels

        expect(assigns(:labels)).to eq [group_label_3, group_label_4, label_4, label_5]
      end

      it 'does not include labels with priority' do
        list_labels

        expect(assigns(:labels)).not_to include(group_label_2, label_1, label_3, group_label_1, label_2)
      end

      it 'does not include group labels when project does not belong to a group' do
        project.update(namespace: create(:namespace))

        list_labels

        expect(assigns(:labels)).not_to include(group_label_3, group_label_4)
      end
    end

    def list_labels
      get :index, namespace_id: project.namespace.to_param, project_id: project.to_param
    end
  end

  describe 'POST #generate' do
    let(:admin) { create(:admin) }
    let(:project) { create(:empty_project) }

    before do
      sign_in(admin)
    end

    it 'creates labels' do
      post :generate, namespace_id: project.namespace.to_param, project_id: project.to_param

      expect(response.code).to eq(302)
    end
  end
end
