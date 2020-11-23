require 'rails_helper'

RSpec.describe "Admin::V1::coupons as :admin", type: :request do
  let(:user) { create(:user) }

  context "GET /coupons" do
    let(:url) { "/admin/v1/coupons" }
    let!(:coupons) { create_list(:coupon, 5) }

    it "Returns all coupons" do
      get url, headers: auth_header(user)
      expect(body_json["coupons"]).to contain_exactly *coupons.as_json(only: %i(id code status discount_value due_date))
    end

    it "Returns success status" do
      get url, headers: auth_header(user)
      expect(response).to have_http_status(:ok)
    end
  end

  context "Post /coupons" do
    let(:url) { "/admin/v1/coupons" }

    context "With valid params" do
      let(:coupon_params) { { coupon: attributes_for(:coupon)}.to_json }

      it "adds a new coupon" do
        expect do
          post url, headers: auth_header(user), params: coupon_params
        end.to change(Coupon, :count).by(1)
      end

      it "returns last added user" do
        post url, headers: auth_header(user), params: coupon_params
        expect_coupon = Coupon.last.as_json(only: [:id, :code, :status, :discount_value, :due_date])
        expect(body_json["coupon"]).to eq expect_coupon
      end

      it "Returns success status" do
        post url, headers: auth_header(user), params: coupon_params
        expect(response).to have_http_status(:ok)
      end
    end

    context "With invalid params" do
      let(:coupon_invalid_params) { { coupon: attributes_for(:coupon, code: nil) }.to_json }

      it "does not add ad new coupon" do
        expect do
          post url, headers: auth_header(user), params: coupon_invalid_params
        end.to_not change(Coupon, :count)
      end

      it "returns error messages" do
        post url, headers: auth_header(user), params: coupon_invalid_params

        expect(body_json["errors"]["fields"]).to have_key("code")
      end

      it "returns unprocessable_entity status" do
        post url, headers: auth_header(user), params: coupon_invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  context "Patch /coupons/:id" do
    let(:coupon) { create(:coupon) }
    let(:url) { "/admin/v1/coupons/#{coupon.id}"}

    context "with valid params" do
      let(:new_code) { Faker::Commerce.unique.promotion_code(digits: 6) }
      let(:new_status) { [:active, :inactive].sample.to_s }
      let(:new_discount_value) { 11 }
      let(:new_due_date) { (Time.zone.now + 1.day ).strftime("%d/%m/%Y - %H:%M:%S") }

      let(:coupon_params) { { coupon:  { code: new_code, status: new_status, discount_value: new_discount_value, due_date: new_due_date } }.to_json }

      it "updates coupon" do
        patch url, headers: auth_header(user), params: coupon_params
        coupon.reload

        coupon_records = {
          code: coupon.code,
          status: coupon.status,
          discount_value: 11,
          due_date: coupon.due_date
        }

        expected_records = { code: new_code, status: new_status, discount_value: new_discount_value, due_date: new_due_date }
        expect(coupon_records).to eq expected_records
      end

      it "returns updates coupon" do
        patch url, headers: auth_header(user), params: coupon_params
        coupon.reload
        expect_coupon = coupon.as_json(only: %i(id code status discount_value due_date))
        expect(body_json["coupon"]).to eq expect_coupon
      end

      it "return success status" do
        patch url, headers: auth_header(user), params: coupon_params
        expect(response).to have_http_status(:ok)
      end
    end

    context "with invalid params" do
      let(:coupon_invalid_params) { { coupon: attributes_for(:coupon, code: nil) }.to_json }

      it "does not update coupon" do
        old_code = coupon.code
        patch url, headers: auth_header(user), params: coupon_invalid_params
        coupon.reload
        expect(coupon.code).to eq old_code
      end

      it "returns error messages" do
        patch url, headers: auth_header(user), params: coupon_invalid_params

        expect(body_json["errors"]["fields"]).to have_key("code")
      end

      it "returns unprocessable_entity status" do
        patch url, headers: auth_header(user), params: coupon_invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  context "Delete /coupons/:id" do
    let!(:coupon) { create(:coupon) }
    let(:url) { "/admin/v1/coupons/#{coupon.id}"}

    it "removes user" do
      expect do
        delete url, headers: auth_header(user)
      end.to change(Coupon, :count).by(-1)
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
