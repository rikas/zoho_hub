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

    # Valid attributes for search
    SEARCH_ATTRS = [:criteria, :email, :phone, :word, :converted, :approved, :page, :per_page]

    class << self
      def request_path(name = nil)
        @request_path = name if name
        @request_path ||= StringUtils.pluralize(StringUtils.demodulize(to_s))
        @request_path
      end

      # block will be passed the farady request, to use for further configuration
      #   example: Account.where('...zoho_id...'){|req| req}
      def find(id)
        # @example
        body = get(File.join(request_path, id.to_s), &block)
        response = build_response(body)

        if response.empty?
          raise RecordNotFound, "Couldn't find #{request_path.singularize} with 'id'=#{id}"
        end

        new(response.data.first)
      end

      # block will be passed the farady request, to use for further configuration
      #   example: Account.where({account_name_: 'Whiting'}){|req| req.params['limit'] = 25}
      #   note, ending a criteria name with an underscore use start_with instead of equals
      def where(params, &block)
        path = File.join(request_path, 'search')
        # fix what happens if params[:criteria] is already set
        whereParams = params.entries.reduce({criteria: []}) do |hsh, (k, v)|
          if SEARCH_ATTRS.include? k
            hsh[k] = v
            return hsh
          end
          if k.ends_with? '_'
            hsh[:criteria].push("(#{attr_to_zoho_key(k.gsub(/_$/,''))}:starts_with:#{v})")
          else
            hsh[:criteria].push("(#{attr_to_zoho_key(k)}:equals:#{v})")
          end
        end
        whereParams[:criteria] = whereParams[:criteria].join('and')

        body = get(path, params, &block)
        response = build_response(body)

        data = response.nil? ? [] : response.data

        data.map { |json| new(json) }
      end

      # block will be passed the farady request, to use for further configuration
      #   example: Account.where('...zoho_id...'){|req| req.approved = false}
      def find_by(params, &block)
        records = where(params, &block)
        records.first
      end

      def create(params)
        new(params).save
      end

      def update(id, params)
        new(id: id).update(params)
      end

      def blueprint_transition(id, transition_id, data = {})
        new(id: id).blueprint_transition(transition_id, data)
      end

      def add_note(id:, title: '', content: '')
        path = File.join(request_path, id, 'Notes')
        post(path, data: [{ Note_Title: title, Note_Content: content }])
      end

      # block will be passed the farady request, to use for further configuration
      # ZohoHub::Account.all{|req| req.headers['If-Modified-Since'] = ::Account.maximum(:created_at).iso8601}
      def all(params = {}, &block)
        params[:page] ||= DEFAULT_PAGE
        params[:per_page] ||= DEFAULT_RECORDS_PER_PAGE
        params[:per_page] = MIN_RECORDS if params[:per_page] < MIN_RECORDS

        body = get(request_path, params, &block)
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

      def build_response(body)
        response = Response.new(body)

        raise InvalidTokenError, response.msg if response.invalid_token?
        raise InternalError, response.msg if response.internal_error?
        raise RecordInvalid, response.msg if response.invalid_data?
        raise InvalidModule, response.msg if response.invalid_module?
        raise NoPermission, response.msg if response.no_permission?
        raise MandatoryNotFound, response.msg if response.mandatory_not_found?
        raise RecordInBlueprint, response.msg if response.record_in_blueprint?

        response
      end
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
      zoho_params = Hash[params.map { |k, v| [attr_to_zoho_key(k), v] }]
      body = put(File.join(self.class.request_path, id), data: [zoho_params])
      build_response(body)
    end

    def blueprint_transition(transition_id, data = {})
      body = put(File.join(self.class.request_path, id, 'actions/blueprint'),
                 blueprint: [{ transition_id: transition_id, data: data }])
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
