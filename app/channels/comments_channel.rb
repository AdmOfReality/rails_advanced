class CommentsChannel < ApplicationCable::Channel
  def subscribed
    stream_for "#{params[:commentable_type].downcase}_#{params[:commentable_id]}"
  end
end
