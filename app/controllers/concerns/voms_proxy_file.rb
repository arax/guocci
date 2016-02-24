module VomsProxyFile
  def voms_proxy_path
    Rails.logger.info "Selecting proxy: #{remote_proxy || InstancesController.voms_proxy_path}"
    remote_proxy || InstancesController.voms_proxy_path
  end

  def remote_proxy
    return nil if remote_user_candid.blank?
    path = "/tmp/x509_#{remote_user_candid}"
    return nil unless File.readable?(path)
    path
  end

  def remote_user_candid
    Rails.logger.info "Remote user: #{ENV['REMOTE_USER'].inspect}"
    Rails.logger.debug "Headers: #{request.headers.inspect}"
    ENV['REMOTE_USER'] || request.headers['HTTP_PROXY_USER']
  end
end
