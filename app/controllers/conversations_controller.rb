class ConversationsController < ApplicationController

  def index
    favourite_postcodes = current_user.trackings.map(&:property).map(&:postcode).uniq
    same_postcode_trackings = favourite_postcodes.map(&:properties).flatten.map(&:trackings).flatten.reject { |tracking| tracking.user == current_user }
    @similar_users = same_postcode_trackings.map(&:user).uniq
    # @users.map { |user| user.trackings.select { |tracking| c}
    @conversations = Conversation.where(sender: current_user).or(Conversation.where(recipient: current_user))
    if params[:selected_convo]
      @selected_convo = Conversation.find(params[:selected_convo])
      @selected_convo.messages.each do |message|
        message.update(read: true) if message.user_id != current_user.id
      end
    else
     @selected_convo = @conversations.last
    end
  end
  def show
    @conversation = Conversation.find(params[:id])
    @messages = @conversation.messages
  end
def create
  @user = User.find(params[:recipient_id])
 if Conversation.between(params[:sender_id],params[:recipient_id])
   .present?
    conversation = Conversation.between(params[:sender_id],
     params[:recipient_id]).first
 else
   conversation = Conversation.create!(conversation_params)
 end
  redirect_to conversation_path(conversation)
end
private
 def conversation_params
  params.permit(:sender_id, :recipient_id)
 end
end
