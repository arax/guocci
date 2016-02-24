class ProxyController < ApplicationController
  respond_to :json

  VOMS_PROXY_BIN = File.executable?('/usr/bin/voms-proxy-info') ? '/usr/bin/voms-proxy-info' : 'voms-proxy-info'

  def show
    respond_with(self.class.proxy_info(voms_proxy_path), status: 200)
  end

  class << self
    include ActionView::Helpers::DateHelper

    def voms_proxy_bin
      VOMS_PROXY_BIN.strip
    end

    def proxy_info(proxy_file)
      proxy_info_h = {}

      proxy_info_h[:identity] = `#{voms_proxy_bin} --file #{proxy_file} --identity`.strip
      fail 'Failed to get proxy identity!' unless $?.to_i == 0

      proxy_info_h[:vo] = `#{voms_proxy_bin} --file #{proxy_file} --vo`.strip
      fail 'Failed to get proxy VO!' unless $?.to_i == 0

      proxy_info_h[:timeleft] = `#{voms_proxy_bin} --file #{proxy_file} --timeleft`.strip
      fail 'Failed to get proxy expiration time!' unless $?.to_i == 0
      proxy_info_h[:timeleft] = time_ago_in_words(Time.now + proxy_info_h[:timeleft].to_i)

      proxy_info_h[:human] = proxy_info_h[:identity].split('/').last.split('=').last

      proxy_info_h
    end
  end

  private

  include VomsProxyFile
end
