START TRANSACTION;

DELETE FROM virtual_aliases;
DELETE FROM virtual_users;
DELETE FROM virtual_domains;

{% for domain, accounts in s3mtp_accounts|groupby('domain') %}
    INSERT INTO virtual_domains (name) VALUES ('{{ domain }}');
    INSERT INTO virtual_users (domain_id, password, email) VALUES
    {% for account in accounts %}
        (
            (SELECT id from virtual_domains WHERE name LIKE '{{ account['domain'] }}'),
            '{{ account['password'] }}',
            '{{ account['user'] }}@{{ account['domain'] }}'
        ){% if not loop.last %},{% endif %}
    {% endfor %}
    ;
{% endfor %}

INSERT INTO virtual_aliases (domain_id, source, destination) VALUES
{% for alias in s3mtp_aliases %}
(
    (SELECT id from virtual_domains WHERE name LIKE '{{ alias['domain'] }}'),
    '{{ alias['from'] }}',
    '{{ alias['to'] }}'
){% if not loop.last %},{% endif %}
{% endfor %}
;

COMMIT;
