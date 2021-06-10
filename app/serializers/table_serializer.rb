# frozen_string_literal: true

class TableSerializer
  attr_accessor :rows
  @@serializeable_fields = []

  def initialize(rows)
    @rows = rows
  end

  def self.attribute(key, as: nil, format: nil)
    @@serializeable_fields << {
      key: key,
      as: key.present? ? as : key,
      format: format
    }
  end

  def self.serializeable_fields
    @@serializeable_fields
  end

  def serializeable_fields
    @@serializeable_fields
  end

  def as_json
    rows.map(&render_serializeable_keys_only)
        .map(&render_formatted_values)
        .map(&render_key_aliases)
  end

  private

  def serializeable_keys
    @serializeable_keys ||= serializeable_fields.map { |sf| sf[:key] }
  end

  def render_serializeable_keys_only
    ->(row) { row.slice(*serializeable_keys) }
  end

  def render_key_aliases
    lambda do |row|
      aliasable = ->(sf) { sf[:as].present? }

      serializeable_fields.filter(&aliasable).each do |sf|
        new_field_name = sf[:as]
        old_field_name = sf[:key]
        value = row.delete(old_field_name)
        row.merge!(new_field_name => value)
      end
      row
    end
  end

  def render_formatted_values
    lambda do |row|
      serializeable_fields.each do |sf|
        sf[:format].present? ? row[sf[:key]] = sf[:format] % row[sf[:key]] : row
      end
      row
    end
  end
end
