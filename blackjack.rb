class Card
  attr_reader :suit, :value

  def initialize (s,v)
    @suit = s
    @value = v
  end

  def to_s
    "The #{value} of #{suit}"
  end
end

class Deck
  attr_accessor :cards
  def initialize
    @cards = []

    ['Hearts','Spades','Diamonds','Clubs'].each do |suit|
      ['A','2','3','4','5','6','7','8','9','10','J','Q','K'].each do  |value|
        @cards << Card.new(suit, value)
      end
    end
  end

  def shuffle!
    cards.shuffle!
  end

  def deal
    cards.pop
  end
end

module Hand
  def add_card new_card
    cards << new_card
  end

  def show_cards
    puts "---- #{name}'s hand ----" 
    cards.each do |card|
      puts "=> #{card}"
    end
    puts "Total is #{total}",""
  end

  def total 
    total = 0

    cards.each do |card|
      if card.value == 'A'
        total += 11
      elsif card.value.to_i == 0 # J, Q, K
        total += 10
      else
        total += card.value.to_i
      end
    end

    # correct for Aces
    cards.select {|card| card.value == 'A'}.count.times do
      total -= 10 if total > Blackjack::BLACKJACK_AMOUNT
    end

    total
  end

  def blackjack?
    total == Blackjack::BLACKJACK_AMOUNT
  end

  def busted?
    total > Blackjack::BLACKJACK_AMOUNT
  end
end

class Player
  attr_accessor :cards, :name
  include Hand

  def initialize name
    @name = name
    @cards = []
  end
end

class Dealer
  attr_reader :name
  attr_accessor :cards
  include Hand

  def initialize name
    @name = name
    @cards = []
  end

  def show_one_card
    puts "---- #{name}'s hand ----" 
    puts "=> #{cards[0]}"
    puts "=> The ? of ?"
  end    
end

class Blackjack
  attr_accessor :player, :dealer, :deck

  BLACKJACK_AMOUNT = 21
  DEALER_HIT_MIN = 17

  def initialize
    # create dealer
    @dealer = Dealer.new 'Dealer'
    @player = Player.new 'Name'
    @deck = Deck.new
  end

  def start
    puts 'Welcome to blackjack!'
    set_player_name
    play
  end

  def set_player_name
    puts 'What\'s your name?'
    player.name = gets.chomp
  end

  def reset
    deck = Deck.new
    player.cards = []
    dealer.cards = []
  end

  def deal_cards
    # first round
    player.add_card deck.deal
    dealer.add_card deck.deal
    player.add_card deck.deal
    dealer.add_card deck.deal
  end

  def first_show
    dealer.show_one_card
    player.show_cards
  end

  def show_again person
    # only show again when getting new card
    person.show_cards if person.cards.length > 2
  end

  def compare
    # compare total points
    if dealer.total > player.total
      puts "Sorry, dealer wins."
    elsif dealer.total < player.total
      puts "Congratulations, you win!"
    else
      puts "It's a tie!"
    end
  end

  def play
    deck.shuffle!
    reset
    deck = Deck.new

    deal_cards
    first_show

    player_turn
    show_again player

    # show dealer's second card
    puts "#{dealer.name} turns over her second card."
    dealer.show_cards

    dealer_turn
    show_again dealer

    compare

    play_or_exit
  end

  def player_turn 
    if player.blackjack?
      puts "You hit blackjack! You win!"
      play_or_exit
    end

    while player.total < BLACKJACK_AMOUNT
      # let the player choose to hit or stay
      puts "#{player.name}, what would you like to do? 1) hit 2) stay?"
      hit_or_stay = gets.chomp
      if !['1','2'].include?(hit_or_stay)
        puts "Error. You must enter 1 or 2."
        next
      end

      # stay
      break if hit_or_stay == '2'

      # hit
      new_card = deck.deal
      puts "Dealing card to #{player.name}: #{new_card}"
      player.add_card new_card
      puts "Total is #{player.total}"
      if player.blackjack?
        puts "You hit blackjack! You win!"
        play_or_exit
      end

      if player.busted?
        puts "Oops. Looks like you busted."
        play_or_exit
      end
    end
  end

  def dealer_turn
    while dealer.total < DEALER_HIT_MIN
      new_card = deck.deal
      puts "Dealing card to #{dealer.name}: #{new_card}"
      dealer.add_card new_card
      puts "Total is #{dealer.total}"

      if dealer.blackjack?
        puts "#{dealer.name} hit blackjack! You lose."
        play_or_exit
      end

      if dealer.busted?
        puts "Oops. #{dealer.name} busted. You win!"
        play_or_exit
      end
    end
  end

  def play_or_exit
    puts "Do you want to play again? 1) yes 2) no"
    input = gets.chomp
    play if input == '1'
    exit
  end

end

game = Blackjack.new
game.start