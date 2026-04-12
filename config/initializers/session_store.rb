Rails.application.config.session_store :cookie_store,
  key: "_training_history_session",
  expire_after: 30.days
