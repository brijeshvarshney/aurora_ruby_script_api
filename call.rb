load 'h_mac_helper.rb'
load 'post.rb'

class AuroraApi 

	def self.tenant
		HMacHelper.aurora_api("tenants","GET")
	end

	def self.retrieve_tenant
		puts"tenant id"
		id= gets.chomp
		new_uri= "tenants/#{id}"
		HMacHelper.aurora_api(new_uri,"GET")
	end


	def self.users
		HMacHelper.aurora_api("users","GET")
	end

	def self.get_user
		puts"user id"
		id= gets.chomp
		new_uri= "users/#{id}"
		HMacHelper.aurora_api(new_uri,"GET")
	end

	def self.invite_user
		PostData.post_api("users/invite","")	
	end 

	def self.create_user
		puts "enter external id"
		id = gets.chomp
		PostData.post_api("users","#{id}")	
	end

	def self.create_design
		puts "enter external id"
		id = gets.chomp
		PostData.post_api("designs",id)	
	end 

	def self.design_project
		puts"id"
		id= gets.chomp
		new_uri= "projects/#{id}/designs"
		HMacHelper.aurora_api(new_uri,"GET")
	end

	def self.design_summary
		puts" design id "
		id= gets.chomp
		new_uri= "designs/#{id}/summary"
		HMacHelper.aurora_api(new_uri,"GET")
	end


	def self.consumption_profiles
		puts"consumption profile id"
		id= gets.chomp
		new_uri= "consumption_profiles/#{id}"
		HMacHelper.aurora_api(new_uri,"GET")
	end


	def self.create_consumption_pro
		puts "enter project id"
		id = gets.chomp
		PostData.post_api("consumption_profiles",id)	
	end 
	
	
	def self.create_project
		PostData.post_api("projects","")	
	end 

	def self.list_project
		HMacHelper.aurora_api("projects","GET")
	end

	def self.get_project
		puts"project id"
		id= gets.chomp
		new_uri= "projects/#{id}"
		HMacHelper.aurora_api(new_uri,"GET")
	end

	def self.components
		HMacHelper.aurora_api("components","GET")
	end
	
	def self.list_components
		puts"components type"
		
		puts"components filter"
		filter= gets.chomp
		new_uri= "projects/#{filter}"
		HMacHelper.aurora_api(new_uri,"GET")
	end
	
end

#AuroraApi.tenant
#AuroraApi.retrieve_tenant

#AuroraApi.invite_user
#AuroraApi.create_user
#AuroraApi.users
#AuroraApi.get_user

#AuroraApi.create_project
#AuroraApi.list_project
#AuroraApi.get_project

#AuroraApi.design_summary
#AuroraApi.create_design
#AuroraApi.design_project

#AuroraApi.create_consumption_pro
#AuroraApi.consumption_profiles

#AuroraApi.components
#AuroraApi.list_components