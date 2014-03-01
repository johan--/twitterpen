module ApplicationHelper
  def omniauth_authorize_path(resource_name, provider)
    send "#{resource_name}_omniauth_authorize_path", provider
  end

  def timeago(time, options = {})
    options[:class] ||= "timeago"
    content_tag(:abbr, time.to_s, options.merge(title: time.getutc.iso8601)) if time
  end
end
