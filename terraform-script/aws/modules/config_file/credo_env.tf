
resource "aws_s3_object" "credo_env" {
  bucket  = var.env_file_bucket_id
  key     = "${var.environment}-CREDO.env"
  content = <<-EOT
# Specify connect timeout
CONNECT_TIMEOUT=10
# Specify max connections
MAX_CONNECTIONS=1000
# Specify idle timeout
IDLE_TIMEOUT=30000
#Specify max number 2147483647
SESSION_ACQUIRE_TIMEOUT=2147483647
SESSION_LIMIT=2147483647
INMEMORY_LRU_CACHE_LIMIT=2147483647
# Specify BCovrin Register url
BCOVRIN_REGISTER_URL=http://test.bcovrin.vonx.io/register
# Specify indicio nym url
INDICIO_NYM_URL=https://selfserve.indiciotech.io/nym
# Specify Schema Manager contract address
SCHEMA_MANAGER_CONTRACT_ADDRESS=0x4B16719E73949a62E9A7306F352ec73F1B143c27
# Specify File SErver Token
FILE_SERVER_TOKEN=
# Specify RPC URL
RPC_URL=https://polygon-rpc.com
# Specify server url
SERVER_URL=
# Specify windowMs
windowMs=1000
# Specify maxRateLimit
maxRateLimit=800
# Specify Did contract address
DID_CONTRACT_ADDRESS=0x0C16958c4246271622201101C83B9F0Fc7180d15

  EOT
}
