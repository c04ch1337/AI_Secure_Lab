# FAQ

**Q: Does this require Internet?**  
A: Only for initial image/model pulls. Once cached, it runs offline.

**Q: Can I add TLS?**  
A: Yes—add a cert resolver in Traefik and bind `:443`. For lab use, HTTP is simplest.

**Q: Can I skip the Python firewall?**  
A: Yes. Set Traefik to route directly to OpenWebUI by disabling the firewall service labels in `docker-compose.yml` (see comments).

**Q: Power Automate integration?**  
A: Use the firewall endpoint (`/v1/chat`) as your policy-ingress URL to centralize checks and logging.
