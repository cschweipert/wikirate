describe Card::Set::TypePlusRight::Source::File::Import do
  before do
    login_as "joe_user"
    @source = create_source file: csv1
    Card::Env.params['is_metric_import_update'] = 'true'
  end
  let(:csv1) do
    File.open File.expand_path('../import_test.csv', __FILE__)
  end
  let(:csv2) do
    File.open File.expand_path('../import_test.csv2', __FILE__)
  end
  let(:metric) { 'Access to Nutrition Index+Marketing Score' }

  def metric_answer_exists? company
    Card.exists?(metric_answer_name(company))
  end
  def metric_value company
    Card[metric_answer_name(company) + '+value'].content
  end
  def metric_answer_card company
    Card[metric_answer_name(company)]
  end
  def metric_answer_name company
    metric + '+' + company_name(company) + '+2015'
  end

  def trigger_import data, file=nil
    Card::Env.params[:metric_values] = data
    source = file ? create_source(file: file) : @source
    source_file = source.fetch trait: :file
    source_file.update_attributes subcards: {
      "#{source.name}+#{Card[:metric].name}" => {
        content: '[[Access to Nutrition Index+Marketing Score]]',
        type_id: Card::PointerID
      },
      "#{source.name}+#{Card[:year].name}" => {
        content: '[[2015]]', type_id: Card::PointerID
      }
    }
    source_file
  end
  def company_name company
    case company
    when :amazon then 'Amazon.com, Inc.'
    when :apple then 'Apple Inc.'
    when :sony then 'Sony Corporation'
    else company.to_s
    end
  end

  describe 'while adding metric value' do
    it 'shows errors while params do not fit' do
      source_file = @source.fetch trait: :file
      source_file.update_attributes subcards: {
        "#{@source.name}+#{Card[:metric].name}" => {
          content: '[[Access to Nutrition Index+Marketing Score]]',
          type_id: Card::PointerID
        }
      }
      expect(source_file.errors).to have_key(:content)
      expect(source_file.errors[:content]).to include('Please give a Year.')

      # as local cache will be cleaned after every request,
      # this reset local is pretending last request is done
      Card::Cache.reset_soft
      source_file.update_attributes subcards: {
        "#{@source.name}+#{Card[:year].name}" => {
          content: '[[2015]]', type_id: Card::PointerID
        }
      }
      expect(source_file.errors).to have_key(:content)
      expect(source_file.errors[:content]).to include('Please give a Metric.')
    end

    it 'adds correct metric values' do
      trigger_import [
        { company: 'Amazon.com, Inc.', value: '9' },
        { company: 'Apple Inc.',  value: '62' }
      ]
      expect(metric_answer_exists?(:amazon)).to be true
      expect(metric_answer_exists?(:apple)).to be true

      expect(metric_value(:amazon)).to eq('9')
      expect(metric_value(:apple)).to eq('62')
    end
    context 'company correction name is filled' do
      it 'uses the correction name as company names' do
        Card::Env.params[:corrected_company_name] = {
          1 => 'Apple Inc.',
          2 => 'Sony Corporation',
          3 => 'Amazon.com, Inc.'
        }
        trigger_import [
           { company: 'Amazon.com, Inc.', value: '9', row: 1 },
           { company: 'Apple Inc.',       value: '62', row: 2 },
           { company: "Sony Corporation", value: '13', row: 3 }
        ]

        expect(metric_answer_exists?(:amazon)).to be true
        expect(metric_answer_exists?(:apple)).to be true
        expect(metric_answer_exists?(:sony)).to be true

        expect(metric_value(:amazon)).to eq('13')
        expect(metric_value(:apple)).to eq('9')
        expect(metric_value(:sony)).to eq('62')
      end
      context "input company doesn't exist in wikirate" do
        it 'should create company and the value' do
          Card::Env.params[:corrected_company_name] = { 1 => 'Cambridge University' }
          trigger_import [{ company: "Cambridge", value: '800', row: 1 }]
          expect(Card.exists?('Cambridge University')).to be true
          expect(metric_answer_exists?(:cambridge_university)).to be true
          expect(metric_value(:cambridge_university)).to eq('800')
        end
      end
    end
    context 'company correction name is empty' do
      context 'non-matching case' do
        it 'should create company and the value' do
          trigger_import [{ company: "Cambridge", value: '800' }]
          expect(Card.exists?('Cambridge')).to be true
          expect(metric_answer_exists?(:cambridge)).to be true
          expect(metric_value(:cambridge)).to eq('800')
        end
      end
    end
    # existing values are not updated anymore
    # context 'metric value exists' do
    #   it 'updates metric values' do
    #     trigger_import [{ company: "Amazon.com, Inc.", value:'9' }]
    #     expect(metric_answer_exists?(:amazon)).to be true
    #     expect(metric_value(:amazon)).to eq('9')
    #
    #     trigger_import [{ company: "Amazon.com, Inc.", value: '999' }]
    #     expect(metric_value(:amazon)).to eq('999')
    #   end
    # end
  end
  # existing values are not updated anymore
  # describe 'updating metric values' do
  #   it 'updates correct metric values' do
  #     trigger_import [{ company: 'Amazon.com, Inc.', value: '9' },
  #                     { company: 'Apple Inc.', value: '62' }]
  #     expect(metric_answer_exists?(:amazon)).to be true
  #     expect(metric_answer_exists?(:apple)).to be true
  #
  #     expect(metric_value(:amazon)).to eq('9')
  #     expect(metric_value(:apple)).to eq('62')
  #     source_file =
  #       trigger_import  [
  #         { company: "Amazon.com, Inc.", value: "369" },
  #         { company: "Apple Inc.", value: '689' }
  #       ], test_csv2
  #     expect(source_file.errors).to be_empty
  #     expect(Card.exists?'Access to Nutrition Index+Marketing Score+Amazon.com, Inc.+2015+link').to be false
  #     expect(Card.exists?'Access to Nutrition Index+Marketing Score+Apple Inc.+2015+link').to be false
  #     expect(metric_value(:amazon)).to eq('369')
  #     expect(metric_value(:apple)).to eq('689')
  #   end
  # end
  def with_row checked, args
    with = { type: 'checkbox', id: 'metric_values_',
             value: args.to_json}
    with[:checked] = 'checked' if checked
    with_tag 'tr' do
      with_tag 'input', with: with
      with_tag 'td', text: args[:file_company]
      if args[:wikirate_company].present?
        with_tag 'td', text: args[:wikirate_company]
      end

      input_args = ['input', with: {
        type: 'text', name: "corrected_company_name[#{args[:row]}]"
      }]
      if args[:status] != 'exact'
        with_tag *input_args
      end
      with_tag 'td', text: args[:status]
    end
  end

  describe 'while rendering import view' do
    subject { @source.fetch(trait: :file).format.render_import }
    it 'shows radio buttons correctly' do
      is_expected.to have_tag('div', with: {
        card_name: "#{@source.name}+Metric"
      }) do
        with_tag 'input', with: {
          class: 'card-content form-control',
          id: "card_subcards_#{@source.name}_Metric_content"
        }
      end
      is_expected.to have_tag('div', with: {
        card_name: "#{@source.name}+Year"
      }) do
        with_tag 'input', with: {
          class: 'card-content form-control',
          id: "card_subcards_#{@source.name}_Year_content"
        }
      end
      is_expected.to have_tag('input', with: {
        id: 'is_metric_import_update',value: 'true',type: 'hidden'
      })
      is_expected.to have_tag('table', with: {class: 'import_table'}) do
        with_row false,
                 file_company: 'Cambridge',
                 value: '43',
                 row: 1,
                 wikirate_company: '',
                 status: 'none',
                 company: ''
        with_row true,
                 file_company: 'amazon.com',
                 value: '9',
                 row: 2,
                 wikirate_company: 'Amazon.com, Inc.',
                 status: 'alias',
                 company: 'Amazon.com, Inc.'
        with_row true,
                 file_company: 'Apple Inc.',
                 value: '62',
                 row: 3,
                 wikirate_company: 'Apple Inc.',
                 status: 'exact',
                 company: 'Apple Inc.'
        with_row true,
                 file_company: 'Sony C',
                 value: '33',
                 row: 4,
                 wikirate_company: 'Sony Corporation',
                 status: 'partial',
                company: 'Sony Corporation'

      end
    end
  end
end
