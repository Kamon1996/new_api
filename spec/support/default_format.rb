# frozen_string_literal: true

module DefaultFormat
  extend ActiveSupport::Concern

  included do
    let(:default_format) { :json }
    prepend RequestHelpersCustomized
  end

  module RequestHelpersCustomized
    l = lambda do |path, **kwargs|
      kwargs[:format] ||= default_format if default_format
      super(path, kwargs)
    end
    %w[get post patch put delete].each do |method|
      define_method(method, l)
    end
  end
end

def json
  JSON.parse(response.body)
end

RSpec.configure do |config|
  config.include DefaultFormat, type: :controller
end
