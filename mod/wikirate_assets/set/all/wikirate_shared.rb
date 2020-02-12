NAV_MENUS = {
  "Explore" => ["Companies", "Topics", "Metrics",
                "Projects", "Research Groups", "Company Groups", "Sources", "Changes"],
  "How To"  => ["Add Data", "Use Data", "Organize Projects", "FAQ", "Glossary",
               "Report Issue"],
  "About" => ["About Us", "Our Team", "Programs", "Publications", "News", "Legal",
              "Contact Us", "Donate"]
}.freeze

MENU_REFS = { "Groups" => "Research Groups",
              "Changes" => ":recent",
              "FAQ" => "Frequently Asked Questions",
              "Report Issue" => "Tickets",
              "Add Data" => "How to Add Data",
              "Use Data" => "How to Use Data",
              "Organize Projects" => "How to Organize Projects",
              "Facebook" => "https://www.facebook.com/wikirate/",
              "Twitter" => "https://twitter.com/WikiRate",
              "Instagram" => "https://www.instagram.com/wikirate/",
              "Notice" => "Notice and Take Down Procedure" }.freeze

SECONDARY_MENUS = { "Legal" => ["Privacy Policy", "Licensing", "Disclaimers",
                                "Terms of Use", "Notice"],
                    "Social" => %w[Facebook Twitter Instagram] }.freeze

format do
  def nav_menus
    NAV_MENUS
  end

  def secondary_menus
    SECONDARY_MENUS
  end

  def nav_menu_item_url menu, item_name
    ref = MENU_REFS[item_name] || item_name
    return ref if ref.match?(/^http/)
    url_prefix(menu) + ref.to_name.url_key
  end

  def url_prefix menu
    shared_url_prefix(menu == "About")
  end

  def shared_url_prefix project=true
    project ? "https://wikirateproject.org/" : "/"
  end

  # this is just to add the unknown setting, which was (perhaps unintentionally?)
  # set globally in wikirate before.  removing the setting has some surprising
  # consequences
  view :core, unknown: true do
    super()
  end
end
