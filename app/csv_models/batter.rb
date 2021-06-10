# frozen_string_literal: true

class Batter < Table
  FIELD_PLAYER_ID = 'playerID'
  FIELD_YEAR_ID   = 'yearID'
  FIELD_TEAM_ID   = Team::FIELD_ID
  FIELD_STINT     = 'stint'
  FIELD_H         = 'H'
  FIELD_AB        = 'AB'

  BATTER_CSV_KEYS = [
    FIELD_PLAYER_ID,
    FIELD_YEAR_ID,
    FIELD_TEAM_ID,
    FIELD_STINT,
    FIELD_H,
    FIELD_AB
  ].freeze

  BATTER_CSV_KEYS.each do |field|
    define_field field
  end

  OUTPUT_KEY_BATTING_AVERAGE = 'Batting Average'
  OUTPUT_KEY_TEAM_NAMES      = 'Team name(s)'

  BATTER_OUTPUT_KEYS_ALL = BATTER_CSV_KEYS + [OUTPUT_KEY_BATTING_AVERAGE]

  def calculate_batting_averages!
    combine_by!(FIELD_YEAR_ID, FIELD_PLAYER_ID, with: rows) do |subset, evaluator|
      ba = batting_average(subset)

      evaluator.build_field ba, as: OUTPUT_KEY_BATTING_AVERAGE
    end
  end

  def combine_teams_by_player!
    combine_by!(FIELD_YEAR_ID, FIELD_PLAYER_ID, with: rows) do |subset, evaluator|
      team_names = subset.map { |row| row[Team::FIELD_NAME] }

      evaluator.build_field team_names.join(','), as: OUTPUT_KEY_TEAM_NAMES
    end
  end

  private

  def batting_average(rows)
    hits = rows.sum { |row| row[FIELD_H] }
    at_bats = rows.sum { |row| row[FIELD_AB] }
    (hits.to_f / at_bats.to_f).round(3)
  end
end
