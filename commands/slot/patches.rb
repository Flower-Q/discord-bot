require 'discordrb'

module Discordrb
  module Events
    class ReactionAddEventHandler
      def matches?(event)
        return false unless event.is_a? ReactionEvent

        check_message(event) &&
          check_user(event) &&
          check_emoji(event)
      end

      private

      def check_message(event)
        @attributes[:message].nil? ||
          event.message == @attributes[:message]
      end

      def check_user(event)
        @attributes[:user].nil? ||
          event.user == @attributes[:user]
      end

      def check_emoji(event)
        [
          matches_all(@attributes[:emoji], event.emoji) do |attribute, emoji|
            match_emoji(attribute, emoji)
          end
        ].reduce(true, &:&)
      end

      def match_emoji(emoji, to_check)
        if to_check.is_a? Integer
          to_check.id == emoji
        elsif emoji.is_a? String
          to_check.name == emoji ||
            to_check.name == emoji.delete(':') ||
            to_check.id == emoji.resolve_id
        else
          to_check == emoji
        end
      end
    end
  end
end
