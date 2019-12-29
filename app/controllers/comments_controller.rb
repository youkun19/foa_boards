class CommentsController < ApplicationController
  def update
    @comment = Comment.find(params[:id])
    @comment.update(comment_params)
    redirect_to request.headers[:HTTP_REFERER]
  end

  private

  def comment_params
    params.require(:comment).permit(:comment)
  end
end
