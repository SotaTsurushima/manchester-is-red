require 'rails_helper'

RSpec.describe PlayerBatch::ProcessPlayers do
  let(:sample_stats) do
    FactoryBot.attributes_for(:player, :with_stats).slice(
      :goals, :assists, :appearances, :yellow_card, :red_card, :position
    )
  end

  let(:sample_extraction_values) do
    FactoryBot.attributes_for(:player, :with_stats).slice(
      :number, :market_value, :salary, :image
    )
  end

  let(:interactor) { described_class.new }

  # 共通のモック設定
  before do
    allow(interactor).to receive(:extract_player_number).and_return(sample_extraction_values[:number])
    allow(interactor).to receive(:extract_market_value).and_return(sample_extraction_values[:market_value])
    allow(interactor).to receive(:extract_player_salary).and_return(sample_extraction_values[:salary])
    allow(interactor).to receive(:extract_image).and_return(sample_extraction_values[:image])
  end

  describe '#create_player' do
    it 'プレイヤーが作成される' do
      interactor.instance_variable_set(:@stats, sample_stats)
      
      expect { interactor.send(:create_player, 'Bruno Fernandes') }
        .to change(Player, :count).by(1)
      
      player = Player.last
      expect(player.name).to eq('Bruno Fernandes')
      expect(player.goals).to eq(3)
      expect(player.assists).to eq(7)
    end
  end

  # describe '#update_player' do
  #   it 'プレイヤーが更新される' do
  #     player = FactoryBot.create(:player, :bruno_fernandes, goals: 0, assists: 0)
  #     interactor.instance_variable_set(:@stats, sample_stats)
      
  #     interactor.send(:update_player, player)
      
  #     player.reload
  #     expect(player.goals).to eq(3)
  #     expect(player.assists).to eq(7)
  #     expect(player.appearances).to eq(25)
  #   end
  # end

  # describe '#find_player_by_name' do
  #   it '名前でプレイヤーを検索できる' do
  #     player = FactoryBot.create(:player, :bruno_fernandes)
      
  #     result = interactor.send(:find_player_by_name, 'Bruno Fernandes')
      
  #     expect(result).to eq(player)
  #   end

  #   it '存在しないプレイヤーはnilを返す' do
  #     result = interactor.send(:find_player_by_name, 'Non Existent Player')
      
  #     expect(result).to be_nil
  #   end
  # end

  # describe '#extract_stats' do
  #   it '統計データを正しく抽出' do
  #     html = <<~HTML
  #       <tr>
  #         <td data-stat="games">25</td>
  #         <td data-stat="goals">3</td>
  #         <td data-stat="assists">7</td>
  #         <td data-stat="cards_yellow">2</td>
  #         <td data-stat="cards_red">0</td>
  #         <td data-stat="position">MF</td>
  #       </tr>
  #     HTML
      
  #     mock_row = Nokogiri::HTML(html).css('tr').first
  #     interactor.instance_variable_set(:@current_row, mock_row)
      
  #     stats = interactor.send(:extract_stats)
      
  #     expect(stats).to eq(sample_stats)
  #   end
  # end

  # describe 'エラーハンドリング' do
  #   it 'プレイヤー作成でエラーが発生しても処理を続行' do
  #     interactor.instance_variable_set(:@stats, { goals: 3 })
      
  #     # 無効なデータでエラーを発生させる
  #     allow(interactor).to receive(:extract_player_number).and_return(nil)
  #     allow(interactor).to receive(:extract_market_value).and_return(nil)
  #     allow(interactor).to receive(:extract_player_salary).and_return(nil)
  #     allow(interactor).to receive(:extract_image).and_return(nil)
      
  #     expect { interactor.send(:create_player, '') }.not_to raise_error
  #   end
  # end
end