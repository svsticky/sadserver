from ansible.plugins.vars import BaseVarsPlugin  # type:ignore[import]

from functools import lru_cache
import subprocess
import json
import os
import inspect

folder_ids = {
    "production" : "b690c7cf-16bb-4b69-b86a-ae6d01449634",
    "staging": "a4c144b8-457d-45d4-b3a9-ae51014bed02",
}

def extract_info(item):
    name = item["name"]
    fields = {}
    for field in item["fields"]:
        fields[field["name"]] = field["value"]
    if not fields:
        fields = item["notes"]
    return { name: fields }

def parse_bw_output(output):
     items = list(map(extract_info, json.loads(output)))
     ret = {}
     for k in items:
         ret = {**ret, **k}
     return ret

@lru_cache(maxsize=100000)
def global_get_vars():
    host = os.environ["STICKY_ENV"]
    folder_id = folder_ids[host]
    print(f"Fetching credentials from bitwarden for {host} (folder: {folder_id})")
    secrets = parse_bw_output(subprocess.check_output([f"bw list items --folderid {folder_id}"], shell=True))
    ret = {'secrets': secrets }
    print(ret)
    return ret




class VarsModule(BaseVarsPlugin):
    def get_vars(self, load, path, entities):
        return global_get_vars()
