module ApplicationHelper

  # Return a title on a per-page basis
  def full_title(page_title)
    base_title = "Football Pool Mania"
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end

  # Set the alert levels for styling
  def flash_class(level)
    case level
        when "notice" then "alert alert-warning"
        when "success" then "alert alert-success"
        when "error" then "alert alert-danger"
        when "alert" then "alert alert-danger"
    end
  end

  # Return the logo variable
  def logo
    image_tag("logo.png", :alt => "Sample App", :class => "round")
  end

  # Set tab stops for a form
  def tabindex
    @tabindex ||= 0
    @tabindex += 1
  end
end
