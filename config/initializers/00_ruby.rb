
# Mixin to provide pagination capabilities to Enumerable collections.
#
# It allows slicing a collection using offset and limit, while attaching
# pagination metadata to the resulting object.
module Limitate
  # @return [Integer] The offset used for slicing the collection.
  attr_accessor :limitate_offset

  # @return [Integer] The maximum number of elements returned.
  attr_accessor :limitate_limit

  # @return [Integer] The total count of elements before slicing.
  attr_accessor :limitate_total

  # Slices the collection based on offset and limit.
  #
  # @param params [Hash, ActionController::Parameters, nil] Optional parameters
  #   containing :offset and :limit.
  # @param offset [Integer] Default offset if not provided in params.
  # @param limit [Integer] Default limit if not provided in params.
  # @return [Enumerable] The sliced collection with pagination metadata attached.
  def limitate(params = nil, offset: 0, limit: 10)
    result = frozen? ? dup : self
    total  = result.count
    params = params.permit(:offset, :limit) if params.respond_to?(:permit)
    offset = params.fetch(:offset, offset).to_i
    limit  = params.fetch(:limit, limit).to_i
    offset and result = result.drop(offset)
    limit  and result = result.take(limit)
    result.limitate_offset, result.limitate_limit, result.limitate_total =
      offset, limit, total
    result
  end
end

module Enumerable
  include Limitate
end
