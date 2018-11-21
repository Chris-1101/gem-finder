class ConversationsController < ApplicationController

  def index
    @users = User.all
    @conversations = Conversation.where(sender: current_user).or(Conversation.where(recipient: current_user))
  end
  def show
    @conversation = Conversation.find(params[:id])
    @messages = @conversation.messages
  end
def create
  @user = User.find(params[:recipient_id])
 if Conversation.between(params[:sender_id],params[:recipient_id])
   .present?
    @conversation = Conversation.between(params[:sender_id],
     params[:recipient_id]).first
 else
  @conversation = Conversation.create!(conversation_params)
 end
redirect_to conversation_path(@conversation)
end
private
 def conversation_params
  params.permit(:sender_id, :recipient_id)
 end
end
