# NiFi Access

- **URL:** https://localhost:8161/nifi
- **User:** `nifiuser`
- **Password:** `nifiPass!2025`

## Notes

NiFi in this compose runs in secure (HTTPS) mode with a self-signed certificate. When opening the URL in a browser, you will need to accept the certificate exception.

### Backups

Backups of the original files changed are stored inside the NiFi container:
- `/opt/nifi/nifi-current/conf/login-identity-providers.xml.bak`
- `/opt/nifi/nifi-current/conf/authorizers.xml.bak`

### Quick curl examples (from host)

Test login with curl (accept insecure TLS):
```bash
curl -k -i -X POST 'https://localhost:8161/nifi-api/access/token' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -H 'X-Requested-By: cli' \
  -d 'username=nifiuser&password=nifiPass!2025'
```

### Revert changes

To restore the original configuration and restart NiFi:
```bash
docker-compose -f docker-compose-full.yml exec -T nifi bash -lc \
  "cp /opt/nifi/nifi-current/conf/login-identity-providers.xml.bak /opt/nifi/nifi-current/conf/login-identity-providers.xml && \
   cp /opt/nifi/nifi-current/conf/authorizers.xml.bak /opt/nifi/nifi-current/conf/authorizers.xml"
docker-compose -f docker-compose-full.yml restart nifi
```

### Security recommendation

Change the temporary password after first login. To set a new password:
1. Generate a bcrypt hash for your new password
2. Replace the `Password` property under the `single-user-provider` in `/opt/nifi/nifi-current/conf/login-identity-providers.xml`
3. Restart NiFi

If you want, I can generate a different password and apply it now.
