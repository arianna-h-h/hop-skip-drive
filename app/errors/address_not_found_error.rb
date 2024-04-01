class AddressNotFoundError < StandardError
  def initialize(message = "Address not found")
    super(message)
  end
end
