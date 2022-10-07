# frozen_string_literal: true

module ZohoHub
  class Error < StandardError; end

  class RecordNotFound < Error; end

  class RecordInvalid < Error; end

  class InvalidTokenError < Error; end

  class InternalError < Error; end

  class InvalidRequestError < Error; end

  class InvalidModule < Error; end

  class NoPermission < Error; end

  class AuthenticationFailure < Error; end

  class MandatoryNotFound < Error; end

  class RecordInBlueprint < Error; end

  class TooManyRequestsError < Error; end

  class RecordNotInProcessError < Error; end

  class OauthScopeMismatch < Error; end

  class ZohoAPIError < Error; end
end
