# frozen_string_literal: true

require 'spec_helper'
require 'rspec_command'

RSpec.describe 'shell interface' do
  include RSpecCommand

  describe '#each' do
    command "spidy each #{__dir__}/example.rb"
    its(:exitstatus) { is_expected.to eq 0 }
  end

  describe 'call' do
    command { "echo 'http://localhost/?id=91' | spidy call #{__dir__}/example/master_detail.rb" }
    its(:exitstatus) { is_expected.to eq 0 }
    its(:stdout) { is_expected.to include('{"title":"title_91","body":"body_91"}') }
  end
end
