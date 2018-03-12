require 'sinatra'
require 'sinatra/json'
require 'json'
require 'csv'

class MythicalManMonth < Sinatra::Base
  MYTHICAL_MAN_MONTH_CHAPTER = [
    "タールの沼",
    "人月の神話",
    "外科手術チーム",
    "貴族政治、民主政治、そしてシステムデザイン",
    "セカンドシステム症候群",
    "命令を伝える",
    "バベルの塔は、なぜ失敗に終わったか？",
    "予告宣言する",
    "5ポンド袋に詰め込んだ10ポンド",
    "文章の前提",
    "1つは捨石にするつまりで",
    "切れ味のいい道具",
    "全体と部分",
    "破局を生み出すこと",
    "もう1つの顔",
    "銀の弾などない",
    "「銀の弾などない」再発射"
  ]

  configure do
    set :environment, :production
  end

  def initialize
    @file_name = './src/maxims.csv'
    load_csv
  end

  def load_csv
    @proverbs = CSV.read(@file_name)
  end

  post '/maxims' do
    op, *text = params[:text].split
    case op
    when nil, 'get'
      proverb, chapter = @proverbs.to_a.drop(1).sample
      attachments = [{
          "fields": [
                      {
                        "title": "第#{chapter.to_i}章",
                        "value": MYTHICAL_MAN_MONTH_CHAPTER[chapter.to_i-1]
                      }
          ]
        }
      ]
      data = {response_type: "in_channel", content_type: "application/json" ,
              text: proverb, attachments: attachments}
    when 'list'
      res_text = @proverbs.inject("") { |acc, l | "#{acc}> #{l["proverb"]}\n\n"}
      data = {response_type: "in_channel", content_type: "application/json" ,
              text: res_text}
    when 'add'
      CSV.open(@file_name, 'w') do |f|
        f << text
      end
      load_csv
    end
    json data
  end

  get '/test' do
    "test"
  end
end

