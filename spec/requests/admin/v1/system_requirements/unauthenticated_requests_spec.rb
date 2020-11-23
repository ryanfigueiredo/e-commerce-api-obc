require 'rails_helper'

RSpec.describe "Admin::V1::system_requirements without authentication", type: :request do
  context "GET /system_requirements" do
    let(:url) { "/admin/v1/system_requirements" }
    let!(:system_requirements) { create_list(:system_requirement, 5) }

    before(:each) { get url }

    include_examples "unauthenticated_access"
  end

  context "POST /system_requirements" do
    let(:url) { "/admin/v1/system_requirements" }

    before(:each) { post url }
    include_examples "unauthenticated_access"
  end

  context "PATCH /system_requirements/:id" do
    let(:system_requirement) { create(:system_requirement) }
    let(:url) { "/admin/v1/system_requirements/#{system_requirement.id}"}

    before(:each) { patch url }
    include_examples "unauthenticated_access"
  end

  context "Delete /system_requirements/:id" do
    let!(:system_requirement) { create(:system_requirement) }
    let(:url) { "/admin/v1/system_requirements/#{system_requirement.id}"}

    before(:each) { delete url }
    include_examples "unauthenticated_access"
  end
end
