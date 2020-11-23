require 'rails_helper'

RSpec.describe "Admin::V1::system_requirements as :admin", type: :request do
  let(:user) { create(:user) }

  context "GET /system_requirements" do
    let(:url) { "/admin/v1/system_requirements" }
    let!(:system_requirements) { create_list(:system_requirement, 5) }

    it "Returns all system_requirements" do
      get url, headers: auth_header(user)
      expect(body_json["system_requirements"]).to contain_exactly *system_requirements.as_json(only: %i(id name operational_system storage processor memory video_board))
    end

    it "Returns success status" do
      get url, headers: auth_header(user)
      expect(response).to have_http_status(:ok)
    end
  end

  context "Post /system_requirements" do
    let(:url) { "/admin/v1/system_requirements" }

    context "With valid params" do
      let(:system_requirement_params) { { system_requirement: attributes_for(:system_requirement)}.to_json }

      it "adds a new system_requirement" do
        expect do
          post url, headers: auth_header(user), params: system_requirement_params
        end.to change(SystemRequirement, :count).by(1)
      end

      it "returns last added system_requirement" do
        post url, headers: auth_header(user), params: system_requirement_params
        expect_system_requirement = SystemRequirement.last.as_json(only: [:id, :name, :operational_system, :storage, :processor, :memory, :video_board])
        expect(body_json["system_requirement"]).to eq expect_system_requirement
      end

      it "Returns success status" do
        post url, headers: auth_header(user), params: system_requirement_params
        expect(response).to have_http_status(:ok)
      end
    end

    context "With invalid params" do
      let(:system_requirement_invalid_params) { { system_requirement: attributes_for(:system_requirement, name: nil) }.to_json }

      it "does not add ad new system_requirement" do
        expect do
          post url, headers: auth_header(user), params: system_requirement_invalid_params
        end.to_not change(SystemRequirement, :count)
      end

      it "returns error messages" do
        post url, headers: auth_header(user), params: system_requirement_invalid_params

        expect(body_json["errors"]["fields"]).to have_key("name")
      end

      it "returns unprocessable_entity status" do
        post url, headers: auth_header(user), params: system_requirement_invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  context "Patch /system_requirements/:id" do
    let(:system_requirement) { create(:system_requirement) }
    let(:url) { "/admin/v1/system_requirements/#{system_requirement.id}"}

    context "with valid params" do
      let(:new_name) { "my new system_requirement" }
      let(:new_operational_system) { Faker::Computer.os }
      let(:new_storage) { "1Tb" }
      let(:new_processor) { "AMD Ryzen 9" }
      let(:new_memory) { "32gb" }
      let(:new_video_board) { "Geforce GTX 1660 SUPER" }
      let(:system_requirement_params) { { system_requirement: { name: new_name, operational_system: new_operational_system, storage: new_storage, processor: new_processor, memory: new_memory, video_board: new_video_board }}.to_json }

      it "updates system_requirement" do
        patch url, headers: auth_header(user), params: system_requirement_params
        system_requirement.reload

        system_requirement_records = {
          name: system_requirement.name,
          operational_system: system_requirement.operational_system,
          storage: system_requirement.storage,
          processor: system_requirement.processor,
          memory: system_requirement.memory,
          video_board: system_requirement.video_board
        }
        expected_records = {
          name: new_name,
          operational_system: new_operational_system,
          storage: new_storage,
          processor: new_processor,
          memory: new_memory,
          video_board: new_video_board
        }
        expect(system_requirement_records).to eq expected_records
      end

      it "returns updates system_requirement" do
        patch url, headers: auth_header(user), params: system_requirement_params
        system_requirement.reload
        expect_system_requirement = system_requirement.as_json(only: %i(id name operational_system storage processor memory video_board))
        expect(body_json["system_requirement"]).to eq expect_system_requirement
      end

      it "return success status" do
        patch url, headers: auth_header(user), params: system_requirement_params
        expect(response).to have_http_status(:ok)
      end
    end

    context "with invalid params" do
      let(:system_requirement_invalid_params) { { system_requirement: attributes_for(:system_requirement, name: nil) }.to_json }

      it "does not update system_requirement" do
        old_name = system_requirement.name
        patch url, headers: auth_header(user), params: system_requirement_invalid_params
        system_requirement.reload
        expect(system_requirement.name).to eq old_name
      end

      it "returns error messages" do
        patch url, headers: auth_header(user), params: system_requirement_invalid_params

        expect(body_json["errors"]["fields"]).to have_key("name")
      end

      it "returns unprocessable_entity status" do
        patch url, headers: auth_header(user), params: system_requirement_invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  context "Delete /system_requirements/:id" do
    let!(:system_requirement) { create(:system_requirement) }
    let(:url) { "/admin/v1/system_requirements/#{system_requirement.id}"}

    it "removes system_requirement" do
      expect do
        delete url, headers: auth_header(user)
      end.to change(SystemRequirement, :count).by(-1)
    end

    it "return success status" do
      delete url, headers: auth_header(user)
      expect(response).to have_http_status(:no_content)
    end

    it "does not return any body content" do
      delete url, headers: auth_header(user)
      expect(body_json).to_not be_present
    end
  end
end
