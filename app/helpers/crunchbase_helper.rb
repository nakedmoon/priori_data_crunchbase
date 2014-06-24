module CrunchbaseHelper


  def pagination_prev(current_page, item_type)
    return '' if current_page.zero?
    content_tag(:li, :class => 'previous') do
      link_to('&larr; Prev'.html_safe, page_path(:item_type => item_type.downcase, :page => current_page-1), :class => 'pagination-link')
    end
  end


  def pagination_next(current_page, item_type)
    total_pages = 10000000
    return '' if current_page == total_pages
    content_tag(:li, :class => 'next') do
      link_to('Next &rarr;'.html_safe, page_path(:item_type => item_type.downcase, :page => current_page+1), :class => 'pagination-link')
    end
  end

  def url_to_item(item_url)
    item_type, permalink = item_url.split('/').delete_if{|w| w.blank?}
    item_url(:item_type => item_type, :permalink => permalink)
  end

  def link_row(record)
    link_to(content_tag(:span, '', :class => 'glyphicon glyphicon-zoom-in'), url_to_item(record.url), :class => 'row-link')
  end


end
