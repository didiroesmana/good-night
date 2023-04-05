module SleepRecordError
  class NotFound < HandledError
    default(
      title: "Sleep Record not found",
      detail: "Sleep Record not found",
      code: "1000",
      status: :not_found,
    )
  end
end
