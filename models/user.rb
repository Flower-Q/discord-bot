class User
  include Mongoid::Document

  field :_id, type: String, overwrite: true
  field :gold, type: Integer, default: 0
  field :last_check_in_date, type: String
end
