module Command
  # @return [Discordrb::User]
  def user
    @event.user
  end

  # @return [Discordrb::Message]
  def message
    @event.message
  end

  # @return [Discordrb::Channel]
  def channel
    @event.channel
  end

  # @return [Discordrb::Bot]
  def bot
    @event.bot
  end

  # @return [Discordrb::Profile]
  def bot_user
    @event.bot.bot_user
  end

  def respond(text)
    @event.respond(text)
  end

  def respond_with_mention(text)
    respond("#{@event.user.mention} #{text}")
  end
end
