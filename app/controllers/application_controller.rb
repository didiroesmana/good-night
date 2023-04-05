class ApplicationController < ActionController::Base
  rescue_from HandledError, with: :handle_defined_error

  private def handle_defined_error(error)
    @error = "#{error.class}: #{error}"

    render status: error.status, json: {
      errors: [
        {
          errorCode: error.code,
          title: error.title,
          detail: error.detail,
        },
      ],
    }
  end
end
