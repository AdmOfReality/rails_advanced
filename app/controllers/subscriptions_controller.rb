class SubscriptionsController < ApplicationController
  before_action :authenticate_user!

  authorize_resource

  def create
    @question = Question.find(params[:question_id])
    if current_user.subscribed_of?(@question)
      flash[:notice] = 'Already subscribed'
    else
      @subscription = current_user.subscribe!(@question)

      flash[:notice] = 'Subscribed successfully'
    end
  end

  def destroy
    @subscription = Subscription.find(params[:id])

    return unless current_user.subscribed_of?(@subscription.question)

    @subscription.destroy
    flash[:notice] = 'Unsubscribed successfully'
  end
end
