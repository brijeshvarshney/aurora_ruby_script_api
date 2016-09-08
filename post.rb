
module PostData
# Helper class to flatten recursively nested Hash objects
  class HashHelper
    def self.flatten_hash(hash)
      hash.each_with_object({}) do |(key, value), global_hash|
        if value.is_a? Hash
          flatten_hash(value).map do |h_k, h_v|
            # Concatenate parent/child key together to ensure uniqueness
            global_hash["#{key}.#{h_k}"] = h_v
          end
        else
          global_hash[key] = value
        end
      end
    end
  end

# Helper class to build the formatted canonical request string needed to then
# create the signature.
class HMacHelper
  def self.format_request_string(http_verb, uri, api_key, timestamp, params = nil)
    clean_http_verb = self.format_http_verb(http_verb)
    clean_uri = self.extract_api_endpoint_from_uri(uri)
    clean_api_key = self.format_api_key(api_key)
    clean_timestamp = self.format_timestamp(timestamp)

    # Put the base query together, without the optional GET/POST params for now.
    formatted_query = "#{clean_http_verb}\n#{clean_uri}\nAuroraKey=#{clean_api_key}\nTimestamp=#{clean_timestamp}\n"

    self.format_custom_params(formatted_query, params)
  end

  def self.format_http_verb(http_verb)
    http_verb.strip.upcase
  end


  def self.extract_api_endpoint_from_uri(uri)
    clean_uri = uri.downcase.strip.chomp("/").gsub /https?:\/\//, "" # Remove protocol
    clean_uri.gsub /\?.*/, ""
  end


  def self.format_api_key(api_key)
    unless api_key.include? "%20"
      return URI.escape(api_key)
    end
    api_key
  end


  def self.format_timestamp(timestamp)
    unless timestamp.include? "%20"
      return URI.escape(timestamp)
    end
    timestamp
  end


  def self.format_custom_params(formatted_query, params)

    if params && params.size > 0
      sorted_params = ""

      # We hence we recursively parse the tree and flatten the hash to format the query.
      flat_hash = HashHelper.flatten_hash params
      sorted_flat_hash = flat_hash.sort.to_h #Ruby sorts in ASCII byte order. Hurray
      sorted_flat_hash.each do |k, v|
        value = v.to_s
          if v.is_a?(Array)
            value = "[#{v.join(",")}]"
          end
      sorted_params << "#{URI.escape(k.to_s)}=#{URI.escape(value)}&"
    end

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
end

    def self.post_api(ap_uri, ext_id )

      host = "api-sandbox.aurorasolar.com"
      # Example API key/secret. Keep YOUR key/secret in a safe place!!!
      aurora_api_key = "bcc68198-b5b5-42ad-a34e-f99ba462d102"
      aurora_api_secret = "e412286f-76d6-40f3-b4a5-1cb4992651e4"
      timestamp = URI.escape(Time.now.utc.to_s)

      http_verb = "POST"
      protocol = "443"
      api_uri = "/v1/#{ap_uri}"
      
          if ap_uri == "users" or ap_uri == "users/invite" 
            post_params = {
              "user" => {
                "first_name" => "abrijesh",
                "last_name" => "varshney",
                "email" => "elon-#{rand(1000)}@solarcity.com",
                "phone" => "650-1234-9000",
                "title" => "Chairman of the board",
                "external_provider_id" => "#{ext_id}"
              }
            }
      
          elsif ap_uri == "designs"
            post_params = {
              "design" => {
                "external_provider_id" => "#{ext_id}",
                "project_id" => "varshney",
                "name" => "new design",
            }
          }
        
          elsif ap_uri == "projects"
            post_params = {
                "project" => {
                  "external_provider_id" => "iuyt-234u-2345j",
                  "name" => "solar",
                  "customer_first_name" => "aurora",
                  "customer_last_name" => "solar",
                  "customer_address" => "india",
                  "latitude" => "",
                  "longitude" => "",
                  "pre_solar_utility_rate_version_id" => "249b91ca-cb5d-4ad8-b03d-6ef654ac3bd8"
            }
          }

        elsif ap_uri== "consumption_profiles"
          post_params = {
              "project" => {
                "project_id" => "#{ext_id}",
                "monthly_energy" => "[1,2,3,4,5,6,7,8,9,88,44,33]"
              }
            }      
        end  

      # Create the signature necessary for the API call using the helper class
      formated_request_string = HMacHelper.format_request_string(http_verb, api_uri, aurora_api_key, timestamp, post_params)
      puts formated_request_string
      signature = HMacHelper.compute_hmac_signature(formated_request_string, aurora_api_secret)
      
      hmac_params = {
        "AuroraKey" => aurora_api_key,
        "Timestamp" => timestamp,
        "Signature" => signature,
      }

      # Make the actual API request:
      end_point = "https://#{host}#{api_uri}"
      payload = hmac_params.merge(post_params).to_json
      
      req = Net::HTTP::Post.new(api_uri, initheader = {'Content-Type' =>'application/json'})
      req.body = payload 
      response = Net::HTTP.start(host, protocol, use_ssl: true) {|http| http.request(req) }
      #p response
      puts "Response #{response.code} #{response.message}:\n#{response.body}"

    end
end