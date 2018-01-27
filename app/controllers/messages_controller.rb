class MessagesController < ApplicationController

  before_action :redirect_login

  def self.permission_definition
    {
        :global_options => {
            :text => 'Private Messages',
            options: [:true, :false],
        },
        :permissions_sets => [{
                                  :actions => [:multi_send]
                              }]
    }
  end

  def index
    if params[:clear] && params[:user_id].to_i == current_user.id
      Message.where(receiver: current_user).delete_all
      flash[:notice] = 'All messages have been cleared.'
    end

    @sent = Message.where(sender: current_user).order('created_at DESC').paginate(:page => params[:page], :per_page => 15)
    @received = Message.where(receiver: current_user).order('created_at DESC').paginate(:page => params[:page], :per_page => 15)
  end

  def search
    list = User.select('username, id').where('username LIKE ?', "#{params[:q].gsub('_', '\_')}%").limit(5)
    res = []
    list.each do |u|
      res << {id: u.id, name: u.username}
    end
    render :json => res.to_json
  end

  def compose
    @message = Message.new
    @multi = current_user.has_permission?(:messages_controllers, :multi_send, true)
    if params.has_key?(:to)
      @reply_to = User.find_by_id(params[:to])
    end
  end

  def create
    if params.has_key?(:recipients)
      @multi = current_user.has_permission?(:messages_controllers, :multi_send, true)

      recipients = params[:recipients].split(',')

      redirect_if_fail(!recipients.empty?, messages_path, 'At least one recipient must be specified.'); return if performed?
      redirect_if_fail(!(!@multi && recipients.length > 1), messages_path, 'You are only allowed to specify one recipient.'); return if performed?

      if @multi && recipients.length > 1
        good = true
        recipients.each do |rec|
          receiver = User.find_by_id(rec)
          if receiver.nil?
            good = false
            break
          end
          message = Message.new(
              sender: current_user,
              content: params[:content],
              receiver: receiver
          )
          unless message.save
            good = false
            break
          else
            receiver.alert('new-msg:' + message.id.to_s, 'You have a new message from ' + current_user.username + '!', messages_path)
          end
        end
        if good
          redirect_to messages_path, notice: 'Message sent.'
        else
          render :compose, alert: 'Failed to send message.'
        end
      else
        receiver = User.find_by_id(params[:recipients])
        if receiver.nil?
          render :compose, alert: 'Recipient not found!'
          return
        end
        message = Message.new(
            sender: current_user,
            content: params[:content],
            receiver: receiver
        )
        if message.save
          receiver.alert('new-msg:' + message.id.to_s, 'You have a new message from ' + current_user.username + '!', messages_path)
          redirect_to messages_path, notice: 'Message sent.'
        else
          render :compose, alert: 'Failed to send message.'
        end
      end
    else
      receiver = User.find_by_id(params[:recipient])
      if receiver.nil?
        render :compose, alert: 'Recipient not found!'
        return
      end
      message = Message.new(
          sender: current_user,
          content: params[:content],
          receiver: receiver
      )
      if message.save
        receiver.alert('new-msg:' + message.id.to_s, 'You have a new message from ' + current_user.username + '!', messages_path)
        redirect_to messages_path, notice: 'Message sent.'
      else
        render :compose, alert: 'Failed to send message.'
      end
    end
  end

  def delete
    Message.where(:id => params[:id]).delete_all
    flash[:notice] = 'You have deleted a message.'
    redirect_to messages_path
  end
end
