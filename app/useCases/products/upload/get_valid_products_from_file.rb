class Products::Upload::GetValidProductsFromFile
  def initialize(local_file_path, upload_file_id)
    @file_path = local_file_path
    @upload_file_id = upload_file_id
    @products = []
    @errors = []
  end

  def exec
    CSV.foreach(@file_path, col_sep: ';').with_index do |row, index|
      next if index == 0

      begin

        name, code = sanitize_name_with_code(row[0])
        price = sanitize_price(row[1])
        expiration = sanitize_expiration(row[2])

        if name && code && price && expiration
          @products << { name: name, price: price, expiration: expiration, code: code, upload_file_id: @upload_file_id }
        end
      rescue => e
        @errors << { csv_error_line: index + 1, error: e.message }
      end
    end

    [@products, @errors]
  end

  def sanitize_name_with_code(name_with_code)
    begin
      match_data = name_with_code.match(/(.+?)\s+\#\((\d+)\)/) # Grab all characters until the first " #" and then grab all digits

      regex = /[^0-9A-Za-z\s\-_.]/ # allow only alphanumeric, spaces, hyphens, underscores, and dots
      sanitized_name = ActionController::Base.helpers.strip_tags(match_data[1].strip).gsub(regex, '') 
      sanitized_code = ActionController::Base.helpers.strip_tags(match_data[2].strip).gsub(regex, '')

      [sanitized_name, sanitized_code]
    rescue => e
      raise "Invalid format for name_with_code"
    end
  end

  def sanitize_price(price)
    begin
      cleaned_price = price.gsub(/[^\d.]/, '')
      raise "Invalid price format" if cleaned_price.empty?


      (BigDecimal(cleaned_price) * 100).to_i # Convert to cents
    rescue => e
      raise "Invalid price format"
    end
  end

  def sanitize_expiration(expiration)
    begin
      Date.strptime(expiration, '%m/%d/%Y').strftime('%m/%d/%Y').to_s
    rescue => e
      raise "Invalid expiration date format"
    end
  end
end