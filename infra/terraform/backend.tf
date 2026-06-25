# Remote state for DigitalOcean.
#
# The README asks for "S3 + DynamoDB lock, or equivalent for your provider."
# DigitalOcean Spaces is S3-compatible storage but has NO native locking,
# so it isn't a full equivalent on its own. Terraform Cloud's free tier
# gives you both remote state storage AND state locking out of the box,
# which is the closer match — use that here.
#
# Setup:
#   1. Create a free account at https://app.terraform.io
#   2. Create an organization, then a workspace named "phoenix-capstone"
#   3. Set workspace execution mode to "Local" (CLI-driven runs)
#   4. Run `terraform login` once on your machine
#   5. Replace REPLACE_WITH_YOUR_TFC_ORG below with your org name
#
# Alternative (documented trade-off if you prefer to stay all-in on DO):
# use a DigitalOcean Spaces bucket as an S3-compatible backend and note
# in your docs that it provides storage but not locking.

terraform {
  cloud {
    organization = "Capstone_project_tsacademy"
    workspaces {
      name = "phoenix-capstone"
    }
  }
}
