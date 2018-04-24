class Flagging < ApplicationRecord
  belongs_to :flaggable, polymorphic: true
  belongs_to :flag
end
