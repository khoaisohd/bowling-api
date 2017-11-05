module GameManager extend self
  FRAME_LIMIT  = 10

  def add_roll(roll_params)
    ActiveRecord::Base.transaction do
      game_id = roll_params['game_id']
      username = roll_params['username']

      game = Game.find(game_id)
      raise ActiveRecord::RecordInvalid unless game.usernames.include?(username)

      roll = game.rolls.create!(roll_params)
      rolls = game.rolls.where(username: username).order(created_at: :asc)
      raise ActiveRecord::RecordInvalid unless follow_rules?(rolls)
      return roll
    end
  end

  def compute_results(game)
    results = []
    map = {}

    game.rolls.each do |roll|
      map[roll.username] = [] unless map.key?(roll.username)
      map[roll.username] << roll
    end

    map.each do |username, rolls|
      results << compute_result_for_user(username, rolls)
    end

    results
  end

  private

  def compute_result_for_user(username, rolls)
    result = {
      score: 0,
      username: username,
      frames: []
    }

    i = 0

    while i < rolls.size do
      frame = {
        rolls: [rolls[i]]
      }
      result[:frames] << frame
      is_last_frame = result[:frames].size == FRAME_LIMIT

      if strive?(i, rolls)
        frame[:score] = 10 + sum_two_rolls(i + 1, rolls)
        frame[:rolls] << rolls[i + 1] << rolls[i + 2] if is_last_frame
        i += is_last_frame ? 3 : 1

      elsif spare?(i, rolls)
        frame[:rolls] << rolls[i + 1]
        frame[:score] = 10 + sum_one_roll(i + 2, rolls)
        frame[:rolls] << rolls[i + 2] if is_last_frame
        i += is_last_frame ? 3 : 2

      else
        frame[:rolls] << rolls[i + 1]
        frame[:score] = sum_two_rolls(i, rolls)
        i += 2
      end

      frame[:rolls].compact!
      result[:score] += frame[:score]
    end

    result[:completed] = i == rolls.size && is_last_frame

    return result
  end

  def follow_rules?(rolls)
    frames_count = 0
    i = 0

    while i < rolls.size do
      frames_count += 1
      return false if frames_count > FRAME_LIMIT
      is_last_frame = frames_count == FRAME_LIMIT

      if strive?(i, rolls)
        i += is_last_frame ? 3 : 1
      elsif spare?(i, rolls)
        i += is_last_frame ? 3 : 2
      else
        return false if sum_two_rolls(i, rolls) > 10
        i += 2
      end
    end

    return true
  end

  def strive?(id, rolls)
    rolls[id].score == 10
  end

  def spare?(id, rolls)
    sum_two_rolls(id, rolls) == 10
  end

  def sum_two_rolls(id, rolls)
    score = 0
    score += rolls[id].score if id < rolls.size
    score += rolls[id + 1].score if id + 1 < rolls.size
    score
  end

  def sum_one_roll(id, rolls)
    score = 0
    score += rolls[id].score if id < rolls.size
    score
  end
end
