require 'spec_helper'

describe SessionsController do

  describe "GET 'sign_in'" do
    it "returns http success" do
      get 'sign_in'
      response.should be_success
    end
  end

  describe "GET 'sign_out'" do
    it "returns http success" do
      get 'sign_out'
      response.should be_success
    end
  end

end
