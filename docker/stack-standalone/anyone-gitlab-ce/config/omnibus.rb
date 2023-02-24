external_url 'http://gitlab.lan/'
gitlab_rails['initial_root_password'] = File.read('/run/secrets/password_secret')