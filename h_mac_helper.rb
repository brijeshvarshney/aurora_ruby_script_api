

# Helper class to build the formatted canonical request string needed to then
# create the signature.
class HMacHelper
  require 'openssl'
  require 'base64'
  require 'uri'
  require 'net/http'
  require 'json'

  def self.format_request_string(http_verb, uri, api_key, timestamp, params = nil)
    
    clean_http_verb = http_verb.strip.upcase
    clean_uri = uri.downcase.strip.chomp("/").gsub /https?:\/\//, "" # Remove protocol
    clean_uri = clean_uri.gsub /\?.*/, "" # Remove query params. See byte order below
    clean_api_key = api_key
    clean_timestamp = timestamp

    # Put the base query together, without the optional GET/POST params for now.
    formatted_query = "#{clean_http_verb}\n#{clean_uri}\nAuroraKey=#{clean_api_key}\nTimestamp=#{clean_timestamp}\n"

    if params && params.size > 0
      sorted_params_hash = params.sort.to_h #Ruby sorts in ASCII byte order. Hurray
      sorted_params = ""
      sorted_params_hash.map {|k, v| sorted_params << "#{URI.escape(k)}=#{URI.escape(v)}&" }
      sorted_params.chomp! "&" #Remove trailing ampersand

      formatted_query << "#{sorted_params}\n"
    end
      formatted_query
  end


  def self.compute_hmac_signature(request_string, api_secret)
    
    hmac = OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), api_secret, request_string)
   #Base 64 encode the HMac
    base64_signature = Base64.encode64(hmac)
    #Remove whitespace, new lines and trailing equal sign.
    base64_signature.strip().chomp("=")
  end


      
      def self.aurora_api(p, method)
      host = "api-sandbox.aurorasolar.com"
      aurora_api_key = "bcc68198-b5b5-42ad-a34e-f99ba462d102"
      aurora_api_secret = "e412286f-76d6-40f3-b4a5-1cb4992651e4"

            # Plain script to send a sampel request to the API
            http_verb = "#{method}"
            api_uri ="/v1/#{p}"

            timestamp = URI.escape(Time.now.utc.to_s)
            # Given INDEX call, we do not have any get/post params, but for other requests we might.
            get_post_params = nil 

            # Sample API key/secret. These will differ for your tenant. 
            # Keep your key/secret in a SAFE place!!!
            # Create the signature necessary for the API call using the helper class

            formated_request_string = HMacHelper.format_request_string(http_verb, api_uri, aurora_api_key, timestamp)
            signature = HMacHelper.compute_hmac_signature(formated_request_string, aurora_api_secret)

            # Make the actual API request:
            end_point = "https://#{host}#{api_uri}?AuroraKey=#{aurora_api_key}&Timestamp=#{timestamp}&Signature=#{signature}"
            uri = URI(end_point)
            json_string = Net::HTTP.get(uri) 
            p json_string

      end
end