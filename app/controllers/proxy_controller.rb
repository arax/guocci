class ProxyController < ApplicationController
  respond_to :json

  def show
    respond_with(self.class.proxy_info, status: 200)
  end

  class << self
    include ActionView::Helpers::DateHelper

    def proxy_info
      proxy_info = {}

      proxy_info[:identity] = `voms-proxy-info --identity`.strip
      fail 'Failed to get proxy identity!' unless $?.to_i == 0

      proxy_info[:vo] = `voms-proxy-info --vo`.strip
      fail 'Failed to get proxy VO!' unless $?.to_i == 0

      proxy_info[:timeleft] = `voms-proxy-info --timeleft`.strip
      fail 'Failed to get proxy expiration time!' unless $?.to_i == 0
      proxy_info[:timeleft] = time_ago_in_words(Time.now + proxy_info[:timeleft].to_i)

      proxy_info[:human] = proxy_info[:identity].split('/').last.split('=').last

      proxy_info
    end
  end
end
