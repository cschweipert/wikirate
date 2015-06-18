def contribution_count
  @cc ||= Card.search :type_id=>MetricID, :or=>
                      {
                       :left=>cardname.left,
                       :created_by=>cardname.left,
                       :edited_by=>cardname.left,
                       :linked_to_by=>{:left=>cardname.left, :right=>["in", "*upvotes", "*downvotes"]}
                      },
                      :return=>:count
end

format :html do
  include ContributedAnalysis::HtmlFormat

  def default_header_args args
    super(args)
    args[:icon] = '<i class="fa fa-bar-chart-o"></i>'
  end

end