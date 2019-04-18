require 'json-schema-generator'

module Swaggerize
  class Perform
    attr_accessor :request, :response, :request_hash, :swagger_hash, :file_path, :api_version

    FILE_PATH = "#{Rails.root}/swagger/swagger.json"
    EXCLUSE_PARAMS = %i(controller action format api_version)
    SWAGGER_EMPTY_HASH = {
      'swagger' => '2.0',
      'info' => {
        'title' => 'HCM API',
        'version' => 'v1'
      },
      'basePath' => '/api',
      'consumes' => [
        'application/json'
      ],
      'produces' => [
        'application/json'
      ],
      'paths' => {
      }
    }.freeze
    NEW_METHOD_HASH = {
      'summary' => nil,
      'parameters' => nil,
      'responses' => nil
    }

    def initialize(request, response)
      @request = request
      @response = response
      @swagger_hash = File.exist?(file_path) ? JSON.parse(File.read file_path) : SWAGGER_EMPTY_HASH
    end

    def call
      return if Rails.env == 'production' || ENV['SWAGGERIZE'].blank?
      swagger_hash['paths'].deep_merge!(request_hash) { |_key, this_val, other_val| this_val.presence || other_val }
      save_swagger
    end

    private

    def file_path
      api_version.present? ? FILE_PATH.sub('.json', "_#{api_version}.json") : FILE_PATH
    end

    def api_version
      request.path_parameters[:api_version] || 'v1'
    end

    def request_hash
      {
        swagger_path_name => {
          request.request_method.downcase => {
            'summary' => title,
            'parameters' => success_response? ? parameters : {},
            'responses' => responses
          }
        }
      }
    end

    def title
      "#{request.request_method} #{swagger_path_name}"
    end

    def success_response?
      (200..299).include? response.status
    end

    def swagger_path_name
      path_name = request.path.sub '.json', ''
      path_name.sub! '/api', ''
      path_name.sub! "/#{api_version}", ''
      request.path_parameters.each_with_index do |(key, val), _index|
        path_name.sub! val, "{#{key}}"
      end
      path_name
    end

    def parameters
      [] + path_parameters + query_parameters
    end

    def path_parameters
      request.path_parameters.each_with_object([]) do |(key, _val), array|
        next if EXCLUSE_PARAMS.include? key
        array << {
          'name' => key.to_s,
          'in' => 'path',
          'type' => 'string',
          'required' => true
        }
      end
    end

    def query_parameters
      request.query_parameters.each_with_object([]) do |(key, _val), array|
        next if EXCLUSE_PARAMS.include? key
        array << {
          'name' => key,
          'in' => 'query',
          'type' => 'string',
          'required' => false
        }
      end
    end

    def responses
      {
        response.status.to_s => {
          'description' => response_massage,
          'examples' => response_body,
          'schema' => schema
        }
      }
    end

    def schema
      json_schema = JSON::SchemaGenerator.generate(title, response_body.to_json, {:schema_version => 'draft3'})
      hash_schema = JSON.parse(json_schema)
      hash_schema.except!('$schema')
      hash_schema['description'] = title
      hash_schema
    end

    def response_massage
      return 'Successful' if success_response?
      response_body['message'].presence
    end

    def response_body
      JSON.parse(response.body)
    end

    def request_parameters
      request.request_parameters
    end

    def save_swagger
      dirname = File.dirname(file_path)
      FileUtils.mkdir_p(dirname) unless File.directory?(dirname)

      File.open(file_path,'w') do |f|
        f.write(JSON.pretty_generate(swagger_hash))
      end
    end
  end
end