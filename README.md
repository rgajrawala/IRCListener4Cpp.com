# IRCListener4Cpp.com
An IRC bot that listens for new posts on [cplusplus.com](http://www.cplusplus.com/).

## How To
### Install
+ Install [Nokogiri](http://www.nokogiri.org/) and [Cinch](https://github.com/cinchrb/cinch).
+ Copy `config.example.rb` to `config.rb` and edit the configuration as needed.

### Run
+ For development, run `./listener.rb`.
+ For production, run `./run.sh`. Check `listener.log` to make sure you have no errors.

### Commands
All command are prefixed with `<bot-nick>: `.
+ `['quit', 'exit', 'die']` => Quit the bot.
+ `['start']` => Start listening for new posts.
+ `['stop', 'shutup']` => Stop listening for new posts.
+ `['save', 'backup']` => Back up the saved post ids.
