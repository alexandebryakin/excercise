# frozen_string_literal: true

require 'csv'
require 'pry'

class Table
  attr_accessor :scopes

  def where(field, value)
    @scopes << {
      type: 'where',
      meta: {
        field: field,
        value: value
      }
    }

    self
  end

  def select(*fields)
    @scopes << {
      type: 'select',
      meta: {
        fields: fields
      }
    }

    self
  end

  def joins(table_instance, field)
    @scopes << {
      type: 'joins',
      meta: {
        table: table_instance,
        field: field
      }
    }

    apply_joins(rows)

    self
  end

  def aggregate(new_field, with: nil)
    rows.map do |row|
      value = yield(row, with)
      row.merge!(new_field => value)
    end

    @@fields << new_field
  end

  def apply_joins(rows)
    scopes_for_joins = @scopes.select { |sc| sc[:type] == 'joins' }

    rows.map do |row|
      scopes_for_joins.each do |scope|
        table = scope[:meta][:table]
        field = scope[:meta][:field]

        matching_row = table.rows.find { |joined_row| joined_row[field] == row[field] }
        to_merge = matching_row.blank? ? table.fields.map { |field| [field, nil] }.to_h : matching_row

        row.merge!(to_merge)
      end

      row
    end
  end

  def apply_where(rows)
    scopes_for_conditions = @scopes.select { |sc| sc[:type] == 'where' }
    conditions = scopes_for_conditions.map { |sc| [sc[:meta][:field], sc[:meta][:value]] }

    rows.filter do |row|
      conditions.all? { |field, value| row[field].to_s == value.to_s }
    end
  end

  def apply_select(rows)
    scopes_for_select = @scopes.select { |sc| sc[:type] == 'select' }
    selected_fields = scopes_for_select.map { |sc| sc[:meta][:fields] }.flatten
    selected_fields = fields if selected_fields.blank?

    rows.map do |row|
      row.slice(*selected_fields)
    end
  end

  def fetch!
    filtered_rows = apply_where(rows)

    apply_select(filtered_rows)
  end

  def group_deep(fields, rows)
    return yield(rows) if fields.blank?

    field = fields.first

    grouped = rows.group_by { |row| row[field] }

    grouped.values.each do |grouped_rows|
      group_deep(fields.slice(1, fields.count - 1), grouped_rows) { |subset| yield(subset) }
    end
    fields.shift
  end

  def combine_by(*fields, with:)
    rows_ = with

    group_deep(fields, rows_) do |subset|
      value = yield(subset, Evaluator)
      subset.each { |row| row.merge!(value) }
    end

    rows_
  end

  def combine_by!(*fields, with:)
    @rows = combine_by(*fields, with: with) do |subset, evaluator|
      yield(subset, evaluator)
    end
  end

  class Evaluator
    def self.build_field(value, as:)
      field_name = as
      { field_name => value }
    end
  end
  # <<<<<<<

  @@fields = []
  attr_accessor :csv_content
  attr_accessor :rows

  def initialize(csv_content)
    @scopes = []
    @csv_content = csv_content
  end

  def self.fields
    @@fields
  end

  def fields
    @@fields
  end

  def self.define_field(field)
    @@fields << field.to_s
  end

  protected

  def data
    @data ||= CSV.parse(csv_content, headers: true, skip_blanks: true)
  end

  def rows
    @rows ||= cleanup(data)
  end

  def cleanup(data)
    stripped = ->(header, value) { [header.to_s.strip, value.to_s.strip] }

    data = data.map(&:to_h).map { |row| row.map(&stripped).to_h }
    rows = data.map { |row| row.slice(*fields) }
    rows.select { |row| row.values.all?(&:present?) }
  end
end
