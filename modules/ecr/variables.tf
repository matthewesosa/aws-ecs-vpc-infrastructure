variable "ecr_mutability" {
  description = "Indicates if the images in the ECR repository should be mutable (true) or immutable (false)"
  type        = bool
  default     = false
}