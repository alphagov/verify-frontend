require 'spec_helper'
require 'action_view'
require 'verify_form_builder'

describe VerifyFormBuilder do
  let(:template) {
    template = Struct.new(:output_buffer).new
    template.extend(ActionView::Helpers::FormHelper)
    template.extend(ActionView::Helpers::FormOptionsHelper)
  }
  it 'creates the block label radio button with value set on object and is checked when matches object' do
    foo = double(:foo)
    expect(foo).to receive(:a).and_return 'b'
    form_builder = VerifyFormBuilder.new('foo', foo, template, {})
    expected_radio_button = '<label class="block-label" onclick="" for="foo_a_b"><input type="radio" value="b" checked="checked" name="foo[a]" id="foo_a_b" /> <span><span class="inner">&nbsp;</span></span> c</label>'
    expect(form_builder.block_label(:a, 'b', 'c', {})).to eql expected_radio_button
  end

  it 'creates the block label radio button with value set on object but is unchecked when does not match object' do
    foo = double(:foo)
    expect(foo).to receive(:a).and_return 'd'
    form_builder = VerifyFormBuilder.new('foo', foo, template, {})
    expected_radio_button = '<label class="block-label" onclick="" for="foo_a_b"><input type="radio" value="b" name="foo[a]" id="foo_a_b" /> <span><span class="inner">&nbsp;</span></span> c</label>'
    expect(form_builder.block_label(:a, 'b', 'c', {})).to eql expected_radio_button
  end

  it 'allows us to set html attributes' do
    foo = double(:foo)
    expect(foo).to receive(:a).and_return nil
    form_builder = VerifyFormBuilder.new('foo', foo, template, {})
    expected_radio_button = '<label class="block-label" onclick="" for="foo_a_b"><input required="required" type="radio" value="b" name="foo[a]" id="foo_a_b" /> <span><span class="inner">&nbsp;</span></span> c</label>'
    expect(form_builder.block_label(:a, 'b', 'c', required: true)).to eql expected_radio_button
  end
end
