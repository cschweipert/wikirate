include_set Abstract::AwardBadges, hierarchy_type: :project

event :award_project_discussion_badges, :finalize,
      on: :save do
  award_badge_if_earned :discuss
end
