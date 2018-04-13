require 'sinatra'
require 'sinatra/json'
require 'json'
require 'csv'
require 'redis'

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
    @redis = Redis.new
    load_csv
  end

  def load_csv
    CSV.read(@file_name).each do |k, v|
      add_proverbs(k, v)
    end
  end

  def get_proverbs
    @redis.keys("prov-*").map { |k| Marshal.load(@redis.get(k)) }
  end

  def add_proverbs(prov, chapter)
    @redis.set "prov-#{Digest::SHA1.hexdigest(prov)}", Marshal.dump([prov,chapter])
  end

  def delete_proverbs(key)
    @redis.del key
  end

  def list_piece(text)
    {
      "text": text,
     "callback_id": "prov-#{Digest::SHA1.hexdigest(text)}",
     "actions": [
                  {
                    "name": "delete",
                   "text": "Delete",
                   "style": "danger",
                   "type": "button",
                   "value": "delete",
                   "confirm": {
                                "title": "削除",
                               "text": "本当に削除しますか?",
                               "ok_text": "はい",
                               "dismiss_text": "いいえ"
                              }
                  }

                ]
    }
  end

  post '/maxims' do
    op, *text = params[:text].split
    case op
    when nil, 'get'
      proverb, chapter = get_proverbs.sample
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
      attachments = get_proverbs.inject([]) { |acc, l| acc << list_piece(l.first)}
      data = {content_type: "application/json" , attachments: attachments}
    when 'add'
      CSV.open(@file_name, 'a') do |f|
        f << text
      end
      proverb, chapter = text
      add_proverbs(proverb, chapter)
      attachments = [{
                       "fields": [
                                   {
                                     "title": "第#{chapter.to_i}章",
                                    "value": MYTHICAL_MAN_MONTH_CHAPTER[chapter.to_i-1]
                                   }
                                 ]
                     }
                    ]
      data = {content_type: "application/json", text: "Success \n#{proverb}", attachments: attachments}
    end
    json data
  end

  post '/results' do
    content_type :json
    results = JSON.parse(params[:payload])
    if results["callback_id"]
      delete_proverbs(results["callback_id"])
      data = {content_type: "application/json", text: "削除しました。"}
    else
      data = {content_type: "application/json", text: "不正な動作です"}
    end
    json data
  end

  get '/test' do
    'test'
  end
end

