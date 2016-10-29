class LinkRequestsController < ApplicationController

	# GET request: /link_requests
	def index
		@link_requests = LinkRequest.all
	end

	# GET request: /link_requests/:id
	def show
		@link_requests = LinkRequest.find_by(user_id: params[:user_id])
	end
end