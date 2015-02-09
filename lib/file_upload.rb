module FileUpload
  def fileupload(file, account)
    result = {:key => "error", :message => "Something went wrong while uploading file."}
    file_content = file.read()
    directory = File.dirname(File.join(Rails.public_path, "data"))
    FileUtils.mkdir_p(directory) unless File.directory?(directory)
    # write the file
    file_path = File.join(directory,file.original_filename)

    File.open(file_path, "wb") { |f| f.write(file_content)}
    if file.size > account.space_available
      result[:key] = "error"
      result[:message] = t(:size_exceed)
    else
      if account.provider == "dropbox"
        response = account.client.put_file(file.original_filename, file_content)
      else
        response = account.client.upload_file(file_path, '/') # lookups by id are more efficient
      end
      result[:key] = "success"
      result[:message] = t(:file_uploaded, :filename => file.original_filename)
    end
    File.delete(file_path)

    return result
  end
end