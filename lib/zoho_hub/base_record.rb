# frozen_string_literal: true

require 'zoho_hub/response'
require 'zoho_hub/with_connection'
require 'zoho_hub/with_attributes'
require 'zoho_hub/with_validations'
require 'zoho_hub/string_utils'

module ZohoHub
  class BaseRecord
    include WithConnection
    include WithAttributes
    include WithValidations

    # Default number of records when fetching all.
    DEFAULT_RECORDS_PER_PAGE = 200

    # Default page number when fetching all.
    DEFAULT_PAGE = 1

    # Minimum number of records to fetch when fetching all.
    MIN_RECORDS = 2

    class << self
      def request_path(name = nil)
        @request_path = name if name
        @request_path ||= StringUtils.pluralize(StringUtils.demodulize(to_s))
        @request_path
      end

      def find(id)
        body = get(File.join(request_path, id.to_s))
        response = build_response(body)

        if response.empty?
          raise RecordNotFound, "Couldn't find #{request_path.singularize} with 'id'=#{id}"
        end

        new(response.data.first)
      end

      def find_all(ids)
        ids = Array(ids).join(',')
        body = get(File.join(request_path), ids: ids)
        response = build_response(body)

        if response.empty?
          raise RecordNotFound, "Couldn't find #{request_path.singularize} with 'ids'=#{ids}"
        end

        response.data.map { |json| new(json) }
      end

      def where(params)
        path = File.join(request_path, 'search')

        if params.size == 1
          params = case params.keys.first
                   when :criteria, :email, :phone, :word
                     # these attributes are directly handled by Zoho
                     # see https://www.zoho.com/crm/help/developer/api/search-records.html
                     params
                   else
                     key = attr_to_zoho_key(params.keys.first)

                     {
                       criteria: "#{key}:equals:#{params.values.first}"
                     }
                   end
        end

        body = get(path, params)
        response = build_response(body)

        data = response.nil? ? [] : response.data

        data.map { |json| new(json) }
      end

      def find_by(params)
        records = where(params)
        records.first
      end

      def create(params)
        new(params).save
      end

      def update(id, params)
        new(id: id).update(params)
      end

      def delete_record(id)
        new(id: id).delete_record
      end

      def blueprint_transition(id, next_field_value, data = {})
        new(id: id).blueprint_transition(next_field_value, data)
      end

      def blueprint_transitions(id)
        new(id: id).blueprint_transitions
      end

      def all_related(parent_module:, parent_id:)
        body = get(File.join(parent_module.constantize.request_path, parent_id, request_path))
        response = build_response(body)

        data = response.nil? ? [] : response.data

        data.map { |json| new(json) }
      end

      def update_related(parent_module:, parent_id:, related_id:, data:)
        path = File.join(
          parent_module.constantize.request_path, parent_id, request_path, related_id
        )
        body = put(path, data: data)
        build_response(body)
      end

      def add_related(parent_module:, parent_id:, related_id:)
        update_related(
          parent_module: parent_module, parent_id: parent_id, related_id: related_id, data: [{}]
        )
      end

      def remove_related(parent_module:, parent_id:, related_id:)
        body = delete(
          File.join(parent_module.constantize.request_path, parent_id, request_path, related_id)
        )
        build_response(body)
      end

      def update_all(records)
        zoho_params = records.map { |record| record.transform_keys { |key| attr_to_zoho_key(key) } }

        body = put(File.join(request_path), data: zoho_params)

        build_response(body)
      end

      def delete_all(array_of_ids)
        body = delete(File.join(request_path), ids: array_of_ids.join(','))

        build_response(body)
      end

      def all(params = {})
        params[:page] ||= DEFAULT_PAGE
        params[:per_page] ||= DEFAULT_RECORDS_PER_PAGE
        params[:per_page] = MIN_RECORDS if params[:per_page] < MIN_RECORDS

        body = get(request_path, params)
        response = build_response(body)

        data = response.nil? ? [] : response.data

        data.map { |json| new(json) }
      end

      def exists?(id)
        !find(id).nil?
      rescue RecordNotFound
        false
      end

      alias exist? exists?

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/PerceivedComplexity
      def build_response(body)
        response = Response.new(body)

        raise InvalidTokenError, response.msg if response.invalid_token?
        raise InternalError, response.msg if response.internal_error?
        raise InvalidRequestError, response.msg if response.invalid_request?
        raise InvalidQueryError, response.msg if response.invalid_query?
        raise RecordInvalid, response.msg if response.invalid_data?
        raise InvalidModule, response.msg if response.invalid_module?
        raise NoPermission, response.msg if response.no_permission?
        raise AuthenticationFailure, response.msg if response.authentication_failure?
        raise MandatoryNotFound, response.msg if response.mandatory_not_found?
        raise RecordInBlueprint, response.msg if response.record_in_blueprint?
        raise TooManyRequestsError, response.msg if response.too_many_requests?
        raise RecordNotInProcessError, response.msg if response.record_not_in_process?
        raise RecordNotFound, response.msg if response.record_not_found?
        raise OauthScopeMismatch, response.msg if response.oauth_scope_mismatch?

        response
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/PerceivedComplexity
    end

    def initialize(params = {})
      attributes.each do |attr|
        zoho_key = attr_to_zoho_key(attr)
        value = params[zoho_key].nil? ? params[attr] : params[zoho_key]

        send("#{attr}=", value)
      end
    end

    def save
      body = if new_record? # create new record
               post(self.class.request_path, data: [to_params])
             else # update existing record
               put(File.join(self.class.request_path, id), data: [to_params])
             end

      response = build_response(body)

      response.data.first.dig(:details, :id)
    end

    def update(params)
      zoho_params = params.transform_keys { |key| attr_to_zoho_key(key) }
      body = put(File.join(self.class.request_path, id), data: [zoho_params])

      build_response(body)
    end

    def delete_record
      body = delete(File.join(self.class.request_path, id))

      build_response(body)
    end

    def transition_id(next_field_value)
      response = blueprint_transitions
      transition = response.data[:blueprint][:transitions].find do |t|
        t[:next_field_value] == next_field_value
      end
      raise BlueprintTransitionNotFound, next_field_value unless transition

      transition[:id]
    end

    def blueprint_transition(next_field_value, data = {})
      body = put(File.join(self.class.request_path, id, 'actions/blueprint'),
                 blueprint: [{ transition_id: transition_id(next_field_value), data: data }])

      build_response(body)
    end

    def blueprint_transitions
      body = get(File.join(self.class.request_path, id, 'actions/blueprint'))
      build_response(body)
    end

    def new_record?
      !id
    end

    def to_params
      params = {}

      attributes.each do |attr|
        key = attr_to_zoho_key(attr)

        params[key] = send(attr)
      end

      params
    end

    def build_response(body)
      self.class.build_response(body)
    end
  end
end
