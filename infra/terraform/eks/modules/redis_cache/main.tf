resource "aws_elasticache_cluster" "redis" {
  cluster_id          = var.name
  engine              = "redis"
  node_type           = "cache.t3.small"
  num_cache_nodes     = 1
  port                 = 6379
}
