require 'openssl'
require 'base64'

module VomsProxyFile
  def voms_proxy_path
    local_path = remote_proxy || InstancesController.voms_proxy_path
    Rails.logger.info "Selecting proxy: #{local_path}"
    local_path
  end

  def remote_proxy
    ruc = remote_user_candid
    ruc.blank? ? nil : "/tmp/x509_#{ruc}"
  end

  def remote_user_candid
    Rails.logger.info "Remote user: #{ENV['REMOTE_USER'].inspect}"
    Rails.logger.info "Proxy user: #{request.headers['HTTP_PROXY_USER'].inspect}"
    user = ENV['REMOTE_USER'] || request.headers['HTTP_PROXY_USER']
    return if user.blank?

    data = OpenSSL::Digest::SHA256.new.digest(user)
    Base64.encode64(data).slice(0, 16)
  end
end
