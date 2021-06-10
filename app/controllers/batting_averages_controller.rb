# frozen_string_literal: true

class BattingAveragesController < ActionController::API
  def process_file
    content = params[:batting_file].read
    batters = Batter.new(content)
    teams = Team.new(File.read("#{Rails.root}/db/teams.csv"))

    batters = batters.joins(teams, Team::FIELD_ID)
    batters.calculate_batting_averages!
    batters.combine_teams_by_player!

    batters.select(Batter::FIELD_PLAYER_ID,
                   Batter::FIELD_YEAR_ID,
                   Batter::OUTPUT_KEY_TEAM_NAMES,
                   Batter::OUTPUT_KEY_BATTING_AVERAGE)

    batters = batters.where(Batter::FIELD_YEAR_ID, params[:year]) if params[:year].present?
    batters = batters.where(Team::FIELD_NAME, params[:team]) if params[:team].present?

    result = batters.fetch!.uniq

    render json: BatterSerializer.new(result).as_json
  end
end
