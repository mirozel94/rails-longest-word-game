class SessionsController < ApplicationController
  def create
    session[:id] = @page.id
  end
end
