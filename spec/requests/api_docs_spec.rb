require 'rails_helper'

RSpec.describe "API ドキュメント (rswag)", type: :request do
  it "OpenAPI スペック(YAML)を認証なしで配信する" do
    get "/api-docs/v1/openapi.yaml"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("ワリタロ会計部 API")
  end

  it "Swagger UI を配信する" do
    get "/api-docs/index.html"
    expect(response).to have_http_status(:ok)
  end
end
