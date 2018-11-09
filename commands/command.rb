module Command
  def user
    @event.user
  end

  def message
    @event.message
  end

  def channel
    @event.channel
  end

  def respond(text)
    @event.respond(text)
  end

  def respond_with_mention(text)
    respond("#{@event.user.mention} #{text}")
  end

  def bot_user
    @event.bot.bot_user
  end
end
