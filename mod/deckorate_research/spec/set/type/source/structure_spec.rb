# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::Source::Structure do
  let(:source) { sample_source }

  def expect_source_link html, text, url, icon
    expect(html).to(
      have_tag("a", with: { href: url }, text: /#{text}/) do
        with_tag "i.material-icons", text: icon
      end
    )
  end

  describe "#download_link" do
    it "renders link with download icon" do
      expect_source_link source.format.download_link,
                         "Download",
                         source.fetch(:file).file.url,
                         "file_download"
    end
  end

  describe "#original_link" do
    it "renders link with external link icon" do
      expect_source_link source.format.original_link,
                         "Original",
                         source.fetch(:wikirate_link).content,
                         "close_fullscreen"
    end
  end
end
