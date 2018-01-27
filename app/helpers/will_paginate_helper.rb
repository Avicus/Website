module WillPaginateHelper
  class WillPaginateAjaxLinkRenderer < WillPaginate::ActionView::LinkRenderer
    def prepare(collection, options, template)
      options[:params] ||= {}
      options[:params]['_'] = nil
      super(collection, options, template)
    end

    protected
    def link(text, target, attributes = {})
      if target.is_a? Fixnum
        attributes[:rel] = rel_value(target)
        target = url(target)
      end
      attributes['class'] = 'ajax-link'
      attributes['rel-to'] = target
      @template.link_to(text.to_s.html_safe, '#', attributes)
    end

    def html_container(html)
      tag :div, tag(:ul, html, :class => 'pagination'), container_attributes
    end

    def page_number(page)
      tag :li, link(page, page, :rel => rel_value(page)), :class => ('active' if page == current_page)
    end

    def gap
      tag :li, link('&hellip;'.html_safe, '#'), :class => 'disabled'
    end

    def previous_or_next_page(page, text, classname)
      tag :li, link(text, page || '#'),
          :class => [(classname[0..3] if @options[:page_links]), (classname if @options[:page_links]), ('disabled' unless page)].join(' ')
    end

  end

  def ajax_will_paginate(collection, options = {})
    will_paginate(collection, options.merge(:renderer => WillPaginateHelper::WillPaginateAjaxLinkRenderer))
  end
end