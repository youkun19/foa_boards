module KakuninBoardsHelper
  def find_comment(comment_id)
    @comment = Comment.where(comment_id: comment_id).first
    if not @comment then
      @comment = Comment.new(comment_id: comment_id, comment: %Q[【タイトル】\n（変更内容を入力）\n\n【メッセージ】\n（変更内容を入力）\n\n\n\n---\n公開して良ければ、\nここに「公開してください」と記入ください。])
      @comment.save
    end
    @comment
  end
end
