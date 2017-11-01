{% from "vault/default.yml" import lookup, rawmap with context %}
{% set lookup = salt['grains.filter_by'](lookup, grain='os', merge=salt['pillar.get']('vault:lookup')) %}
{% set rawmap = salt['pillar.get']('vault', rawmap, merge=True) %}

{{ lookup.group }}_group:
    group.present:
        - name: {{ lookup.group }}

{{ lookup.user }}_user:
    user.present:
        - name: {{ lookup.user }}
        - fullname: {{ lookup.user }}
        - groups:
            - {{ lookup.group }}
        - shell: /bin/sh
        - home: {{ lookup.datadir }}
        - require:
            - group: {{ lookup.group }}_group

{% if lookup.package is defined %}
    {% if salt['grains.get']('osarch') == 'arm' %}
        {% set _package = lookup.package_arm %}
    {% else %}
        {% set _package = lookup.package %}
    {% endif %}

    {# issue with https and archive.extracted so the workaround is to extract the file manually on the minion and launch this state #}
    {% if salt['file.file_exists']('/usr/local/bin/vault') %}
vault_package:
    file.managed:
        - name: /usr/local/bin/vault
        - user: {{ lookup.user }}
        - group: {{ lookup.group }}
        - mode: 0700
        - require:
            - group: {{ lookup.group }}
            - user: {{ lookup.user }}
    {% else %}
vault_package:
    archive.extracted:
        - name: /usr/local/bin/vault
        - source: {{ _package }}
        {% if lookup.package_hash is defined %}
        - source_hash: {{ lookup.package_hash }}
        {% endif %}
        - archive_format: zip
        - user: {{ lookup.user }}
        - group: {{ lookup.group }}
        - require:
            - group: {{ lookup.group }}
            - user: {{ lookup.user }}
    {% endif %}
{% endif %}

