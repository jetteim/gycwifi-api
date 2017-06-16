#
module Api
  module V1
    # Authorization of router connetion
    class HalController < ApplicationController
      # Captive network assistant (curtain)
      include Skylight::Helpers
      before_action :router_make
      skip_before_action :authenticate_user

      instrument_method
      def configure
        mtik = Hal::Mikrotik.new
        res = @router ? { json: { data: { config: mtik.configure(@router) }, status: 'ok' } } : { json: { status: 'error' }, status: :unauthorized }
        render res
      end

      def availability_check
        render json: { method: 'post' }
      end

      def send_command(_router)
        logger.warn 'warning: abstract method called, use hardware layer library instead!'.bold.red
      end

      def get_reply(_router)
        logger.warn 'warning: abstract method called, use hardware layer library instead!'.bold.red
      end

      instrument_method
      def authorize_client
        # generate username & password if not sent
        username  = hal_params[:username] || SecureRandom.uuid.to_s
        passwd    = hal_params[:password] || SecureRandom.hex(8)
        mac       = hal_params[:mac]
        client_ip = hal_params[:client_ip]

        if (timeout = hal_params[:timeout])
          AuthLog.create(
            username: username,
            password: passwd,
            timeout: timeout
          )
        end

        mtik = Hal::Mikrotik.new
        mtik.authorize_client(mac, client_ip, username, passwd)
        # и теперь авторизуем клиента
        if @router
          t = Thread.new {mtik.send_command(@router, mtik.command)}
          t.join(3)
        end
        head :ok
      end

      def close_cna
        puts 'Close CNA'
      end

      def change_guest_ssid
        mtik = Hal::Mikrotik.new
        mtik.change_guest_ssid(hal_params[:guest_ssid] || 'default')
        Thread.new { mtik.send_command(@router, mtik.command) }
        head :ok
      end

      def change_staff_ssid
        mtik = Hal::Mikrotik.new
        mtik.change_staff_ssid(hal_params[:staff_ssid] || 'default')
        Thread.new { mtik.send_command(@router) }
        head :ok
      end

      def change_staff_pass
        mtik = Hal::Mikrotik.new
        mtik.change_staff_pass(hal_params[:staff_pass])
        Thread.new { mtik.send_command(@router) }
        head :ok
      end

      def hotspot_wan_limit
        mtik = Hal::Mikrotik.new
        mtik.hotspot_wan_limit(hal_params[:hotspotconnectionlimit])
        Thread.new { mtik.send_command(@router) }
        head :ok
      end

      def hotspot_wlan_limit
        mtik = Hal::Mikrotik.new
        mtik.hotspot_wlan_limit(hal_params[:hotspotbalancerlimit])
        Thread.new { mtik.send_command(@router) }
        head :ok
      end

      #  На всякий случай оставлю пока
      # def change_speed_limit
      #   logger.info 'change speed limit'
      #   new_queue = params[:new_queue]
      #   pcq_total_limit = params[:pcq_total_limit] || '0'
      #   pcq_upload_default = params[:pcq_upload_default] || '0'
      #   pcq_download_default = params[:pcq_download_default] || '0'
      #   @command = ['/queue/type/add', "=name=#{new_queue}", '=kind=pcq', "=pcq-total-limit=#{pcq_total_limit}",
      #              "=pcq-upload-default=#{pcq_upload_default}", "=pcq-download-default=#{pcq_download_default}", '/quit']
      ##
      #   send_command
      # end

      private

      instrument_method
      def router_make
        return @router = nil unless hal_params[:common_name] || hal_params[:ip_name] || hal_params[:id]
        return @router = RedisCache.cached_router(hal_params[:common_name].to_s) if hal_params[:common_name]
        return @router = Router.find_by(hal_params[:ip_name].to_s).as_json if hal_params[:ip_name]
        return @router = Router.find_by(hal_params[:id].to_s).as_json if hal_params[:id]
      end

      def hal_params
        params.permit(:timeout, :mac, :common_name, :client_ip, :username, :password, :guest_ssid, :staff_pass, :staff_ssid, :wlan_id,
                      :pcq_total_limit, :pcq_upload_default, :pcq_download_default, :new_queue, :hotspotconnectionlimit,
                      :hotspotbalancerlimit)
      end
    end
  end
end
