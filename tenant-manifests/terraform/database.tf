resource random_password db_password {
  length  = 64
  special = false
}

resource random_pet db_user {
  length    = 2
  prefix    = "dbuser-"
  separator = "-"
}

resource kubernetes_secret db_secret {
  metadata {
    name      = "db-secret"
    namespace = var.namespace
  }
  data = {
    POSTGRES_PASSWORD = random_password.db_password.result
    POSTGRES_USER     = random_pet.db_user.id
    POSTGRES_DB       = "postgres"
    DSN               = "postgres://$(kubernetes_service.postgres.metadata.0.name):5432/postgres?sslmode=disable"
  }
}