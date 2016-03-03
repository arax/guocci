class ProxyController < ApplicationController
  respond_to :json

  VOMS_PROXY_BIN = File.executable?('/usr/bin/voms-proxy-info') ? '/usr/bin/voms-proxy-info' : 'voms-proxy-info'
  NUMERIC_PROXY_REGEXP = /^\d+$/

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
      proxy_info_h[:timeleft] = if proxy_info_h[:timeleft].to_i == 0
                                  "expired"
                                else
                                  time_ago_in_words(Time.now + proxy_info_h[:timeleft].to_i)
                                end

      proxy_info_h[:human] = name_candidate(proxy_info_h[:identity])

      proxy_info_h
    end

    def name_candidate(identity)
      parts = identity.split('/').reject { |part| part.blank? }
      parts.reverse.each do |candidate|
        name = candidate.split('=').last
        next if name.blank?
        return name unless name =~ NUMERIC_PROXY_REGEXP
      end

      "Unknown"
    end
  end

  private

  include VomsProxyFile
end
