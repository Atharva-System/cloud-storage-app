class LinkedAccountsController < ApplicationController
  def dropbox
    dbsession = DropboxSession.new(DROPBOX_APP_KEY, DROPBOX_APP_KEY_SECRET)
    session[:dropbox_session] = dbsession.serialize
    redirect_to dbsession.get_authorize_url(url_for(:action => 'dropbox_callback'))
  end

  def dropbox_callback
    dbsession = DropboxSession.deserialize(session[:dropbox_session])
    dbsession.get_access_token #we've been authorized, so now request an access_token
    linked_account = current_user.linked_accounts.where({:provider => "dropbox", :uid => params[:uid]}).first_or_initialize
    linked_account.access_token = dbsession.serialize
    if linked_account.save
      session.delete :dropbox_session
      flash[:success] = "You have successfully authorized with dropbox."
    end
  rescue DropboxAuthError => e
    flash.now[:error] = e.message
  rescue OAuth2::Error => e
    flash.now[:error] = e.message
  ensure
    redirect_to root_path
  end

  def box
    boxsession = RubyBox::Session.new({client_id: BOX_APP_KEY, client_secret: BOX_APP_KEY_SECRET})
    session[:box_session] = boxsession
    authorize_url = boxsession.authorize_url(url_for(:action => 'box_callback'))
    redirect_to authorize_url
  end

  def box_callback
    boxsession = RubyBox::Session.new({client_id: BOX_APP_KEY, client_secret: BOX_APP_KEY_SECRET})
    token = boxsession.get_access_token(params["code"])
    linked_account = current_user.linked_accounts.where({:provider => "box"}).first_or_initialize
    linked_account.access_token = token.token
    if linked_account.save
      session.delete :box_session
      flash[:success] = "You have successfully authorized with box."
    end
  rescue OAuth2::Error => e
    flash.now[:error] = e.message
  ensure
    redirect_to root_path
  end

  def upload_file
    file = params[:uploaded_file]
    if file.present?
      file_content = file.read()
      directory = File.dirname(File.join(Rails.public_path, "data"))
      FileUtils.mkdir_p(directory) unless File.directory?(directory)
      # write the file
      file_path = File.join(directory,file.original_filename)
      File.open(file_path, "wb") { |f| f.write(file_content)}
      account = current_user.linked_accounts.sort_by(&:space_available).last

      if file.size > account.space_available
        flash[:error] = "File size exceeds available space."
      else
        if account.provider == "dropbox"
          response = account.client.put_file(file.original_filename, file_content)
        else
          response = account.client.upload_file(file_path, '/') # lookups by id are more efficient
        end
        # ap response.inspect
        flash[:success] = "#{file.original_filename} - File Uploaded."
      end
    else
      flash[:error] = "Please select file to upload."
    end
  rescue => e
    flash[:error] = "Something went wrong while uploading file - #{file.original_filename if file}"
  ensure
    redirect_to root_path
  end

  def destroy
    linked_account = LinkedAccount.where(:id => params[:id]).first
    if linked_account
      provider = linked_account.provider
      linked_account.destroy
      flash[:success] = "You have successfully disconnected from #{provider}"
    else
      flash[:error] = "Something went wrong while disconnect from account."
    end
    redirect_to root_path
  end
end

