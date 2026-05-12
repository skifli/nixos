# Multi-container setup for organizing tabs and cookies
# Containers help isolate browsing contexts (work, personal, shopping, etc.)
#
# ⚠ Only if using pins or pinsForce: close Zen before home-manager switch
# (activation script needs exclusive access to modify zen-sessions.jsonlz4)
#
# Note: containersForce = true (as I have done) deletes containers not declared here.
# Set to false to keep manually created containers.
{
  Home = {
    color = "green";
    icon = "briefcase";
    id = 1;
  };

  Work = {
    color = "blue";
    icon = "fingerprint";
    id = 2;
  };
}
