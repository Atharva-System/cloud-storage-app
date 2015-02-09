module HomeHelper
  def show_account_button(accounts = [], account_name)
    linked_account = accounts.find{|account| account.provider == account_name}
    if linked_account
      button_tag(image_tag("#{account_name}.png", :size => "30x30") + " - " + linked_account.display_name + raw("<br />") + link_to("Disconnect", linked_account_path(linked_account.id), :method => "DELETE", :data => {:confirm => "Are you sure to disconnect from #{account_name}"}), :class => "btn btn-large")
    else
      link_to(account_name.titlecase, "/linked_accounts/#{account_name}", :class => "btn btn-primary btn-large", :onClick => "$.blockUI();")
    end
  end
end
