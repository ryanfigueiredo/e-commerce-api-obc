require 'rails_helper'

RSpec.describe "Admin::V1::users as :admin", type: :request do
  let(:user) { create(:user) }

  context "GET /users" do
    let(:url) { "/admin/v1/users" }
    let!(:users) { create_list(:user, 5).push(user) }

    it "Returns all users" do
      get url, headers: auth_header(user)
      expect(body_json["users"]).to contain_exactly *users.as_json(only: %i(id))
    end

    it "Returns success status" do
      get url, headers: auth_header(user)
      expect(response).to have_http_status(:ok)
    end
  end

  context "Post /users" do
    let(:url) { "/admin/v1/users" }

    context "With valid params" do
      let(:user_params) { { user: attributes_for(:user)}.to_json }

      it "adds a new user" do
        expect do
          post url, headers: auth_header(user), params: user_params
        end.to change(User, :count).by(2)
      end

      it "returns last added user" do
        post url, headers: auth_header(user), params: user_params
        expect_user = User.last.as_json(only: [:id, :name, :profile, :email])
        expect(body_json["user"]).to eq expect_user
      end

      it "Returns success status" do
        post url, headers: auth_header(user), params: user_params
        expect(response).to have_http_status(:ok)
      end
    end

    context "With invalid params" do
      let(:user_invalid_params) { { user: attributes_for(:user, name: nil) }.to_json }

      it "does not add ad new user" do
        expect do
          post url, headers: auth_header(user), params: user_invalid_params
        end.to change(User, :count).by(1)
      end

      it "returns error messages" do
        post url, headers: auth_header(user), params: user_invalid_params

        expect(body_json["errors"]["fields"]).to have_key("name")
      end

      it "returns unprocessable_entity status" do
        post url, headers: auth_header(user), params: user_invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  context "Patch /users/:id" do
    let(:user) { create(:user) }
    let(:url) { "/admin/v1/users/#{user.id}"}

    context "with valid params" do
      let(:new_name) { Faker::Name.name }
      let(:new_email) { Faker::Internet.email }
      let(:new_password) { "123456789" }
      let(:new_profile) { [:client].sample.to_s }

      let(:user_params) { { user:  { name: new_name, email: new_email, password: new_password, profile: new_profile } }.to_json }

      it "updates user" do
        patch url, headers: auth_header(user), params: user_params
        user.reload

        user_records = {
          name: user.name,
          email: user.email,
          password: user.password,
          profile: user.profile
        }

        expected_records = { name: new_name, email: new_email, password: new_password, profile: new_profile }
        expect(user_records).to eq expected_records
      end

      it "returns updates user" do
        patch url, headers: auth_header(user), params: user_params
        user.reload
        expect_user = user.as_json(only: %i(id name profile email))
        expect(body_json["user"]).to eq expect_user
      end

      it "return success status" do
        patch url, headers: auth_header(user), params: user_params
        expect(response).to have_http_status(:ok)
      end
    end

    context "with invalid params" do
      let(:user_invalid_params) { { user: attributes_for(:user, name: nil) }.to_json }

      it "does not update user" do
        old_name = user.name
        patch url, headers: auth_header(user), params: user_invalid_params
        user.reload
        expect(user.name).to eq old_name
      end

      it "returns error messages" do
        patch url, headers: auth_header(user), params: user_invalid_params

        expect(body_json["errors"]["fields"]).to have_key("name")
      end

      it "returns unprocessable_entity status" do
        patch url, headers: auth_header(user), params: user_invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  context "Delete /users/:id" do
    let!(:new_user) { create(:user) }
    let(:url) { "/admin/v1/users/#{new_user.id}"}

    it "removes user" do
      expect do
        delete url, headers: auth_header(user)
      end.to_not change(User, :count)
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
