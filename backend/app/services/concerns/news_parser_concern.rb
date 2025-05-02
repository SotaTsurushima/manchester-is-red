module NewsParserConcern
  extend ActiveSupport::Concern

  included do
    include HTTParty
    include ServiceHandler
  end

  private

  def is_transfer_news?(title)
    keywords = [
      'transfer',
      'deal',
      'signs',
      'signing',
      'bid',
      'move',
      'joins',
      'fee',
      'contract',
      'talks',
      'interest',
      'target'
    ]
    
    match_keywords?(title, keywords)
  end

  def is_united_news?(title)
    keywords = [
      'manchester united',
      'man united',
      'man utd',
      'mufc',
      'old trafford',
      'ten hag'
    ]
    
    match_keywords?(title, keywords)
  end

  def match_keywords?(text, keywords)
    text_downcase = text.downcase
    keywords.any? { |keyword| text_downcase.include?(keyword) }
  end

  def parse_date(date_string)
    DateTime.parse(date_string)
  rescue
    Time.current
  end

  def build_url(path, base_uri)
    return nil unless path
    path.start_with?('http') ? path : "#{base_uri}#{path}"
  end

  def get_transfer_status(title)
    title_lower = title.downcase
    
    case
    when title_lower.include?('here we go')
      'Confirmed'
    when title_lower.include?('agreed') || title_lower.include?('done deal')
      'Agreement Reached'
    when title_lower.include?('talks') || title_lower.include?('negotiating')
      'In Talks'
    when title_lower.include?('interested') || title_lower.include?('targeting')
      'Interest Shown'
    else
      'Rumour'
    end
  end
end
