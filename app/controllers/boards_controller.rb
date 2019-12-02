class BoardsController < ApplicationController
  def show
    region = 'ap-northeast-1'
    client = Aws::S3::Client.new(region: region)

    bucket = 'foa-siteimages'
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
      contents_per_page: 5,
      now_page: params[:now_page]&.to_i || 1,
      pages: (@cards.count / 5.0).ceil
    }

    @cards = @cards[(@pager[:contents_per_page]*(@pager[:now_page]-1))...(@pager[:contents_per_page]*@pager[:now_page])]
  end


  class Card
    attr_reader :contents

    def self.all(client:, bucket:, board: board)
      o = new(client: client, bucket: bucket, prefix: board)
      cards = o.contents.select { |c| %r[^#{board}/\d{8}-\d{2}/card.txt$] =~ c.key }
      cards.map { |c| c.key[%r[#{board}/\d{8}-\d{2}/]] }
    end

    def self.load(client:, bucket:, card_id: card_id)
      o = Card.new(client: client, bucket: bucket, prefix: card_id)
      o.load
    end

    def initialize(client:, bucket:, prefix: nil)
      @client = client
      @bucket = bucket
      @prefix = prefix
      @contents = _contents
    end

    def load
      m = %r[/(\d{8})-(\d{2})/$].match(@prefix)
      { date: Date.strptime(str=m[1], format='%Y%m%d'),
        number: m[2],
        date_number: "#{m[1]}-#{m[2]}",
        card_txt: get_card_txt,
        images: get_images,
        attachments: get_attachments }
    end

    private

    def get_card_txt
      key = @contents.select { |c| %r[/card.txt$] =~ c.key }[0]&.key
      return {} unless key
      io = _object(key: key)
      YAML.load(io)
    end

    def get_images
      keys = @contents.select { |c| %r[jpg$|JPG$] =~ c.key }.map {|i| i.key}
      keys.map do |key|
        io = _object(key: key)
        {key: key, name: File.basename(key),
         s3_url: "https://s3-ap-northeast-1.amazonaws.com/#{@bucket}/#{key}",
         data: ImageData.new(io: io)}
      end
    end

    def get_attachments
      keys = @contents.select { |c| %r[pdf$] =~ c.key }.map {|a| a.key}
      keys.map do |key|
        {key: key, name: File.basename(key)}
      end
    end

    def _contents(marker: nil)
      res_contents = []
      resp = @client.list_objects(bucket: @bucket, prefix: @prefix, marker: marker)
      res_contents = contents(marker: resp.next_marker) if resp.next_marker
      res_contents.concat(resp.contents)
    end

    def _object(key:)
      @client.get_object(bucket: @bucket, key: key).body
    end

    class ImageData
      def initialize(io:)
        @io = io
      end

      def print(width:)
        mmi= MiniMagick::Image.read(@io.read)
        mmi.resize width
        Base64.encode64(mmi.to_blob)
      end

      def print(width:)
        mmi= MiniMagick::Image.read(@io.read)
        mmi.resize width
        Base64.encode64(mmi.to_blob)
      end
    end
  end
end
#https://s3-ap-northeast-1.amazonaws.com/foa-siteimages/information/orignal/20190531-01-01.jpg
