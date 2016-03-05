module VomsProxyFile
  def voms_proxy_path
    Rails.logger.info "Selecting proxy: #{remote_proxy || InstancesController.voms_proxy_path}"
    remote_proxy || InstancesController.voms_proxy_path
  end

  def remote_proxy
    remote_user_candid.blank? ? nil : "/tmp/x509_#{remote_user_candid}"
  end

  def remote_user_candid
    Rails.logger.info "Remote user: #{ENV['REMOTE_USER'].inspect}"
    Rails.logger.info "Proxy user: #{request.headers['HTTP_PROXY_USER'].inspect}"
    ENV['REMOTE_USER'] || request.headers['HTTP_PROXY_USER']
  end
end
