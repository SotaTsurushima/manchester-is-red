class TransferService
  include HTTParty
  include ServiceHandler

  def initialize
    @sky_sports = NewsSources::SkySportsService.new
    @guardian = NewsSources::GuardianService.new
  end

  def get_all_transfer_news
    handle_response do
      news = {
        sky_sports: @sky_sports.get_transfer_news,
        guardian: @guardian.get_transfer_news
      }

      news
    end
  end

  private

  def is_transfer_news?(title)
    # 移籍関連のキーワードを含むタイトルのみを抽出
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
    
    # タイトルを小文字に変換して、キーワードとマッチするか確認
    title_downcase = title.downcase
    keywords.any? { |keyword| title_downcase.include?(keyword) }
  end

  def build_url(path)
    return nil unless path
    path.start_with?('http') ? path : "#{self.class.base_uri}#{path}"
  end
end
