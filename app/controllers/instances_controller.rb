class InstancesController < ApplicationController
  respond_to :json
  before_action :validate_params

  VOMS_PROXY_PATH = ENV['GUOCCI_VOMS_PROXY_PATH'] || '/tmp/x509up_u1000'
  CA_PATH = ENV['GUOCCI_CA_PATH'] || '/etc/grid-security/certificates'

  def index
    computes = client(params[:endpoint]).describe(Occi::Infrastructure::Compute.new.kind.type_identifier)
    computes = computes.collect { |cmpt| { id: cmpt.location, name: cmpt.title, state: cmpt.state, ip: first_address(cmpt) } }
    computes.compact!

    respond_with({ instances: computes }, status: 200, location: "/instances/#{params[:site_id]}/")
  end

  def show
    respond_with({ error: 'Not Implemented!' }, status: 501, location: '/test/')
  end

  def create
    compute = client(params[:endpoint]).get_resource(Occi::Infrastructure::Compute.new.kind.type_identifier)
    compute.title = compute.hostname = params[:name]
    compute.mixins << params[:size] << params[:appliance]
    compute_id = client(params[:endpoint]).create compute

    respond_with({ id: compute_id }, location: "/instances/#{params[:site_id]}/new")
  end

  def destroy
    client(params[:endpoint]).delete params[:id]
    respond_with({ status: 'success' }, status: 200, location: "/instances/#{params[:site_id]}/delete")
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
        :user_cert          => VOMS_PROXY_PATH,
        :user_cert_password => nil,
        :ca_path            => CA_PATH,
        :voms               => true
      },
      :log => {
        :level  => Occi::Api::Log::DEBUG,
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
end
