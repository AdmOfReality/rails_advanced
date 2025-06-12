class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_commentable

  def create
    @comment = @commentable.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      html = ApplicationController.render(
        partial: 'comments/comment',
        locals: { comment: @comment },
        formats: [:html]
      )

      CommentsChannel.broadcast_to(
        commentable_broadcast_id(@commentable),
        {
          html: html,
          commentable_type: @commentable.class.name,
          commentable_id: @commentable.id
        }
      )

      head :ok
    else
      head :unprocessable_entity
    end
  end

  private

  def set_commentable
    klass = [Question, Answer].find { |c| params["#{c.name.underscore}_id"] }
    @commentable = klass.find(params["#{klass.name.underscore}_id"])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end

  def commentable_broadcast_id(commentable)
    "#{commentable.class.name.downcase}_#{commentable.id}"
  end
end
