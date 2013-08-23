# encoding: UTF-8
require 'spec_helper'

describe Resource do

  before do
    @resource = Resource.new(name: 'Some name', url: 'http://google.ru')
  end

  subject { @resource }

  it { should be_valid }

  describe 'when name is empty' do
    before { @resource.name = '' }
    it { should_not be_valid }
  end

  describe 'when url is empty' do
    before { @resource.url = '' }
    it { should_not be_valid }
  end

  describe 'when url should be valid: ' do
    %w[google.ru http://google.ru http://www.google.ru тамтэк.рф
        http://тамтэк.рф ].each() do |url|
      it "#{url}" do
        @resource.url = url
        should be_valid
      end
    end
  end

  describe 'when url should not be valid: ' do
    %w[as.df asdf http://asdf http://as.df].each() do |url|
      it "#{url}" do
        @resource.url = url
        should_not be_valid
      end
    end
  end

  describe 'when url is soooo looong' do
    before { @resource.url = "http://#{'a'*253}.com" }
    it { should_not be_valid }
  end

end