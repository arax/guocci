class SitesController < ApplicationController
  respond_to :json

  CACHE_DIR = '/tmp/guocci_cache'
  APPDB_PROXY_URL = 'https://appdb.egi.eu/api/proxy'
  APPDB_REQUEST_FORM = 'version=1.0&resource=broker&data=%3Cappdb%3Abroker%20xmlns%3Axs%3D%22http%3A%2F%2Fwww.w3.org%2F2001%2FXMLSchema%22%20xmlns%3Axsi%3D%22http%3A%2F%2Fwww.w3.org%2F2001%2FXMLSchema-instance%22%20xmlns%3Aappdb%3D%22http%3A%2F%2Fappdb.egi.eu%2Fapi%2F1.0%2Fappdb%22%3E%3Cappdb%3Arequest%20id%3D%22vaproviders%22%20method%3D%22GET%22%20resource%3D%22va_providers%22%3E%3Cappdb%3Aparam%20name%3D%22listmode%22%3Edetails%3C%2Fappdb%3Aparam%3E%3C%2Fappdb%3Arequest%3E%3C%2Fappdb%3Abroker%3E'

  def index
    vaproviders = vaproviders_from_appdb.select { |prov| prov['in_production'] == 'true' && !prov['endpoint_url'].blank? }
    respond_with({ error: 'Could not retrieve sites from AppDB!' }, status: 500) if vaproviders.blank?

    respond_with({
      sites: vaproviders.collect { |prov| { id: prov['id'], name: prov['name']} }
    })
  end

  def show
    respond_with({ error: 'Could not retrieve the site from AppDB!' }, status: 500) unless params[:id]

    vaprovider = vaproviders_from_appdb.select { |prov| prov['id'] == params[:id] }.first
    respond_with({ error: "Site with ID #{params[:id]} could not be found!" }, status: 404) unless vaprovider

    site_data = {}
    site_data[:id] = vaprovider['id']
    site_data[:name] = vaprovider['name']
    site_data[:country] = vaprovider['country']['isocode'] if vaprovider['country']
    site_data[:endpoint] = vaprovider['endpoint_url']
    site_data[:sizes] = vaprovider_sizes(vaprovider)
    site_data[:appliances] = vaprovider_appliances(vaprovider)

    respond_with({ site: site_data })
  end

  private

  include VomsProxyFile

  def vaproviders_from_appdb
    providers = cache_fetch('guocci-appdb-sites', 2.days) do
                  response = HTTParty.post(APPDB_PROXY_URL, { :body => APPDB_REQUEST_FORM })
                  response.success? ? response.parsed_response : nil
                end
    providers ? providers['broker']['reply']['appdb']['provider'] : []
  end

  def vaprovider_sizes(vaprovider)
    templates = [vaprovider['template']].flatten.compact
    templates.collect do |template|
      next if template['resource_name'].blank?
      {
        id: template['resource_name'],
        name: template['resource_name'].split('#').last,
        memory: template['main_memory_size'],
        vcpu: template['logical_cpus'],
        cpu: template['physical_cpus'],
      }
    end.compact
  end

  def vaprovider_appliances(vaprovider)
    images = [vaprovider['image']].flatten.compact
    images.collect do |image|
      next if image['va_provider_image_id'].blank? || image['mp_uri'].blank?

      appl = cache_fetch("guocci-appdb-appliance-#{Digest::SHA1.hexdigest(image['mp_uri'])}", 2.days) do
               response = HTTParty.get("#{image['mp_uri'].chomp('/')}/json")
               response.success? ? response.parsed_response : nil
             end
      next unless appl

      vo = vaprovider_appliances_vo(vaprovider, appl, image)
      next if vo.strip != ProxyController.proxy_info(voms_proxy_path)[:vo]

      {
        id: image['va_provider_image_id'],
        name: appl['title'].gsub(/\[.+\]/, ''),
        mpuri: image['mp_uri'],
        vo: vo,
      }
    end.compact
  end

  def vaprovider_appliances_vo(vaprovider, appl, image)
    appl['sites'].each do |site|
      site['services'].each do |service|
        next unless service['id'] == vaprovider['id']

        service['vos'].each do |vo|
          return vo['name'] if vo['occi']['id'] == image['va_provider_image_id']
        end
      end
    end

    'unknown'
  end

  private

  def cache_fetch(key, expiration = 1.hour)
    fail 'You have to provide a block!' unless block_given?
    FileUtils.mkdir_p CACHE_DIR
    filename = File.join(CACHE_DIR, key)

    if cache_valid?(filename, expiration)
      Rails.logger.debug "Cache hit on #{key.inspect}"
      File.open(filename, 'r') { |file| JSON.parse file.read }
    else
      Rails.logger.debug "Cache miss on #{key.inspect}"
      data = yield
      File.open(filename, 'w') { |file| file.write JSON.pretty_generate(data) }
      data
    end
  end

  def cache_valid?(filename, expiration)
    File.exists?(filename) && ((Time.now - expiration) < File.stat(filename).mtime)
  end
end
