{% from "vault/default.yml" import lookup, rawmap with context %}
{% set lookup = salt['grains.filter_by'](lookup, grain='os', merge=salt['pillar.get']('vault:lookup')) %}
{% set rawmap = salt['pillar.get']('vault', rawmap, merge=True) %}

{% if lookup.config_file is defined %}
vault_config:
    file.managed:
        - name: {{ lookup.config_file }}
        - source: salt://vault/files/vault.json.j2
        - template: jinja
        - makedirs: True
        - user: {{ lookup.user }}
        - group: {{ lookup.group }}
        - context:
            config: {{ rawmap }}
            lookup: {{ lookup }}

vault_datadir:
    file.directory:
        - name: {{ lookup.datadir }}
        - makedirs: True
        - mode: 0700
        - user: {{ lookup.user }}
        - group: {{ lookup.group }}
{% endif %}

