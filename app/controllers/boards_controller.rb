require 'card'

class BoardsController < ApplicationController
  def show
    region = 'ap-northeast-1'
    client = Aws::S3::Client.new(region: region)

    bucket = 'foa-v2-siteimages'
    @bucket_url = "https://#{bucket}.s3-ap-northeast-1.amazonaws.com"
    board = params[:id]
    @title = {
      information: 'F.O.Aからのお知らせ・声',
      ob: 'FOAの卒業生たち'
    }[params[:id].to_sym]

    card_ids = Card::all(client: client, bucket: bucket, board: board)
    @cards = card_ids.map do |card_id|
      Card::load(client: client, bucket: bucket, card_id: card_id)
    end

    @cards.sort! do |a,b|
      comp = a[:number] <=> b[:number] if a[:date] == b[:date]
      comp ||= b[:date] <=> a[:date]
      comp
    end

    @pager = {
      contents_per_page: 10,
      now_page: params[:now_page]&.to_i || 1,
      pages: (@cards.count / 10.0).ceil
    }

    @cards = @cards[(@pager[:contents_per_page]*(@pager[:now_page]-1))...(@pager[:contents_per_page]*@pager[:now_page])]
  end
end
#https://s3-ap-northeast-1.amazonaws.com/foa-siteimages/information/orignal/20190531-01-01.jpg
