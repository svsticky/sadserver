from ansible.plugins.vars import BaseVarsPlugin  # type:ignore[import]

class VarsModule(BaseVarsPlugin):
    def get_vars(self, load, path, entities):
        print("Hi from bw plugin")
        return {'secret_hello': 'world'}
