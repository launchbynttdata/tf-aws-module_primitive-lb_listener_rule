logical_product_family  = "launch"
logical_product_service = "lbr"
class_env               = 0
instance_env            = 0
instance_resource       = 0

resource_names_map = {
  alb = {
    name       = "alb"
    max_length = 32
  }
  tg = {
    name       = "tg"
    max_length = 32
  }
}

priority = 100

condition = [
  {
    path_pattern = {
      values = ["/api/*"]
    }
  }
]

tags = {
  Environment = "test"
}
