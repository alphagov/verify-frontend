require 'spec_helper'
require 'action_view'
require 'verify_form_builder'

describe VerifyFormBuilder do
  let(:template) {
    template = Struct.new(:output_buffer).new
    template.extend(ActionView::Helpers::FormHelper)
    template.extend(ActionView::Helpers::FormOptionsHelper)
  }
  it 'creates the custom radio button with value set on object and is checked when matches object' do
    foo = double(:foo)
    expect(foo).to receive(:a).and_return 'b'
    form_builder = VerifyFormBuilder.new('foo', foo, template, {})
    expected_html = '<div class="multiple-choice"><input type="radio" value="b" checked="checked" name="foo[a]" id="foo_a_b" /> <label for="foo_a_b">c</label></div>'
    expect(form_builder.custom_radio_button(:a, 'b', 'c', {})).to eql expected_html
  end

  it 'creates the custom radio button with value set on object but is unchecked when does not match object' do
    foo = double(:foo)
    expect(foo).to receive(:a).and_return 'd'
    form_builder = VerifyFormBuilder.new('foo', foo, template, {})
    expected_html = '<div class="multiple-choice"><input type="radio" value="b" name="foo[a]" id="foo_a_b" /> <label for="foo_a_b">c</label></div>'
    expect(form_builder.custom_radio_button(:a, 'b', 'c', {})).to eql expected_html
  end

  it 'allows us to set html attributes against a custom radio button' do
    foo = double(:foo)
    expect(foo).to receive(:a).and_return nil
    form_builder = VerifyFormBuilder.new('foo', foo, template, {})
    expected_html = '<div class="multiple-choice"><input required="required" type="radio" value="b" name="foo[a]" id="foo_a_b" /> <label for="foo_a_b">c</label></div>'
    expect(form_builder.custom_radio_button(:a, 'b', 'c', required: true)).to eql expected_html
  end

  it 'creates the custom check box with value set on object and is checked when matches object' do
    foo = double(:foo)
    expect(foo).to receive(:a).and_return 'b'
    form_builder = VerifyFormBuilder.new('foo', foo, template, {})
    expected_html = '<div class="multiple-choice"><input name="foo[a]" type="hidden" value="c" /><input type="checkbox" value="b" checked="checked" name="foo[a]" id="foo_a" /> <label for="foo_a">d</label></div>'
    expect(form_builder.custom_check_box(:a, {}, 'b', 'c', 'd')).to eql expected_html
  end

  it 'creates the custom check box with value set on object but is unchecked when does not match object' do
    foo = double(:foo)
    expect(foo).to receive(:a).and_return 'd'
    form_builder = VerifyFormBuilder.new('foo', foo, template, {})
    expected_html = '<div class="multiple-choice"><input name="foo[a]" type="hidden" value="c" /><input type="checkbox" value="b" name="foo[a]" id="foo_a" /> <label for="foo_a">d</label></div>'
    expect(form_builder.custom_check_box(:a, {}, 'b', 'c', 'd')).to eql expected_html
  end

  it 'allows us to set html attributes against a custom check box' do
    foo = double(:foo)
    expect(foo).to receive(:a).and_return nil
    form_builder = VerifyFormBuilder.new('foo', foo, template, {})
    expected_html = '<div class="multiple-choice"><input name="foo[a]" type="hidden" value="c" /><input required="required" type="checkbox" value="b" name="foo[a]" id="foo_a" /> <label for="foo_a">d</label></div>'
    expect(form_builder.custom_check_box(:a, { required: true }, 'b', 'c', 'd')).to eql expected_html
  end
end
