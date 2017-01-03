require 'openssl'
require 'base64'

module VomsProxyFile
  def voms_proxy_path
    local_path = session_proxy || InstancesController.voms_proxy_path
    Rails.logger.info "Selecting proxy: #{local_path}"
    local_path
  end

  def session_proxy
    session_proxy_file = "/tmp/x509_#{cookies[:session_id]}"
    File.readable?(session_proxy_file) ? session_proxy_file : nil
  end
end
