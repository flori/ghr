# Helper module for mailer functionality.
#
# This module provides utility methods specifically designed to assist with
# formatting content within email templates. It currently includes a method for
# converting markdown text into HTML, which is useful for rendering rich-text
# content in email notifications.
#
# @example
#   helper.markdown("**bold**")
#   # => "<p><strong>bold</strong></p>\n"
module MailerHelper
  # Converts markdown text to HTML format.
  #
  # This method takes a string containing markdown formatted text and converts it
  # into HTML format using the Kramdown library with GitHub Flavored Markdown
  # (GFM) input processing. The resulting HTML is marked as safe for HTML output.
  #
  # @param text [String] the markdown formatted text to convert
  # @return [ActiveSupport::SafeBuffer] the HTML formatted string
  def markdown(text)
    Kramdown::Document.new(text, input: 'GFM').to_html.html_safe
  end
end
