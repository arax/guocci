class SitesController < ApplicationController
  respond_to :json

  APPDB_REQUEST_FORM = 'version=1.0&resource=broker&data=%3Cappdb%3Abroker%20xmlns%3Axs%3D%22http%3A%2F%2Fwww.w3.org%2F2001%2FXMLSchema%22%20xmlns%3Axsi%3D%22http%3A%2F%2Fwww.w3.org%2F2001%2FXMLSchema-instance%22%20xmlns%3Aappdb%3D%22http%3A%2F%2Fappdb.egi.eu%2Fapi%2F1.0%2Fappdb%22%3E%3Cappdb%3Arequest%20id%3D%22vaproviders%22%20method%3D%22GET%22%20resource%3D%22va_providers%22%3E%3Cappdb%3Aparam%20name%3D%22listmode%22%3Edetails%3C%2Fappdb%3Aparam%3E%3C%2Fappdb%3Arequest%3E%3C%2Fappdb%3Abroker%3E'

  def index
    vaproviders = HTTParty.post(
      'https://appdb.egi.eu/api/proxy', { :body => APPDB_REQUEST_FORM }
    )

    if vaproviders.code == 200
      respond_with(
        {
          sites: vaproviders.parsed_response['broker']['reply']['appdb']['provider'].collect { |prov| { id: prov['id'], name: prov['name']} }
        }
      )
    else
      respond_with({ error: 'Could not retrieve sites from AppDB!'}, status: 500)
    end
  end

  def show
    vaproviders = HTTParty.post(
      'https://appdb.egi.eu/api/proxy', { :body => APPDB_REQUEST_FORM }
    )

    if vaproviders.code == 200
      respond_with(
        vaproviders.parsed_response['broker']['reply']['appdb']['provider'].select { |prov| prov['id'] }
      )
    else
      respond_with({ error: 'Could not retrieve the site from AppDB!'}, status: 500)
    end
  end
end
