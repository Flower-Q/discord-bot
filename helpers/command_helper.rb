class CommandHelper
  class << self
    def execute(command_class, regex, event)
      matches = event.message.content.match(regex).captures
      _, *args = matches
      command_instance = command_class.new(event)
      command_instance.run(*args)
    end
  end
end
