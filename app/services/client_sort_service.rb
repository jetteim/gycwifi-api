# sort service for clients#index
class ClientSortService
  def initialize(params = {})
    @limit = params[:limit]
    @offset = params[:offset]
    @loyalty_days = params[:loyalty_days]
    @loyalty = params[:loyalty]
    @locations = params[:locations]
    @sort_order = params[:sort_order]
  end

  def call
    clients = clients_info.map { |info| info.merge client_models[info[:client_id]][0].social_info }
    { itemsOnPage: @limit,
      clients: clients,
      items_count: items_count }
  end

  def client_models
    @client_models ||= Client.includes(:social_accounts)
                             .where(id: clients_info.map { |c| c[:client_id] })
                             .group_by(&:id)
  end

  def clients_info
    @clients_info ||= clients_visits.map do |p|
      { client_id: p[0], phone_number: p[1], updated_at: p[2], visits: p[3], visits30: p[4] }
    end
  end

  def clients_visits
    @clients_visits ||= client_counter.order(order_by)
                                      .limit(@limit)
                                      .offset(@offset)
                                      .pluck("client_id, phone_number, max(client_counters.updated_at) as updated_at,
                                                              count(client_counters.id) as visits,
                                                              sum(case when client_counters.created_at
                                                                  between
                                                                  '#{1.month.ago.beginning_of_day}'
                                                                  and
                                                                  '#{1.day.since.beginning_of_day}'
                                                                  then 1 else 0 end) as visits30")
  end

  def client_counter
    @client_counter ||= ClientCounter.send(@loyalty)
                                     .where('client_counters.created_at >= ?', @loyalty_days)
                                     .group('client_id, phone_number')
                                     .where(location_id: @locations)
                                     .joins(:client)
  end

  def items_count
    @items_count ||= client_counter.pluck('count("client_counters"."client_id")').size
  end

  def order_by
    @order_by ||= @sort_order.to_a.map { |fields| fields.join(' ') }.join(', ')
  end
end
