class InstancesController < ApplicationController
  respond_to :json
  before_action :validate_params

  VOMS_PROXY_PATH = ENV['GUOCCI_VOMS_PROXY_PATH'] || '/tmp/x509up_u1000'
  CA_PATH = ENV['GUOCCI_CA_PATH'] || '/etc/grid-security/certificates'

  def index
    computes = client(params[:endpoint]).describe(Occi::Infrastructure::Compute.new.kind.type_identifier)
    computes = computes.collect { |cmpt| { id: cmpt.location, name: (cmpt.title || cmpt.hostname), state: cmpt.state, ip: first_address(cmpt) } }
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
    compute.attributes['org.openstack.credentials.publickey.name'] = 'Public SSH key'
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
      remote_proxy || VOMS_PROXY_PATH.strip
    end

    def ca_path
      CA_PATH.strip
    end

    def remote_proxy
      return nil if ENV['REMOTE_USER'].blank?
      path = "/tmp/x509_#{ENV['REMOTE_USER']}"
      return nil unless File.readable?(path)

      path
    end
  end

  private

  def validate_params
    respond_with({ error: 'Site ID not provided!' }, status: 400) if params[:site_id].blank?
  end

  def client(endpoint)
    @client ||= Occi::Api::Client::ClientHttp.new({
      :endpoint => endpoint,
      :auth => {
        :type               => "x509",
        :user_cert          => self.class.voms_proxy_path,
        :user_cert_password => nil,
        :ca_path            => self.class.ca_path,
        :voms               => true
      },
      :log => {
        :level  => Rails.env.production? ? Occi::Api::Log::ERROR : Occi::Api::Log::DEBUG,
        :logger => Rails.logger,
        :out => Rails.logger,
      }
    })
  end

  def first_address(compute)
    lnks = compute.links.select do |lnk|
      if lnk.kind.is_a? String
        lnk.kind == Occi::Infrastructure::Networkinterface.new.kind.type_identifier
      else
        lnk.kind.type_identifier == Occi::Infrastructure::Networkinterface.new.kind.type_identifier
      end
    end
    lnks.first ? lnks.first.address : 'unknown'
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
