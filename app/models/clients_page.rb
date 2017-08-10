# == Schema Information
#
# Table name: clients_pages
#
#  id           :integer
#  user_id      :integer
#  clients_page :string
#

class ClientsPage < ApplicationRecord
  # Relations
  belongs_to :user
end
