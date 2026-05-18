resource "aws_cognito_user_pool" "psydoc" {
  name = "${var.project}-${var.environment}"

  # login through email
  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  password_policy {
    minimum_length    = 12
    require_lowercase = true
    require_uppercase = true
    require_numbers   = true
    require_symbols   = true
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  mfa_configuration = "ON"
  #"ON" — MFA wymuszone dla wszystkich użytkowników
  #"OPTIONAL" — użytkownik może włączyć sam
  software_token_mfa_configuration {
    enabled = true
  }
}


resource "aws_cognito_user_pool_client" "frontend" {
  name         = "${var.project}-${var.environment}-frontend"
  user_pool_id = aws_cognito_user_pool.psydoc.id
  # brak stałego secretu — używamy PKCE  
  generate_secret = false # SPA nie może bezpiecznie przechować secretu

  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]
  # SRP = Secure Remote Password
  # hasło nigdy nie wędruje przez sieć w plaintext
  # matematyczna weryfikacja po obu stronach
  # po wygaśnięciu tokenu (60 min) — automatyczne odświeżenie
  # bez ponownego logowania psychologa

  # krótkie tokeny dla danych medycznych
  # token ważny 60 minut — potem wymaga odświeżenia
  # krótki czas = mniejsze ryzyko przy wycieku
  access_token_validity  = 60 # minut
  id_token_validity      = 60 # minut
  refresh_token_validity = 1  # dni

  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }
}