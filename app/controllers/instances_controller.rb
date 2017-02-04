class InstancesController < ApplicationController
  respond_to :json
  before_action :validate_params

  VOMS_PROXY_PATH = ENV['GUOCCI_VOMS_PROXY_PATH'] || '/tmp/x509up_u1000'
  CA_PATH = ENV['GUOCCI_CA_PATH'] || '/etc/grid-security/certificates'

  def index
    computes = client(params[:endpoint]).describe(Occi::Infrastructure::Compute.new.kind.type_identifier)
    computes = computes.collect { |cmpt| { id: cmpt.location, name: (cmpt.title || cmpt.hostname), state: cmpt.state, ip: all_addresses(cmpt) } }
    computes.compact!

    respond_with({ instances: computes }, status: 200, location: "/instances/#{params[:site_id]}/")
  end

  def show
    respond_with({ error: 'Not Implemented!' }, status: 501, location: '/test/')
  end

  def create
    compute = client(params[:endpoint]).get_resource(Occi::Infrastructure::Compute.new.kind.type_identifier)
    compute.mixins << resolve_mixin(client(params[:endpoint]), params[:size])      \
                   << resolve_mixin(client(params[:endpoint]), params[:appliance]) \
                   << context_mixin
    compute.title = compute.hostname = params[:name]
    compute.attributes['org.openstack.credentials.publickey.data'] = params[:sshkey].strip

    compute_id = client(params[:endpoint]).create compute

    respond_with({ id: compute_id }, location: "/instances/#{params[:site_id]}/new")
  end

  def destroy
    client(params[:endpoint]).delete params[:id]
    respond_with({ status: 'success' }, status: 200, location: "/instances/#{params[:site_id]}/delete")
  end

  class << self
    def voms_proxy_path
      VOMS_PROXY_PATH.strip
    end

    def ca_path
      CA_PATH.strip
    end
  end

  private

  include VomsProxyFile

  def validate_params
    respond_with({ error: 'Site ID not provided!' }, status: 400) if params[:site_id].blank?
  end

  def client(endpoint)
    @client ||= Occi::Api::Client::ClientHttp.new({
      :endpoint => endpoint,
      :auth => {
        :type               => "x509",
        :user_cert          => voms_proxy_path,
        :user_cert_password => nil,
        :ca_path            => self.class.ca_path,
        :voms               => true
      },
      :log => {
        :level  => Occi::Api::Log::DEBUG,
        :logger => Rails.logger,
        :out => Rails.logger,
      }
    })
  end

  def all_addresses(compute)
    lnks = compute.links
           .select { |lnk| lnk.attributes['occi.networkinterface'] }
           .collect { |lnk| lnk.attributes['occi.networkinterface.address'] }.compact
    lnks.empty? ? 'unknown' : lnks.join(', ')
  end

  def resolve_mixin(client, mixin)
    fail 'Required mixin not specified!' unless mixin
    return mixin if mixin.is_a? Occi::Core::Mixin
    return mixin if mixin.is_a?(String) && mixin.start_with?('http://')

    type, term = mixin.split('#')
    type = 'os_tpl' if type == 'os'
    type = 'resource_tpl' if type == 'resource'

    client.get_mixin(term, type) || fail("Specified mixin #{mixin.inspect} not declared!")
  end

  def context_mixin
    mxn_attrs = Occi::Core::Attributes.new
    mxn_attrs['org.openstack.credentials.publickey.name'] = {}
    mxn_attrs['org.openstack.credentials.publickey.data'] = {}

    Occi::Core::Mixin.new(
      'http://schemas.openstack.org/instance/credentials#',
      'public_key',
      'OS contextualization mixin',
      mxn_attrs
    )
  end
end
