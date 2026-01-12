class PushSubscriptionsController < ApplicationController
  def create
    subscription = current_user.push_subscriptions.find_or_initialize_by(
      endpoint: params[:endpoint]
    )
    subscription.p256dh = params[:p256dh]
    subscription.auth = params[:auth]

    if subscription.save
      render json: { success: true }
    else
      render json: { success: false, errors: subscription.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    subscription = current_user.push_subscriptions.find_by(endpoint: params[:endpoint])
    subscription&.destroy
    render json: { success: true }
  end
end
