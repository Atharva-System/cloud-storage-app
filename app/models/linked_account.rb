class LinkedAccount < ActiveRecord::Base
  belongs_to :user

  def client
    if provider == "dropbox"
      dbsession = DropboxSession.deserialize(self.access_token)
      return DropboxClient.new(dbsession, DROPBOX_APP_MODE)
    else
      session = RubyBox::Session.new({client_id: BOX_APP_KEY, client_secret: BOX_APP_KEY_SECRET, access_token: access_token})
      return RubyBox::Client.new(session)
    end
  end

  def account_info
    if provider == "dropbox"
      return client.account_info()
    else
      return client.me().as_json
    end
  end

  def display_name
    if provider == "dropbox"
      return account_info["display_name"]
    else
      return account_info["name"]
    end
  end

  def space_available
    if provider == "dropbox"
      quota_info = account_info["quota_info"]
      return (quota_info["quota"] - quota_info["normal"] - quota_info["shared"])
    else
      return client.me().as_json["space_amount"]
    end
  end

  def list_of_files
    if provider == "dropbox"
      root_metadata = client.metadata('/')
      return root_metadata["contents"] if root_metadata.has_key?("contents")
      return []
    else
      return client.root_folder.items.as_json
    end
  end
end
