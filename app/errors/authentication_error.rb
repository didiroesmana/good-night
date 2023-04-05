module AuthenticationError
  class Unauthorized < HandledError
    default(
      title: "GENERAL ERROR",
      detail: "Unauthorized",
      code: "401",
      status: :unauthorized,
    )
  end
end
