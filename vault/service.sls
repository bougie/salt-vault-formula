{% from "vault/default.yml" import lookup, rawmap with context %}
{% set lookup = salt['grains.filter_by'](lookup, grain='os', merge=salt['pillar.get']('vault:lookup')) %}
{% set rawmap = salt['pillar.get']('vault', rawmap, merge=True) %}

{% if lookup.service is defined %}
vault_piddir_file:
    file.directory:
        - name: /var/run/vault
        - user: {{ lookup.user }}
        - group: {{ lookup.group }}

    {% if lookup.service_file is defined %}
vault_service_file:
    file.managed:
        - name: {{ lookup.service_file }}
        - source: salt://vault/files/vault.j2
        - template: jinja
        - mode: 0555
        - context:
            config: {{ rawmap }}
            lookup: {{ lookup }}
    {% endif %}

vault_service:
    service.running:
        - name: {{ lookup.service }}
        - enable: True
{% endif %}
