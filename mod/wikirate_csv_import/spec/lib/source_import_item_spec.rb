require_relative "import_item_spec_helper"

RSpec.describe SourceImportItem do
  include ImportItemSpecHelper

  TEST_URL = "https://decko.org/Home.txt".freeze

  ITEM_HASH = {
    wikirate_company: "Death Star",
    year: "1977",
    report_type: "Dark Report",
    source: TEST_URL,
    wikirate_title: "Death Star Source"
  }.freeze

  describe "#import_hash" do
    it "generates a valid import_hash" do
      item = validate
      expect(item.import_hash)
        .to include(
          type_id: Card::SourceID,
          subfields: a_hash_including(
            wikirate_company: { content: ["Death Star"] },
            file:  { remote_file_url: TEST_URL, type_id: Card::FileID }
          )
        )
    end
  end

  describe "#import" do
    it "works with valid item_hash", as_bot: true do
      status = import.status_hash
      expect(status[:errors]).to be_blank
      expect(Card.fetch_type_id(status[:id])).to eq(Card::SourceID)
    end
  end
end
