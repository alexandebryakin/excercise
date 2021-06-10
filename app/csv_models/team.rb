# frozen_string_literal: true

class Team < Table
  FIELD_ID = 'teamID'
  FIELD_NAME = 'name'

  define_field FIELD_ID
  define_field FIELD_NAME
end
