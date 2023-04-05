module ValidationUtils
  class << self
    def validate_params(params:, required_fields:, optional_fields: [])
      errors = []
      if required_fields.class == Array
        expected = required_fields
      elsif required_fields.class == String
        expected = [required_fields]
      else
        raise "Invalid fields type, only string or array of string supported!"
      end

      params.permit(required_fields + optional_fields)

      expected.each do |field|
        errors << "Parameter #{field} #{I18n.translate("errors.messages.required")}" unless [true, false].include?(params[field]) || params[field].present?
      end

      raise ParameterError::Error.new(title: "GENERAL ERROR", detail: errors.first, code: "1000", status: :bad_request) unless errors.empty?
    end
  end
end
