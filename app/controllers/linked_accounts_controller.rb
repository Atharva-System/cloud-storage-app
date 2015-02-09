class LinkedAccountsController < ApplicationController
  include FileUpload

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
      flash[:success] = t(:aurization_success, :name => "dropbox")
    else
      flash[:error] = linked_account.errors.full_messages.first
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
      flash[:success] = t(:aurization_success, :name => "box")
    end
  rescue OAuth2::Error => e
    flash.now[:error] = e.message
  ensure
    redirect_to root_path
  end

  def upload_file
    file = params[:uploaded_file]
    if file.present?
      account = current_user.linked_accounts.sort_by(&:space_available).last
      result = fileupload(file, account)
      flash[result[:key].to_sym] = result[:message]
    else
      flash[:error] = t(:file_select_error)
    end
  rescue => e
    flash[:error] = t(:something_wrong_with_file_upload, :filename => (file ? file.original_filename : nil))
  ensure
    redirect_to root_path
  end

  def destroy
    linked_account = LinkedAccount.find(params[:id])
    linked_account.destroy
    flash[:success] = t(:account_disconnected, :provider => linked_account.provider)
  rescue ActiveRecord::RecordNotFound
    flash[:error] = t(:something_wrong_with_account_destroy)
  ensure
    redirect_to root_path
  end
end
