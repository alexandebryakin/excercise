# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BattingAveragesController, type: :request do
  describe 'POST /batting_average/process' do
    context 'when `year` is provided in the params' do
      let(:params) do
        {
          batting_file: fixture_file_upload('/files/batting.csv', 'text/csv'),
          year: 2019
        }
      end

      let(:expected) do
        [
          { 'playerID' => '1', 'yearID' => '2019', 'Team name(s)' => 'ALIAS,BALI', 'Batting Average' => '0.031' },
          { 'playerID' => '2', 'yearID' => '2019', 'Team name(s)' => 'FURIOUS', 'Batting Average' => '0.235' },
          { 'playerID' => '3', 'yearID' => '2019', 'Team name(s)' => 'ROGER', 'Batting Average' => '0.250' }
        ]
      end

      it 'returns batting averages for the required year only' do
        post('/batting_average/process', params: params)
        body = JSON.parse(response.body)

        expect(body).to eq(expected)
      end
    end

    context 'when `team` is provided in the params' do
      let(:params) do
        {
          batting_file: fixture_file_upload('/files/batting.csv', 'text/csv'),
          team: 'ALIAS'
        }
      end

      let(:expected) do
        [
          { 'playerID' => '1', 'yearID' => '2019', 'Team name(s)' => 'ALIAS,BALI', 'Batting Average' => '0.031' },
          { 'playerID' => '1', 'yearID' => '2020', 'Team name(s)' => 'ALIAS', 'Batting Average' => '0.278' }
        ]
      end

      it 'returns batting averages for the required team only' do
        post('/batting_average/process', params: params)
        body = JSON.parse(response.body)

        expect(body).to eq(expected)
      end
    end

    context 'when both `team` and `year` is provided in the params' do
      let(:params) do
        {
          batting_file: fixture_file_upload('/files/batting.csv', 'text/csv'),
          team: 'ALIAS',
          year: 2019
        }
      end

      let(:expected) do
        [
          { 'Batting Average' => '0.031', 'Team name(s)' => 'ALIAS,BALI', 'playerID' => '1', 'yearID' => '2019' }
        ]
      end

      it 'returns batting averages filtered by required params' do
        post('/batting_average/process', params: params)
        body = JSON.parse(response.body)

        expect(body).to eq(expected)
      end
    end
  end
end
