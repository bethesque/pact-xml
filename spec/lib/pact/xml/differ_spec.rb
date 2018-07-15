require 'pact/xml/differ'
require 'pact/support'

include Pact::Matchers

# TODO: nested XML
# TODO: complex XML
# TODO: extra elements before matching one
# TODO: refer to https://github.com/DiUS/pact-jvm/blob/master/pact-jvm-matchers/src/test/groovy/au/com/dius/pact/matchers/XmlBodyMatcherSpec.groovy for any missed scenarios

module Pact
  module XML
    describe Differ do
      describe ".call" do

        let(:expected) { StringWithMatchingRules.new(
          expected_xml_string,
          pact_specification_version,
          matching_rules
        ) }
        let(:expected_xml_string) { "" }
        let(:pact_specification_version) { Pact::SpecificationVersion.new("3") }
        let(:matching_rules) { nil }
        let(:options) { { allow_unexpected_keys: allow_unexpected_keys } }
        let(:allow_unexpected_keys) { false }

        subject { Differ.call(expected, actual, options) }

        context "when actual & expected is not a valid XML" do
          let(:actual) { "Actual not a XML" }
          let(:expected) { "Expected not a XML" }
          it "returns diff" do
            expect(subject).to eq([
              Difference.new(expected, actual, "Actual is not a valid XML"),
              Difference.new(expected, actual, "Expected is not a valid XML")
            ])
          end
        end

        context "when allow_unexpected_keys is false" do

          context "simple xml" do

            let(:expected_xml_string) { %(<tag attr="attr_val">text</tag>) }

            context "when text does not match" do
              let(:actual) { expected.gsub "text", "x"}
              it "returns diff" do
                expect(subject).to eq([Difference.new("text", "x")])
              end
            end

            context "when tag does not match" do
              let(:actual) { expected.gsub "tag", "x" }
              it "returns diff" do
                expect(subject).to eq([Difference.new("tag", "x")])
              end
            end

            context "when extra tag" do
              let(:actual) { %(<tag attr="attr_val"><another_tag/>text</tag>) }
              it "returns diff" do
                expect(subject).to eq([Difference.new(nil, "another_tag")])
              end
            end

            context "when attribute value does not match" do
              let(:actual) { expected.gsub "attr_val", "x"}
              it "returns diff" do
                expect(subject).to eq([Difference.new("attr_val", "x")])
              end
            end

            context "when missing attribute" do
              let(:actual) { %(<tag>text</tag>)  }
              it "returns diff" do
                expect(subject).to eq([Difference.new("attr_val", nil)])
              end
            end

            context "when extra attribute" do
              let(:actual) { %(<tag attr="attr_val" another_attr="x">text</tag>)  }
              it "returns diff" do
                expect(subject).to eq([Difference.new(nil, "another_attr")])
              end
            end

            context "when attribute and text" do
              let(:actual) { (expected.gsub "attr_val", "x").gsub "text", "y" }
              it "returns diff" do
                expect(subject).to eq([
                  Difference.new("attr_val", "x"),
                  Difference.new("text", "y")
                ])
              end
            end

            context "when a string match" do
              let(:actual) { expected_xml_string }
              it "returns no diff" do
                expect(subject.any?).to be false
              end
            end
          end

        end

        context "when allow_unexpected_keys is true" do

          let(:allow_unexpected_keys) { true }

          context "simple xml" do

            let(:expected_xml_string) { %(<tag attr="attr_val">text</tag>) }

            context "when extra tag" do
              let(:actual) { %(<tag attr="attr_val"><another_tag/>text</tag>) }
              it "returns no diff" do
                expect(subject.any?).to be false
              end
            end

            context "when extra attribute" do
              let(:actual) { %(<tag attr="attr_val" another_attr="x">text</tag>)  }
              it "returns no diff" do
                expect(subject.any?).to be false
              end
            end

          end

        end

      end
    end
  end
end
