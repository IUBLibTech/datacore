class FeaturedCollection < ActiveRecord::Base
  FEATURE_COLLECTION_LIMIT = 5
  validate :count_within_limit, on: :create
  validates :order, inclusion: { in: proc { 0..FEATURE_COLLECTION_LIMIT } }

  default_scope { order(:order) }

  def count_within_limit
    return if FeaturedCollection.can_create_another?
    errors.add(:base, "Limited to #{FEATURE_COLLECTION_LIMIT} featured collections.")
  end

  attr_accessor :presenter

  class << self
    def can_create_another?
      FeaturedCollection.count < FEATURE_COLLECTION_LIMIT
    end
  end
end
