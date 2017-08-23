require 'csv'
module Dashboard
  # Client Controller for indexing clients in dashboard
  class ClientsController < ApplicationController
    # include Skylight::Helpers
    before_action :current_client, only: %i[show update destroy]

    BOM = "\xEF\xBB\xBF".freeze
    PAGESIZE = 25
    def index
      clients = ClientSortService.new(limit: PAGESIZE,
                                      offset: offset,
                                      loyalty_days: loyalty_days,
                                      loyalty: loyalty,
                                      locations: locations,
                                      sort_order: sort_order)
      render json: {
        data:    clients.call,
        status: 'ok',
        message: 'Social accounts'
      }
    end

    # Экспорт в CSV для AmoCRM
    def export_to_amo
      filename = ('amocrm-export_' + DateTime.current.strftime('%d_%m_%y').to_s + '.csv')
      send_data(
        amocrm_csv_collection,
        type: 'text/csv; charset=utf-8; header=present',
        filename: filename,
        stream: false
      )
    end

    # Экспорт в CSV для Mailchimp
    def export_to_mailchimp
      filename = ('mailchimp_export_' + DateTime.current.strftime('%d_%m_%y').to_s + '.csv')
      send_data(
        mailchimp_csv_collection,
        type: 'text/csv; charset=utf-8; header=present',
        filename: filename,
        stream: false
      )
    end

    # def email_congratulations
    #   social_accounts = current_user.social_accounts
    #   CongratulationsMailer.via_email(params[:message], 'silencesource@gmail.com', 'hello?').deliver_later
    #   render json: { data: nil, status: 'ok', message: 'Mailing started' }
    # end

    def sms_congratulations
      # run sms library
      render json: { data: nil, status: 'ok', message: 'Sms sending started' }
    end

    def self.renew_client_device(phone_number)
      logger.warn "deprecated method call for client #{phone_number}".red.bold
      # client_id = REDIS.hget('client_data', :client_id)
      # logger.debug "checking if client #{client_id} has a new device but same old phone number #{phone_number}"
      # if client_id == 42
      #   logger.debug 'client 42 does not need to update a phone number - skipping this'
      #   return false
      # end
      # exist_user_by_phone_number = Client.where(phone_number: phone_number).where.not(id: client_id).first
      # unless exist_user_by_phone_number
      #   logger.debug "phone number #{phone_number} seems unique, so proceed with authorization"
      #   return false
      # end
      # # 3.2.7 если в базе уже есть такой телефонный номер
      # logger.info "found phone number #{phone_number} in the database!".yellow
      # logger.info "renew client id from #{client_id} to #{exist_user_by_phone_number.id}".yellow
      # # 3.2.7.1 удаляем из Clients клиента с нашим client_id
      # Client.find(client_id).delete
      # # 3.2.7.2 получаем по номеру телефона client_id существующего клиента и кладём его в redis
      # REDIS.hset('client_data', :client_id, exist_user_by_phone_number.id)
      # # 3.2.7.3 обновляем значение client_id в client_device
      # ClientDevice.find(REDIS.hget('router_data', :client_device_id)).update(client_id: exist_user_by_phone_number.id)
    end

    def self.client_number_42
      # этот метод устарел, у нас теперь есть другие способы авторизоваться
      # оставим его для истории
      logger.warn 'deprecated method call'.red.bold
      # client_id = REDIS.hget('router_data', :client_id)
      # return if client_id == 42
      # logger.warn "we need to identify client #{client_id} but cannot send sms - will use client id=42 instead"
      # # 3.3.1 удаляем из Clients клиента с нашим client_id
      # Client.find(client_id).delete
      # # 3.3.2 используем вместо созданного на первом шаге клиента с client_id = 42
      # REDIS.hset('router_data', :client_id, 42)
      # # 3.3.3 обновляем значение client_id в client_device
      # ClientDevice.find(REDIS.hget('router_data', :client_device_id)).update(client_id: 42)
    end

    def amocrm_csv_collection
      result = ActiveRecord::Base.connection.execute("select * from amocrmexport(#{@current_user.id})")
      BOM + result[0]['amocrmexport']
    end

    def mailchimp_csv_collection
      result = ActiveRecord::Base.connection.execute("select * from mailchimpexport(#{@current_user.id})")
      BOM + result[0]['mailchimpexport']
    end

    private

    def loyalty
      @str_prms[:loyalty] || 'all'
    end

    def loyalty_days
      loyalty == 'passed' ?  @str_prms[:loyalty_days].to_i.days.ago : ClientCounter.order(:created_at).first.created_at
    end

    def locations
      @str_prms[:location_id] ? [@str_prms[:location_id]] : policy_scope(Location).pluck(:id)
    end

    def sort_order
      sort_field = (@str_prms[:sort_field] || :updated_at).to_sym
      available_fields = %i[updated_at visits visits30] - [sort_field]
      sort_order = {}
      sort_order[sort_field] = @str_prms[sort_field]
      available_fields.each do |field|
        sort_order[field] = @str_prms[field]
      end
      sort_order
    end

    def offset
      page = @str_prms[:page].to_i < 1 ? 1 : @str_prms[:page].to_i
      (page - 1) * PAGESIZE
    end
  end
end
