# frozen_string_literal: true

module Primer
  module Responsive
    # Helper to handle html attributes separated from the base system_args.
    #
    # Responsive components won't support Primer CSS' utility classes anymore, making
    # it easier to handle html attributes on their own, instead of filtering system_args
    module HtmlAttributesHelper
      # The global attributes supported only exclude event handlers and interactive APIs
      # If they need to be supported, they should be part of the component properties
      # so their behavior can be documented and sanitized
      #
      # attributes ending in * accept any attribute prefixed with the attribute name,
      # like aria-* and data-*
      #
      # To support element specific attributes, inherit from ResponsiveComponent
      #
      # https://developer.mozilla.org/en-US/docs/Web/HTML/Global_attributes
      ALLOWED_GLOBAL_ATTRIBUTES = [
        # aria
        :aria,
        :"aria-*",
        :role,

        :accesskey,
        :autocapitalize,
        :autofocus,
        :class,
        :classes, #support for Primer::BaseComponent abstraction
        :data,
        :"data-*",
        :enterkeyhint,
        :hidden,
        :id,
        :is,

        # https://html.spec.whatwg.org/multipage/microdata.html#microdata
        :"item*",

        :lang,
        :nonce,

        # shadow dom attributes
        :part,
        :slot,

        :spellcheck,
        :tabindex,
        :title,
        :translate
      ].freeze
      # this is calculated and shouldn't be used outside of this helper
      ALLOWED_GLOBAL_ATTRIBUTES_PREFIXES = ALLOWED_GLOBAL_ATTRIBUTES
                                           .select { |attribute_name| attribute_name[-1] == "*" }
                                           .map { |attribute_prefix| attribute_prefix.to_s.chop }
                                           .freeze

      # Error raised when a
      InvalidHtmlAttributeError = Class.new(StandardError)

      # Validates the hash of HTML Attributes for a component
      #
      # @param given_html_attributes [Hash] keys are symbols with the html attribute name.
      # @param additional_allowed_attributes [Array] optional array to allow components to accept element specific attributes.
      #                                              However, wildcard is not allowed for them.
      def validate_html_attributes(given_html_attributes, additional_allowed_attributes = [])
        return if given_html_attributes.blank?

        given_html_attributes.each_key do |name|
          next if ALLOWED_GLOBAL_ATTRIBUTES.include? name
          next if additional_allowed_attributes.include? name
          next if ALLOWED_GLOBAL_ATTRIBUTES_PREFIXES.any? { |prefix| name.to_s.starts_with? prefix }

          raise InvalidHtmlAttributeError, <<~MSG
            HTML Attribute: "#{name}" is not allowed.
            To support element specific attributes, add them using the `additional_allowed_attributes` class method
          MSG
        end
      end

      # Generates a sanitized attributes hash continaing only allowed attributes present in raw_html_attributes
      #
      # @param raw_html_attributes [Hash] html attributes and values to be sanitized
      # @param additional_allowed_attributes [Array] optional array to allow components to accept element specific attributes.
      #                                              However, wildcard is not allowed for them.
      def sanitize_html_attributes(raw_html_attributes, additional_allowed_attributes: [])
        return raw_html_attributes if raw_html_attributes.blank?

        sanitized_attributes = {}
        raw_html_attributes.each do |name, value|
          next unless ALLOWED_GLOBAL_ATTRIBUTES.include?(name) || additional_allowed_attributes.include?(name) || ALLOWED_GLOBAL_ATTRIBUTES_PREFIXES.any? { |prefix| name.to_s.starts_with? prefix }

          sanitized_attributes[name] = value
        end

        sanitized_attributes
      end
    end
  end
end