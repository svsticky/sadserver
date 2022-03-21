from ansible.plugins.vars import BaseVarsPlugin  # type:ignore[import]

from functools import lru_cache
import subprocess
import json

# Utility class that allows dot syntax on dict objects
class DictObj:
    def __init__(self, in_dict:dict):
        assert isinstance(in_dict, dict)
        for key, val in in_dict.items():
            if isinstance(val, (list, tuple)):
               setattr(self, key, [DictObj(x) if isinstance(x, dict) else x for x in val])
            else:
               setattr(self, key, DictObj(val) if isinstance(val, dict) else val)

def extract_info(item):
    name = item["name"]
    fields = {}
    for field in item["fields"]:
        fields[field["name"]] = field["value"]
    return { name: fields }

def parse_bw_output(output):
    return list(map(extract_info, json.loads(output)))

@lru_cache(maxsize=1000)
def global_get_vars():
    print("Hi from bw plugin")
    output = parse_bw_output(subprocess.check_output(["bw list items --folderid a4c144b8-457d-45d4-b3a9-ae51014bed02"], shell=True))
    print(output[1])
    return {'secret_hello': DictObj(output[1]) }




class VarsModule(BaseVarsPlugin):
    def get_vars(self, load, path, entities):
        return global_get_vars()
