class Products::Upload::GetValidProductsFromFile
  def initialize(file, upload_file_id)
    @file = file
    @upload_file_id = upload_file_id
    @products = []
    @errors = []
  end

  def exec
    CSV.foreach(@file.path, col_sep: ';').with_index do |row, index|
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

  private

  def sanitize_name_with_code(name_with_code)
    begin
      match_data = name_with_code.match(/(.+?)\s+\#\((\d+)\)/) # Grab all characters until the first " #" and then grab all digits
      name = sanitize_input(match_data[1].strip)
      code = sanitize_input(match_data[2].strip)

      [name, code]
    rescue => e
      raise "Invalid format for name_with_code"
    end
  end

  def sanitize_input(input)
    ActionController::Base.helpers.strip_tags(input) # Remove HTML tags
    input.gsub(/[^0-9A-Za-z\s\-_.]/, '').strip # Remove unwanted characters
  end

  def sanitize_price(price)
    begin
      cleaned_price = price.gsub(/[^\d.]/, '')
      (cleaned_price.to_f * 100).to_i # Convert to cents
    rescue => e
      raise "Invalid price format"
    end
  end

  def sanitize_expiration(expiration)
    begin
      Date.strptime(expiration, '%m/%d/%Y').to_s
    rescue => e
      raise "Invalid expiration date format"
    end
  end
end