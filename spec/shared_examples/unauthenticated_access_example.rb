shared_examples "unauthenticated_access" do
  it "returns unauthorized status" do
    expect(response).to have_http_status(:unauthorized)
  end
end
