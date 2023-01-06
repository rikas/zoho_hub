# frozen_string_literal: true

module ZohoHub
  class Error < StandardError; end

  class RecordNotFound < Error; end

  class RecordInvalid < Error; end

  class InvalidTokenError < Error; end

  class InternalError < Error; end

  class InvalidRequestError < Error; end

  class InvalidQueryError < Error; end

  class InvalidModule < Error; end

  class NoPermission < Error; end

  class AuthenticationFailure < Error; end

  class MandatoryNotFound < Error; end

  class RecordInBlueprint < Error; end

  class TooManyRequestsError < Error; end

  class RecordNotInProcessError < Error; end

  class OauthScopeMismatch < Error; end

  class ZohoAPIError < Error; end

  class BlueprintTransitionNotFound < Error
    attr_reader :new_status

    def initialize(new_status)
      @new_status = new_status
      @message = "Could not find Blueprint transition to status #{new_status}"
      super()
    end
  end
end
