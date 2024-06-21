resource random_password db_password {
  length  = 90
  special = false
}

resource random_pet db_user {
  length    = 2
  prefix    = "dbuser"
  separator = "-"
}

resource "random_id" "suffix" {
  byte_length = 4
}

locals {
  db_user = "${random_pet.db_user.id}-${random_id.suffix.hex}"
}

resource kubernetes_secret db_secret {
  metadata {
    name      = "db-secret"
    namespace = var.namespace
  }
  data = {
    POSTGRES_PASSWORD = random_password.db_password.result
    POSTGRES_USER     = local.db_user
    POSTGRES_DB       = "postgres"
    DSN               = "postgres://${local.db_user}:${random_password.db_password.result}@db.${var.namespace}.svc.cluster.local:5432/postgres?sslmode=disable"
  }
}