# frozen_string_literal: true

class BatterSerializer < TableSerializer
  attribute Batter::FIELD_PLAYER_ID
  attribute Batter::FIELD_YEAR_ID
  attribute Batter::OUTPUT_KEY_TEAM_NAMES
  attribute Batter::OUTPUT_KEY_BATTING_AVERAGE, format: '%.3f'
end
