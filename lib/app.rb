require 'sinatra'
require 'sinatra/json'
require 'json'


class MythicalManMonth < Sinatra::Base
  configure do
    set :environment, :production
  end

  def initialize
    @proverbs = [
      "時間が足りなかったせいで失敗したプログラミング・プロジェクトは、その他のすべての原因で失敗したプログラミング・プロジェクトよりも多い。",
      "私たちが使っている見積もり手法は、コスト計算を中心に作られたものであり、労力と進捗を混同している。人月は、人を惑わす危険な神話である。なぜなら、人月は、人と月が置き換え可能であることを暗示しているからである。",
      "ブルックスの法則：遅れているソフトウェア・プロジェクトに人員を投入しても、そのプロジェクトをさらに遅らせるだけである。",
      "ソフトウェア・プロジェクトに人員を追加すると、全体として必要となる労力が、次の3つの点で増加する。すなわち、再配置そのものに費やされる労力とそれによる作業の中断、新しい人員の教育、追加の相互連絡である。"
    ]
  end

  post '/maxims' do
    op, text = params[:text].split
    case op
    when nil, 'get'
      res_text = "> #{@proverbs.sample}"
      data = {response_type: "in_channel", content_type: "application/json" ,text: res_text}
    when 'list'
      res_text = @proverbs.each_with_index.inject("") { |acc, (l, i) | "#{acc}> #{i+1}. #{l}\n\n"}
      data = {response_type: "in_channel", content_type: "application/json" ,text: res_text}
    when 'add'
      @proverbs << text
      data = {response_type: "ephemeral", content_type: "application/json" ,text: "Registered!"}
    when 'delete'
      deleted_text = @proverbs.delete_at(text.to_i-1)
      data = {response_type: "ephemeral", content_type: "application/json" ,text: "Delete Complete.\n>#{deleted_text}"}
    end
    json data
  end

  get '/test' do
    "test"
  end
end

