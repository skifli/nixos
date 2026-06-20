# Multi-container setup for organizing tabs and cookies
# Containers help isolate browsing contexts (work, personal, shopping, etc.)
#
# ⚠ Only if using pins or pinsForce: close Zen before home-manager switch
# (activation script needs exclusive access to modify zen-sessions.jsonlz4)
#
# Note: containersForce = true (as I have done) deletes containers not declared here.
# Set to false to keep manually created containers.
{
  Personal = {
    color = "pink";
    icon = "fingerprint";
    id = 1;
  };

  School = {
    color = "green";
    icon = "briefcase";
    id = 2;
  };

  "Stem Racing" = {
    color = "red";
    icon = "vacation";
    id = 3;
  };
}
