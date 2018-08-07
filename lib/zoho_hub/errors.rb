# frozen_string_literal: true

module ZohoHub
  class RecordNotFound < StandardError
  end

  class RecordInvalid < StandardError
  end

  class InvalidTokenError < StandardError
  end

  class ZohoAPIError < StandardError
  end
end
