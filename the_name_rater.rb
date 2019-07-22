#!/usr/bin/ruby
# coding: utf-8

# Libraries!
require 'discordrb'
require 'yaml'

# Configuration, this file has lotsa secrets!
CONFIG = YAML.load_file('config.yaml')

$bot = Discordrb::Bot.new(
  token: CONFIG[:token],
  client_id: CONFIG[:client_id]
)

# Gets a line that the name rater will say in response to changing a name
# These literally just came from Bulbapedia: https://bulbapedia.bulbagarden.net/wiki/Name_Rater#Quotes
def get_name_rater_quote(nick)
  [
    "#{nick} is it? That is a truly impeccable name! Take good care of #{nick}!",
    "OK! This Pokémon has been renamed as #{nick}! That's a better name than before!",
    "Hm... #{nick}? What a great name! It's perfect. Treat #{nick} with loving care.",
    "All right. This Pokémon is now named #{nick}! That's a better name than before! Well done!",
    "Hmmm... #{nick} it is! This is a magnificent nickname! It is impeccably beyond reproach! You'll do well to cherish your #{nick} now and beyond.",
    "Done! From now on, this Pokémon shall be known as #{nick}! It is a better name than before! How fortunate for you!",
    "Done! From now on, this Pokémon shall be known as #{nick}! It is a better name than before! Why this name's luckiness... Why, it goes right off the scale! You'll do well to cherish your #{nick} now and beyond.",
    "Done! From now on, this Pokémon shall be known as #{nick}! Hmhm… It is a name that is vastly superior than before! Its luckiness is simply unsurpassed! Keep treating your #{nick} with love and affection!",
    "Done! How about that? From now on, this Pokémon shall be known as #{nick}! It is a better name than before, isn't it? Good for you!",
    "Done! From now on, this Pokémon shall be known as #{nick}! You're right, that does seem to fit it better. Nicely done!",
    "Hmmm. #{nick}! That is a truly impeccable nickname! I can't say anything bad about it! Take good care of #{nick}!"
  ].sample
end

# If you PM the bot, it will have to go based on server configuration
# settings in the yml file, and works by matching the currently
# visible name since you can't easily @ people when they aren't also
# in the DM conversation
$bot.pm do |event|
  command = event.message.text.split(' ')

  server = $bot.servers.find do |server|
    server.first == CONFIG[:server_id].to_i
  end[1]

  name, nick = (1...command.length).map do |i|
    [command[0..i-1].join(" "), command[i..-1].join(" ")]
  end.find do |command_split|
    name, _ = command_split

    not server.members.find do |user|
      user.display_name == name
    end.nil?
  end

  member = server.members.find do |user|
    user.display_name == name
  end

  if member.nil?
    event.send_message("Hmm. I don't see any Pokemon like that around here. Do come visit again!")
  else
    member.nick = nick
    event.send_message(get_name_rater_quote(nick))
  end
end

# This just extracts the ID and name from the message with a regex,
# and uses the current message's context to change a user's name
$bot.mention do |event|
  _, user_id, nick = event.message.text.match(/<@!?\d+>\s+<@!?(\d+)> (.*)/).to_a

  member = event.server.members.find do |user|
    user.id == user_id.to_i
  end

  if member.nil?
    event.send_message("Hmm. That doesn't seem right. Try @ing the user and a name you wish me to rate!")
  else
    member.nick = nick
    event.send_message(get_name_rater_quote(nick))
  end
end

# Running it, not async, but if you want it to be, you can throw a
# `true` in the run() command
$bot.run()
