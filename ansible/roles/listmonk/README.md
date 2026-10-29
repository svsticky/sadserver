# Listmonk deployment caveats

There are a couple of caveats with deploying Listmonk. These should not come up often, but when _completely_
starting from scratch you could find yourself facing these problems:

1. The settings for the mail server cannot be inserted into listmonk via environment variables.
   This means that after a fresh deployment of Listmonk, i.e. one where the database is not restored, the
   email settings need to be taken from Bitwarden and put into Listmonk via the UI.
2. This also applies for the mmm bot. You need to create a new API user in the UI called mmm and place the
   generated API key in Bitwarden and redeploy Listmonk to update the mmm-bot timer and service to use the new
   API key. The mmm bot user needs the `campagin:manage_all` and `media:manage` permissions.