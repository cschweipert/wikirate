# delegate :input_chunks, :input_cards, :input_names, :input_keys,
#          :year_options, :company_options, :unknown_options, to: :parser

# def item_names _args={}
#   descendant? ? super : parser.input_names
# end
#
# def special_item_names
#   case metric_type_codename
#   when :score       then [metric_card.basic_metric]
#   when :wiki_rating then translation_hash.keys
#   when :descendant  then item_names
#   end
# end

# event :validate_formula_input, :validate, on: :save, changed: :content do
#   input_chunks.each do |chunk|
#     ok_input_name(chunk) && ok_input_card(chunk) && ok_input_cardtype(chunk)
#   end
# end
#
# private
#
# def ok_input_name chunk
#   ok_input? !variable_name?(chunk.referee_name) do
#     "invalid input name: #{chunk.referee_name}"
#   end
# end
#
# def ok_input_card chunk
#   ok_input? chunk.referee_card do
#     "input metric #{chunk.referee_name} doesn't exist"
#   end
# end
#
# def ok_input_cardtype chunk
#   ok_input?(chunk.referee_card.type_id == Card::MetricID) do
#     "#{chunk.referee_name} has invalid type #{chunk.referee_card.type_name}"
#   end
# end
#
# def ok_input? test
#   return true if test
#   errors.add :formula, yield
#   false
# end
#
# def formula_for_parser
#   descendant? ? inheritance_formula : content
# end
