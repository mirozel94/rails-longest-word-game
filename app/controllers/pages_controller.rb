require 'open-uri'
require 'json'

class PagesController < ApplicationController
  def game
    @grid = generate_grid
    @attempt = params[:query]
    session[:grid] = @grid
    # @current_user = User.find_by_id(session[:current_user_id])
  end

  def score
    @attempt = params[:query]
    @grid = params[:grid]
    @end_time = Time.now
    @start_time = DateTime.parse(params[:time])
    @time_taken = (@end_time - @start_time).round(2)
    @message = score_and_message(@attempt, @grid, @time_taken)
  end

  def generate_grid
    vows =  %w{ A E I O U }
    a = Array.new(5) { (('A'..'Z').to_a - vows).sample }
    b = Array.new(4) { vows.sample }
    c = a << b
    c.shuffle
  end

  def included?(guess, grid)
    guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def compute_score(attempt, time_taken)
    time_taken > 60.0 ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end

  def score_and_message(attempt, grid, time)
    if included?(attempt.upcase, grid)
      if english_word?(attempt)
        score = compute_score(attempt, time)
        p "#{score.round(2)} points, well done!"
      else
        [0, "not an english word"]
      end
    else
      [0, "not in the grid"]
    end
  end

  def english_word?(word)
    response = open("https://wagon-dictionary.herokuapp.com/#{word}")
    json = JSON.parse(response.read)
    return json['found']
  end
end


# result = run_game(attempt, grid, start_time, end_time)

